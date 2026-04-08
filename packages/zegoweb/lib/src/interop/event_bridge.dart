// packages/zegoweb/lib/src/interop/event_bridge.dart
//
// Wires JS `engine.on('eventName', cb)` subscriptions into Dart broadcast
// Streams. Exactly one JS listener is installed per event name, regardless of
// how many Dart subscribers attach — downstream listeners share a single
// StreamController.broadcast().
//
// Two levels of API:
//   * Generic: `registerEvent<T>(name, parse)` — used by tests and for any
//     SDK event we don't yet have a typed helper for.
//   * Typed getters: `onRoomStateUpdate`, `onRoomUserUpdate`,
//     `onRoomStreamUpdate`, `onPublisherStateUpdate`, `onPlayerStateUpdate`,
//     `onTokenWillExpire` — consumed by ZegoEngine.
//
// Invariants:
//   * `registerEvent(name, parse)` called twice for the same name returns
//     the SAME Stream instance. The parse function from the FIRST call wins.
//   * `dispose()` is idempotent and tears down every controller and every
//     JS-side listener installed by this bridge.

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import '../models/zego_enums.dart';
import '../models/zego_events.dart';
import '../models/zego_stream_info.dart';
import '../models/zego_user.dart';
import '../token_bridge.dart';
import 'zego_js.dart';

class EventBridge implements TokenBridge {
  EventBridge(this._engine);

  final JSObject _engine;
  final Map<String, _EventEntry<Object?>> _entries =
      <String, _EventEntry<Object?>>{};
  bool _disposed = false;

  /// Register (or look up) a broadcast stream for [eventName]. The [parse]
  /// function converts the raw JS payload into the Dart-side model type.
  ///
  /// Returns a `Stream<T>` backed by a `StreamController<T>.broadcast()`.
  Stream<T> registerEvent<T>(String eventName, T Function(JSAny?) parse) {
    if (_disposed) {
      throw StateError('EventBridge disposed — cannot register "$eventName"');
    }

    final existing = _entries[eventName];
    if (existing != null) {
      return existing.stream as Stream<T>;
    }

    final controller = StreamController<T>.broadcast();
    final stream = controller.stream;

    void dartCallback(JSAny? payload) {
      if (controller.isClosed) return;
      try {
        controller.add(parse(payload));
      } catch (err, st) {
        controller.addError(err, st);
      }
    }

    final jsCallback = dartCallback.toJS;

    (_engine['on'] as JSFunction).callAsFunction(
      _engine,
      eventName.toJS,
      jsCallback,
    );

    _entries[eventName] = _EventEntry<Object?>(
      controller: controller as StreamController<Object?>,
      stream: stream,
      jsCallback: jsCallback,
    );

    return stream;
  }

  /// True if any subscribers are attached to [eventName]'s stream.
  bool hasListeners(String eventName) {
    final e = _entries[eventName];
    return e != null && e.controller.hasListener;
  }

  /// Tear down all registered streams. Removes JS listeners and closes every
  /// broadcast controller. Safe to call multiple times.
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;

    final entries = List<MapEntry<String, _EventEntry<Object?>>>.of(
      _entries.entries,
    );
    _entries.clear();

    for (final entry in entries) {
      try {
        (_engine['off'] as JSFunction).callAsFunction(
          _engine,
          entry.key.toJS,
          entry.value.jsCallback,
        );
      } catch (_) {
        // Swallow JS-side removal errors: if the engine was already destroyed
        // by a prior call there is nothing to clean up on that side.
      }
      await entry.value.controller.close();
    }
  }

  // ---------------------------------------------------------------------------
  // Typed getters — one per semantic event.
  // ---------------------------------------------------------------------------

  Stream<ZegoRoomStateChanged> get onRoomStateUpdate =>
      registerEvent<ZegoRoomStateChanged>(
        ZegoJsEvents.roomStateChanged,
        _parseRoomStateChanged,
      );

  Stream<ZegoRoomUserUpdate> get onRoomUserUpdate =>
      registerEvent<ZegoRoomUserUpdate>(
        ZegoJsEvents.roomUserUpdate,
        _parseRoomUserUpdate,
      );

  Stream<ZegoRoomStreamUpdate> get onRoomStreamUpdate =>
      registerEvent<ZegoRoomStreamUpdate>(
        ZegoJsEvents.roomStreamUpdate,
        _parseRoomStreamUpdate,
      );

  Stream<ZegoPublisherStateChanged> get onPublisherStateUpdate =>
      registerEvent<ZegoPublisherStateChanged>(
        ZegoJsEvents.publisherStateUpdate,
        _parsePublisherStateChanged,
      );

  Stream<ZegoPlayerStateChanged> get onPlayerStateUpdate =>
      registerEvent<ZegoPlayerStateChanged>(
        ZegoJsEvents.playerStateUpdate,
        _parsePlayerStateChanged,
      );

  @override
  Stream<ZegoTokenWillExpire> get onTokenWillExpire =>
      registerEvent<ZegoTokenWillExpire>(
        ZegoJsEvents.tokenWillExpire,
        _parseTokenWillExpire,
      );
}

// ---------------------------------------------------------------------------
// Parse helpers — top-level so tests can exercise them if needed.
// ---------------------------------------------------------------------------

String? _readString(JSObject obj, String key) {
  final v = obj[key];
  if (v == null) return null;
  if (v.isA<JSString>()) return (v as JSString).toDart;
  return null;
}

int? _readInt(JSObject obj, String key) {
  final v = obj[key];
  if (v == null) return null;
  if (v.isA<JSNumber>()) return (v as JSNumber).toDartInt;
  return null;
}

ZegoRoomState _parseRoomStateEnum(String? raw) {
  switch (raw) {
    case 'CONNECTED':
      return ZegoRoomState.connected;
    case 'CONNECTING':
      return ZegoRoomState.connecting;
    case 'DISCONNECTED':
    default:
      return ZegoRoomState.disconnected;
  }
}

ZegoUpdateType _parseUpdateTypeEnum(String? raw) {
  switch (raw) {
    case 'add':
    case 'ADD':
      return ZegoUpdateType.add;
    case 'delete':
    case 'DELETE':
    default:
      return ZegoUpdateType.delete;
  }
}

ZegoRoomStateChanged _parseRoomStateChanged(JSAny? raw) {
  final o = raw as JSObject;
  return ZegoRoomStateChanged(
    roomId: _readString(o, 'roomID') ?? '',
    state: _parseRoomStateEnum(_readString(o, 'state')),
    errorCode: _readInt(o, 'errorCode'),
    extendedData: _readString(o, 'extendedData'),
  );
}

ZegoRoomUserUpdate _parseRoomUserUpdate(JSAny? raw) {
  final o = raw as JSObject;
  final list = (o['userList'] as JSArray<JSObject>?) ??
      (o['users'] as JSArray<JSObject>?) ??
      JSArray<JSObject>();
  final users = <ZegoUser>[];
  for (var i = 0; i < list.length; i++) {
    final u = list[i];
    users.add(
      ZegoUser(
        userId: _readString(u, 'userID') ?? '',
        userName: _readString(u, 'userName') ?? '',
      ),
    );
  }
  return ZegoRoomUserUpdate(
    roomId: _readString(o, 'roomID') ?? '',
    type: _parseUpdateTypeEnum(_readString(o, 'updateType')),
    users: users,
  );
}

ZegoRoomStreamUpdate _parseRoomStreamUpdate(JSAny? raw) {
  final o = raw as JSObject;
  final list = (o['streamList'] as JSArray<JSObject>?) ??
      (o['streams'] as JSArray<JSObject>?) ??
      JSArray<JSObject>();
  final streams = <ZegoStreamInfo>[];
  for (var i = 0; i < list.length; i++) {
    final s = list[i];
    final userObj = s['user'] as JSObject?;
    final user = userObj == null
        ? const ZegoUser(userId: '', userName: '')
        : ZegoUser(
            userId: _readString(userObj, 'userID') ?? '',
            userName: _readString(userObj, 'userName') ?? '',
          );
    streams.add(
      ZegoStreamInfo(
        streamId: _readString(s, 'streamID') ?? '',
        user: user,
        extraInfo: _readString(s, 'extraInfo'),
      ),
    );
  }
  return ZegoRoomStreamUpdate(
    roomId: _readString(o, 'roomID') ?? '',
    type: _parseUpdateTypeEnum(_readString(o, 'updateType')),
    streams: streams,
  );
}

ZegoPublisherStateChanged _parsePublisherStateChanged(JSAny? raw) {
  final o = raw as JSObject;
  return ZegoPublisherStateChanged(
    streamId: _readString(o, 'streamID') ?? '',
    state: _readString(o, 'state') ?? '',
    errorCode: _readInt(o, 'errorCode'),
    extendedData: _readString(o, 'extendedData'),
  );
}

ZegoPlayerStateChanged _parsePlayerStateChanged(JSAny? raw) {
  final o = raw as JSObject;
  return ZegoPlayerStateChanged(
    streamId: _readString(o, 'streamID') ?? '',
    state: _readString(o, 'state') ?? '',
    errorCode: _readInt(o, 'errorCode'),
    extendedData: _readString(o, 'extendedData'),
  );
}

ZegoTokenWillExpire _parseTokenWillExpire(JSAny? raw) {
  final o = raw as JSObject;
  return ZegoTokenWillExpire(
    roomId: _readString(o, 'roomID') ?? '',
    remainingSeconds: _readInt(o, 'remainTimeInSecond') ?? 0,
  );
}

class _EventEntry<T> {
  _EventEntry({
    required this.controller,
    required this.stream,
    required this.jsCallback,
  });
  final StreamController<T> controller;
  final Stream<Object?> stream;
  final JSFunction jsCallback;
}
