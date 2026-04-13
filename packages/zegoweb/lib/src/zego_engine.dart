// packages/zegoweb/lib/src/zego_engine.dart
import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:meta/meta.dart';

import 'package:web/web.dart' as web;

import 'interop/event_bridge.dart';
import 'interop/promise_adapter.dart';
import 'interop/zego_js.dart';
import 'log.dart';
import 'models/zego_config.dart';
import 'models/zego_device_info.dart';
import 'models/zego_enums.dart';
import 'models/zego_error.dart';
import 'models/zego_events.dart';
import 'models/zego_user.dart';
import 'state_guard.dart';
import 'token_manager.dart';
import 'zego_local_stream.dart';
import 'zego_remote_stream.dart';

/// Main entry point for publishing and playing media. Obtain an instance
/// via `ZegoWeb.createEngine`.
class ZegoEngine with StateGuard {
  /// Production constructor used by `ZegoWeb.createEngine`. Tests should
  /// prefer [ZegoEngine.test].
  @internal
  ZegoEngine.internal({
    required ZegoExpressEngineJs js,
    required EventBridge eventBridge,
    required TokenManager tokenManager,
  })  : _js = js,
        _eventBridge = eventBridge,
        _tokenManager = tokenManager {
    _wireEventStreams();
  }

  /// Test-only constructor. Builds a default [EventBridge] and
  /// [TokenManager] around the provided JS handle and provider.
  @visibleForTesting
  factory ZegoEngine.test({
    required JSObject js,
    Future<String> Function()? tokenProvider,
    EventBridge? eventBridge,
    TokenManager? tokenManager,
  }) {
    final jsEngine = js as ZegoExpressEngineJs;
    final bridge = eventBridge ?? EventBridge(jsEngine);
    final tm = tokenManager ??
        TokenManager(tokenProvider: tokenProvider ?? () async => '');
    return ZegoEngine.internal(
      js: jsEngine,
      eventBridge: bridge,
      tokenManager: tm,
    );
  }

  final ZegoExpressEngineJs _js;
  final EventBridge _eventBridge;
  final TokenManager _tokenManager;

  // ignore: unused_field
  ZegoUser? _currentUser;
  final Map<String, ZegoLocalStream> _locals = <String, ZegoLocalStream>{};
  final Map<String, ZegoRemoteStream> _remotes = <String, ZegoRemoteStream>{};
  final List<StreamSubscription<dynamic>> _bridgeSubs =
      <StreamSubscription<dynamic>>[];

  final StreamController<ZegoError> _errorController =
      StreamController<ZegoError>.broadcast();
  final StreamController<ZegoRoomState> _roomStateController =
      StreamController<ZegoRoomState>.broadcast();
  final StreamController<ZegoRoomUserUpdate> _userUpdateController =
      StreamController<ZegoRoomUserUpdate>.broadcast();
  final StreamController<ZegoRoomStreamUpdate> _streamUpdateController =
      StreamController<ZegoRoomStreamUpdate>.broadcast();

  /// Broadcast stream of asynchronous errors.
  Stream<ZegoError> get onError => _errorController.stream;

  /// Broadcast stream of room state transitions.
  Stream<ZegoRoomState> get onRoomStateChanged => _roomStateController.stream;

  /// Broadcast stream of user membership updates.
  Stream<ZegoRoomUserUpdate> get onRoomUserUpdate =>
      _userUpdateController.stream;

  /// Broadcast stream of stream membership updates.
  Stream<ZegoRoomStreamUpdate> get onRoomStreamUpdate =>
      _streamUpdateController.stream;

  Future<void> loginRoom(String roomId, ZegoUser user) async {
    requireAlive();
    ZegoLog.info('ZegoEngine.loginRoom room=$roomId user=${user.userId}');
    final token = await _tokenManager.initialToken();
    final jsUser = ZegoUserJs(userID: user.userId, userName: user.userName);
    // ZegoRoomConfig: userUpdate=true tells the SDK to fire roomUserUpdate
    // events. It's off by default — without it we can't see peer joins.
    // maxMemberCount=0 means "unlimited" (the SDK default).
    final config = JSObject();
    config['userUpdate'] = true.toJS;
    config['maxMemberCount'] = 0.toJS;
    try {
      await futureFromJsPromise<void>(
        _js.loginRoom(roomId, token, jsUser, config),
      );
    } on ZegoError {
      rethrow;
    } catch (e, st) {
      throw ZegoError(-1, 'loginRoom failed: $e', cause: e, stackTrace: st);
    }
    _currentUser = user;
    setCurrentRoom(roomId);
    _tokenManager.wireRefresh(
      _eventBridge,
      // renewToken is sync in 3.12; wrap in a completed Future so the
      // RenewFn signature stays Future-returning.
      (room, tk) async {
        _js.renewToken(tk, room);
      },
      _errorController,
    );
  }

  Future<void> logoutRoom([String? roomId]) async {
    requireAlive();
    final current = currentRoomId;
    if (current == null) {
      ZegoLog.info('ZegoEngine.logoutRoom: no active room; ignoring');
      return;
    }
    final targetRoom = roomId ?? current;
    ZegoLog.info('ZegoEngine.logoutRoom room=$targetRoom');

    // Auto-stop any publishing / playing streams. All three of these SDK
    // methods are synchronous in 3.12 — no await needed.
    for (final id in List<String>.from(_locals.keys)) {
      try {
        _js.stopPublishingStream(id);
      } catch (e) {
        ZegoLog.warn('stopPublishingStream($id) during logout: $e');
      }
    }
    _locals.clear();
    for (final id in List<String>.from(_remotes.keys)) {
      try {
        _js.stopPlayingStream(id);
      } catch (e) {
        ZegoLog.warn('stopPlayingStream($id) during logout: $e');
      }
    }
    _remotes.clear();

    try {
      _js.logoutRoom(targetRoom);
    } catch (e, st) {
      throw ZegoError(-1, 'logoutRoom failed: $e', cause: e, stackTrace: st);
    } finally {
      clearCurrentRoom();
      _currentUser = null;
    }
  }

  Future<ZegoLocalStream> createLocalStream({ZegoStreamConfig? config}) async {
    requireAlive();
    final cfg = config ?? const ZegoStreamConfig();
    ZegoLog.info('ZegoEngine.createLocalStream config=$cfg');
    final jsConfig = cfg.toJs();
    final JSObject jsStream;
    try {
      jsStream = await futureFromJsPromise<JSObject>(
        _js.createStream(jsConfig),
        convert: (any) => any! as JSObject,
      );
    } catch (e, st) {
      throw _mapMediaError(e, st);
    }
    final streamId = (jsStream['streamID'] as JSString?)?.toDart ??
        'local-${DateTime.now().microsecondsSinceEpoch}';
    final handle = zegoLocalStreamInternal(streamId, jsStream);
    _locals[streamId] = handle;
    return handle;
  }

  ZegoError _mapMediaError(Object e, StackTrace st) {
    if (e is ZegoPermissionException) return e;
    // The promise adapter wraps unknown JS rejections as ZegoError(-1, ...)
    // and stores the original JS object in `cause`. For DOMException-shaped
    // errors that's where `.name` lives.
    final domName = _readDomExceptionName(e);
    final msg = e is ZegoError ? e.message : e.toString();
    if (domName == 'NotAllowedError' ||
        msg.contains('NotAllowedError') ||
        msg.contains('Permission denied')) {
      return ZegoPermissionException(
        1103065,
        'Camera/microphone permission denied: $msg',
        kind: PermissionErrorKind.denied,
        cause: e,
        stackTrace: st,
      );
    }
    if (domName == 'NotFoundError' || msg.contains('NotFoundError')) {
      return ZegoPermissionException(
        1103066,
        'No camera/microphone device found: $msg',
        kind: PermissionErrorKind.notFound,
        cause: e,
        stackTrace: st,
      );
    }
    if (domName == 'NotReadableError' || msg.contains('NotReadableError')) {
      return ZegoPermissionException(
        1103067,
        'Camera/microphone is in use by another app: $msg',
        kind: PermissionErrorKind.inUse,
        cause: e,
        stackTrace: st,
      );
    }
    if (e is ZegoError) return e;
    return ZegoError(
      -1,
      'createLocalStream failed: $e',
      cause: e,
      stackTrace: st,
    );
  }

  /// Reads `.name` off a DOMException-shaped JS object that was wrapped by
  /// the promise adapter into a ZegoError's `cause`. Returns null if [e] is
  /// not a wrapped JS object.
  String? _readDomExceptionName(Object e) {
    JSObject? jsObj;
    if (e is ZegoError) {
      final cause = e.cause;
      if (cause is JSObject) jsObj = cause;
    } else if (e is JSObject) {
      jsObj = e;
    }
    if (jsObj == null) return null;
    final raw = jsObj['name'];
    if (raw is JSString) return raw.toDart;
    return null;
  }

  Future<void> startPublishing(
    String streamId,
    ZegoLocalStream stream,
  ) async {
    requireAlive();
    requireRoom();
    ZegoLog.info('ZegoEngine.startPublishing streamId=$streamId');
    // startPublishingStream is SYNCHRONOUS in 3.12 — returns a boolean
    // synchronously, not a Promise. Do not await.
    try {
      _js.startPublishingStream(streamId, stream.jsStream);
    } catch (e, st) {
      throw ZegoError(
        -1,
        'startPublishing failed: $e',
        cause: e,
        stackTrace: st,
      );
    }
  }

  Future<void> stopPublishing(String streamId) async {
    requireAlive();
    ZegoLog.info('ZegoEngine.stopPublishing streamId=$streamId');
    try {
      _js.stopPublishingStream(streamId);
    } catch (e, st) {
      throw ZegoError(
        -1,
        'stopPublishing failed: $e',
        cause: e,
        stackTrace: st,
      );
    }
  }

  Future<ZegoRemoteStream> startPlaying(String streamId) async {
    requireAlive();
    requireRoom();
    ZegoLog.info('ZegoEngine.startPlaying streamId=$streamId');
    final JSObject jsStream;
    try {
      // Omit the second positional arg entirely when we don't have a
      // play option. Passing `null` explicitly makes the SDK reject with
      // 1104001 "input parm error" — it dereferences the config object
      // internally and crashes on null (rather than treating it as
      // "no config").
      jsStream = await futureFromJsPromise<JSObject>(
        _js.startPlayingStream(streamId),
        convert: (any) => any! as JSObject,
      );
    } catch (e, st) {
      throw ZegoError(
        -1,
        'startPlaying failed: $e',
        cause: e,
        stackTrace: st,
      );
    }
    final handle = zegoRemoteStreamInternal(streamId, jsStream);
    _remotes[streamId] = handle;
    return handle;
  }

  Future<void> stopPlaying(String streamId) async {
    requireAlive();
    ZegoLog.info('ZegoEngine.stopPlaying streamId=$streamId');
    try {
      _js.stopPlayingStream(streamId);
    } catch (e, st) {
      throw ZegoError(
        -1,
        'stopPlaying failed: $e',
        cause: e,
        stackTrace: st,
      );
    } finally {
      _remotes.remove(streamId);
    }
  }

  Future<List<ZegoDeviceInfo>> getCameras() async {
    requireAlive();
    final jsList = await futureFromJsPromise<JSArray<JSObject>>(
      _js.getCameras(),
      convert: (any) => any! as JSArray<JSObject>,
    );
    return _mapDeviceList(jsList);
  }

  Future<List<ZegoDeviceInfo>> getMicrophones() async {
    requireAlive();
    final jsList = await futureFromJsPromise<JSArray<JSObject>>(
      _js.getMicrophones(),
      convert: (any) => any! as JSArray<JSObject>,
    );
    return _mapDeviceList(jsList);
  }

  List<ZegoDeviceInfo> _mapDeviceList(JSArray<JSObject> jsList) {
    final out = <ZegoDeviceInfo>[];
    for (var i = 0; i < jsList.length; i++) {
      final entry = jsList[i];
      final id = (entry['deviceID'] as JSString?)?.toDart ?? '';
      final name = (entry['deviceName'] as JSString?)?.toDart ?? '';
      out.add(ZegoDeviceInfo(deviceId: id, deviceName: name));
    }
    return out;
  }

  /// Returns the most-recently-created local stream, or throws a
  /// [ZegoStateError] with an actionable message if none exists. Device
  /// methods target this stream because the JS SDK binds camera/mic changes
  /// to a specific `MediaStream`.
  ZegoLocalStream _requireLocalStream(String op) {
    if (_locals.isEmpty) {
      throw ZegoStateError(
        -3,
        '$op requires an active local stream; call createLocalStream first',
      );
    }
    return _locals.values.last;
  }

  /// Stops all tracks on a local stream, releasing camera/mic hardware.
  void destroyLocalStream(ZegoLocalStream stream) {
    requireAlive();
    ZegoLog.info('ZegoEngine.destroyLocalStream id=${stream.id}');
    _js.destroyStream(stream.jsStream);
    _locals.remove(stream.id);
  }

  Future<void> useCamera(String deviceId) async {
    requireAlive();
    final local = _requireLocalStream('useCamera');
    await futureFromJsPromise<void>(
      _js.useVideoDevice(local.jsStream, deviceId),
    );
  }

  Future<void> useMicrophone(String deviceId) async {
    requireAlive();
    final local = _requireLocalStream('useMicrophone');
    await futureFromJsPromise<void>(
      _js.useAudioDevice(local.jsStream, deviceId),
    );
  }

  Future<void> muteMicrophone(bool mute) async {
    requireAlive();
    final local = _requireLocalStream('muteMicrophone');
    // mutePublishStreamAudio is SYNCHRONOUS in 3.12 — returns bool, no Promise.
    _js.mutePublishStreamAudio(local.jsStream, mute);
  }

  Future<void> enableCamera(bool enable) async {
    requireAlive();
    final local = _requireLocalStream('enableCamera');
    await futureFromJsPromise<void>(
      _js.enableVideoCaptureDevice(local.jsStream, enable),
    );
  }

  Future<ZegoPermissionStatus> checkPermissions({
    bool camera = true,
    bool mic = true,
  }) async {
    requireAlive();

    Future<ZegoPermissionStatus> query(String name) async {
      try {
        final navObj = web.window.navigator as JSObject;
        final perms = navObj['permissions'];
        if (perms == null) return ZegoPermissionStatus.unavailable;
        final queryFn = (perms as JSObject)['query'] as JSFunction;
        final descriptor = <String, Object?>{'name': name}.jsify() as JSObject;
        final promise =
            queryFn.callAsFunction(perms, descriptor) as JSPromise<JSAny?>;
        final result = (await promise.toDart) as JSObject;
        final state = (result['state'] as JSString?)?.toDart;
        switch (state) {
          case 'granted':
            return ZegoPermissionStatus.granted;
          case 'denied':
            return ZegoPermissionStatus.denied;
          case 'prompt':
            return ZegoPermissionStatus.prompt;
          default:
            return ZegoPermissionStatus.unavailable;
        }
      } catch (_) {
        return ZegoPermissionStatus.prompt;
      }
    }

    ZegoPermissionStatus merge(
      ZegoPermissionStatus a,
      ZegoPermissionStatus b,
    ) {
      if (a == ZegoPermissionStatus.denied ||
          b == ZegoPermissionStatus.denied) {
        return ZegoPermissionStatus.denied;
      }
      if (a == ZegoPermissionStatus.prompt ||
          b == ZegoPermissionStatus.prompt) {
        return ZegoPermissionStatus.prompt;
      }
      if (a == ZegoPermissionStatus.unavailable ||
          b == ZegoPermissionStatus.unavailable) {
        return ZegoPermissionStatus.unavailable;
      }
      return ZegoPermissionStatus.granted;
    }

    ZegoPermissionStatus worst = ZegoPermissionStatus.granted;
    if (camera) worst = merge(worst, await query('camera'));
    if (mic) worst = merge(worst, await query('microphone'));
    return worst;
  }

  void _wireEventStreams() {
    _bridgeSubs.add(
      _eventBridge.onRoomStateUpdate.listen((event) {
        ZegoLog.info(
          'bridge→engine roomStateUpdate room=${event.roomId} '
          'state=${event.state.name} errorCode=${event.errorCode}',
        );
        _roomStateController.add(event.state);
        if (event.state == ZegoRoomState.disconnected &&
            event.errorCode != null &&
            event.errorCode != 0) {
          _errorController.add(
            ZegoNetworkException(
              event.errorCode!,
              event.extendedData ?? 'room disconnected',
            ),
          );
        }
      }),
    );
    _bridgeSubs.add(
      _eventBridge.onRoomUserUpdate.listen((event) {
        ZegoLog.info(
          'bridge→engine roomUserUpdate room=${event.roomId} '
          'type=${event.type.name} users=${event.users.length}',
        );
        _userUpdateController.add(event);
      }),
    );
    _bridgeSubs.add(
      _eventBridge.onRoomStreamUpdate.listen((event) {
        ZegoLog.info(
          'bridge→engine roomStreamUpdate room=${event.roomId} '
          'type=${event.type.name} streams=${event.streams.length}',
        );
        _streamUpdateController.add(event);
      }),
    );
    _bridgeSubs.add(
      _eventBridge.onPublisherStateUpdate.listen((event) {
        if (event.isFailed) {
          _errorController.add(
            ZegoNetworkException(
              event.errorCode ?? -1,
              'publisher state=${event.state} for ${event.streamId}',
            ),
          );
        }
      }),
    );
    _bridgeSubs.add(
      _eventBridge.onPlayerStateUpdate.listen((event) {
        if (event.isFailed) {
          _errorController.add(
            ZegoNetworkException(
              event.errorCode ?? -1,
              'player state=${event.state} for ${event.streamId}',
            ),
          );
        }
      }),
    );
  }

  /// Tears down all subscriptions and closes controllers, AND tells the JS
  /// SDK to stop publishing, leave the room, and destroy its engine. Safe
  /// to call multiple times.
  ///
  /// The JS-side teardown is critical for peer notification: without it,
  /// the ZEGO server keeps the publisher alive and remote viewers continue
  /// to see the stream until the page unloads (or a server-side timeout
  /// fires several minutes later). Each JS call is wrapped in try/catch
  /// because destroy() must be idempotent and never throw.
  Future<void> destroy() async {
    if (isDisposed) return;
    // Capture the active room id BEFORE markDisposed() clears it.
    final roomToLeave = currentRoomId;
    final localStreamIds = List<String>.from(_locals.keys);
    final remoteStreamIds = List<String>.from(_remotes.keys);

    markDisposed();
    ZegoLog.info('ZegoEngine.destroy');

    // -- JS-side teardown (best-effort) ---------------------------------
    for (final id in localStreamIds) {
      try {
        _js.stopPublishingStream(id);
      } catch (e) {
        ZegoLog.warn('stopPublishingStream($id) during destroy: $e');
      }
    }
    // Destroy local streams to release camera/mic hardware.
    for (final local in _locals.values) {
      try {
        _js.destroyStream(local.jsStream);
      } catch (e) {
        ZegoLog.warn('destroyStream during destroy: $e');
      }
    }
    for (final id in remoteStreamIds) {
      try {
        _js.stopPlayingStream(id);
      } catch (e) {
        ZegoLog.warn('stopPlayingStream($id) during destroy: $e');
      }
    }
    if (roomToLeave != null) {
      try {
        _js.logoutRoom(roomToLeave);
      } catch (e) {
        ZegoLog.warn('logoutRoom($roomToLeave) during destroy: $e');
      }
    }
    try {
      _js.destroyEngine();
    } catch (e) {
      ZegoLog.warn('destroyEngine during destroy: $e');
    }

    // -- Dart-side teardown ---------------------------------------------
    for (final sub in _bridgeSubs) {
      await sub.cancel();
    }
    _bridgeSubs.clear();
    _tokenManager.dispose();
    await _eventBridge.dispose();

    _locals.clear();
    _remotes.clear();
    _currentUser = null;

    await _errorController.close();
    await _roomStateController.close();
    await _userUpdateController.close();
    await _streamUpdateController.close();
  }

  @visibleForTesting
  Map<String, ZegoLocalStream> get debugLocals => Map.unmodifiable(_locals);

  @visibleForTesting
  Map<String, ZegoRemoteStream> get debugRemotes => Map.unmodifiable(_remotes);
}
