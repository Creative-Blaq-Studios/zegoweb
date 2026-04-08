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
  /// Register (or look up) a broadcast stream for [eventName]. The [parse]
  /// function converts the raw positional JS arguments into the Dart-side
  /// model type. The arg list is always exactly 4 entries — unused slots
  /// are `null`. Four slots cover every event the plugin handles:
  ///
  ///   * roomStateUpdate(roomID, state, errorCode, extendedData) — 4 args
  ///   * roomStreamUpdate(roomID, updateType, streamList, extendedData) — 4 args
  ///   * roomUserUpdate(roomID, updateType, userList) — 3 args (args[3]=null)
  ///   * publisherStateUpdate(result) — 1 arg (args[1..3]=null)
  ///   * playerStateUpdate(result) — 1 arg
  ///   * tokenWillExpire(roomID) — 1 arg
  ///
  /// Returns a `Stream<T>` backed by a `StreamController<T>.broadcast()`.
  Stream<T> registerEvent<T>(
    String eventName,
    T Function(List<JSAny?> args) parse,
  ) {
    if (_disposed) {
      throw StateError('EventBridge disposed — cannot register "$eventName"');
    }

    final existing = _entries[eventName];
    if (existing != null) {
      return existing.stream as Stream<T>;
    }

    final controller = StreamController<T>.broadcast();
    final stream = controller.stream;

    // dart:js_interop's `.toJS` converts a Dart function with up to several
    // positional parameters into a JSFunction. JS callers can supply any
    // number of args; Dart receives up to the declared count and missing
    // args become null. Four slots match the maximum arity of any event the
    // plugin wires.
    void dartCallback([
      JSAny? a0,
      JSAny? a1,
      JSAny? a2,
      JSAny? a3,
    ]) {
      if (controller.isClosed) return;
      try {
        controller.add(parse(<JSAny?>[a0, a1, a2, a3]));
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

/// Maps the state string on both `roomStateUpdate` and `roomStateChanged`
/// into the plugin's simpler 3-state enum. The legacy event uses
/// CONNECTED/CONNECTING/DISCONNECTED; the newer event uses a reason enum
/// with ~10 values (LOGINING, LOGINED, LOGIN_FAILED, RECONNECTING,
/// RECONNECTED, RECONNECT_FAILED, KICKOUT, LOGOUT, LOGOUT_FAILED). We
/// collapse both sets into connected / connecting / disconnected.
ZegoRoomState _parseRoomStateEnum(String? raw) {
  switch (raw) {
    case 'CONNECTED':
    case 'LOGINED':
    case 'RECONNECTED':
      return ZegoRoomState.connected;
    case 'CONNECTING':
    case 'LOGINING':
    case 'RECONNECTING':
      return ZegoRoomState.connecting;
    case 'DISCONNECTED':
    case 'LOGIN_FAILED':
    case 'LOGOUT':
    case 'LOGOUT_FAILED':
    case 'KICKOUT':
    case 'RECONNECT_FAILED':
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

// Positional-arg helpers — pull a JSString/JSNumber out of a slot returned
// from a Dart-side dartCallback(...args) wrapper.

String? _argString(List<JSAny?> args, int i) {
  if (i >= args.length) return null;
  final v = args[i];
  if (v == null) return null;
  if (v.isA<JSString>()) return (v as JSString).toDart;
  return null;
}

int? _argInt(List<JSAny?> args, int i) {
  if (i >= args.length) return null;
  final v = args[i];
  if (v == null) return null;
  if (v.isA<JSNumber>()) return (v as JSNumber).toDartInt;
  return null;
}

JSObject? _argObject(List<JSAny?> args, int i) {
  if (i >= args.length) return null;
  final v = args[i];
  if (v == null) return null;
  if (v.isA<JSObject>()) return v as JSObject;
  return null;
}

JSArray<JSObject>? _argArray(List<JSAny?> args, int i) {
  final obj = _argObject(args, i);
  if (obj == null) return null;
  return obj as JSArray<JSObject>;
}

/// Parses `roomStateUpdate(roomID, state, errorCode, extendedData)`.
///
/// Uses the legacy 3-state enum (CONNECTED / CONNECTING / DISCONNECTED)
/// rather than the newer `roomStateChanged` event, which fires a reason
/// enum with ~10 values (LOGINING, LOGINED, LOGIN_FAILED, …). The legacy
/// event still fires in 3.12 and the simpler state machine is sufficient
/// for every consumer of this plugin.
ZegoRoomStateChanged _parseRoomStateChanged(List<JSAny?> args) {
  return ZegoRoomStateChanged(
    roomId: _argString(args, 0) ?? '',
    state: _parseRoomStateEnum(_argString(args, 1)),
    errorCode: _argInt(args, 2),
    extendedData: _argString(args, 3),
  );
}

/// Parses `roomUserUpdate(roomID, updateType, userList)`.
ZegoRoomUserUpdate _parseRoomUserUpdate(List<JSAny?> args) {
  final roomId = _argString(args, 0) ?? '';
  final updateType = _parseUpdateTypeEnum(_argString(args, 1));
  final list = _argArray(args, 2) ?? JSArray<JSObject>();
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
    roomId: roomId,
    type: updateType,
    users: users,
  );
}

/// Parses `roomStreamUpdate(roomID, updateType, streamList, extendedData)`.
ZegoRoomStreamUpdate _parseRoomStreamUpdate(List<JSAny?> args) {
  final roomId = _argString(args, 0) ?? '';
  final updateType = _parseUpdateTypeEnum(_argString(args, 1));
  final list = _argArray(args, 2) ?? JSArray<JSObject>();
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
    roomId: roomId,
    type: updateType,
    streams: streams,
  );
}

/// Parses `publisherStateUpdate(result)` — single object arg.
ZegoPublisherStateChanged _parsePublisherStateChanged(List<JSAny?> args) {
  final o = _argObject(args, 0) ?? JSObject();
  return ZegoPublisherStateChanged(
    streamId: _readString(o, 'streamID') ?? '',
    state: _readString(o, 'state') ?? '',
    errorCode: _readInt(o, 'errorCode'),
    extendedData: _readString(o, 'extendedData'),
  );
}

/// Parses `playerStateUpdate(result)` — single object arg.
ZegoPlayerStateChanged _parsePlayerStateChanged(List<JSAny?> args) {
  final o = _argObject(args, 0) ?? JSObject();
  return ZegoPlayerStateChanged(
    streamId: _readString(o, 'streamID') ?? '',
    state: _readString(o, 'state') ?? '',
    errorCode: _readInt(o, 'errorCode'),
    extendedData: _readString(o, 'extendedData'),
  );
}

/// Parses `tokenWillExpire(roomID)` — single string arg. The SDK does not
/// report remainingSeconds on the 3.12 callback; we default to 30 which is
/// the documented trigger threshold.
ZegoTokenWillExpire _parseTokenWillExpire(List<JSAny?> args) {
  return ZegoTokenWillExpire(
    roomId: _argString(args, 0) ?? '',
    remainingSeconds: 30,
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
