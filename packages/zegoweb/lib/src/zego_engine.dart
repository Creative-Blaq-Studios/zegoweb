// packages/zegoweb/lib/src/zego_engine.dart
import 'dart:async';
import 'dart:js_interop';

import 'package:meta/meta.dart';

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
    try {
      await futureFromJsPromise<void>(
        _js.loginRoom(roomId, token, jsUser, null),
      );
    } on ZegoError {
      rethrow;
    } catch (e, st) {
      throw ZegoError(-1, 'loginRoom failed: $e', cause: e, stackTrace: st);
    }
    _currentUser = user;
    setCurrentRoom(roomId);
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

    // Auto-stop any publishing / playing streams.
    for (final id in List<String>.from(_locals.keys)) {
      try {
        await futureFromJsPromise<void>(_js.stopPublishingStream(id));
      } catch (e) {
        ZegoLog.warn('stopPublishingStream($id) during logout: $e');
      }
    }
    _locals.clear();
    for (final id in List<String>.from(_remotes.keys)) {
      try {
        await futureFromJsPromise<void>(_js.stopPlayingStream(id));
      } catch (e) {
        ZegoLog.warn('stopPlayingStream($id) during logout: $e');
      }
    }
    _remotes.clear();

    try {
      await futureFromJsPromise<void>(_js.logoutRoom(targetRoom));
    } catch (e, st) {
      throw ZegoError(-1, 'logoutRoom failed: $e', cause: e, stackTrace: st);
    } finally {
      clearCurrentRoom();
      _currentUser = null;
    }
  }

  Future<ZegoLocalStream> createLocalStream({ZegoStreamConfig? config}) async {
    requireAlive();
    throw UnimplementedError('createLocalStream — added in Task 26');
  }

  Future<void> startPublishing(String streamId, ZegoLocalStream stream) async {
    requireAlive();
    throw UnimplementedError('startPublishing — added in Task 27');
  }

  Future<void> stopPublishing(String streamId) async {
    requireAlive();
    throw UnimplementedError('stopPublishing — added in Task 27');
  }

  Future<ZegoRemoteStream> startPlaying(String streamId) async {
    requireAlive();
    throw UnimplementedError('startPlaying — added in Task 28');
  }

  Future<void> stopPlaying(String streamId) async {
    requireAlive();
    throw UnimplementedError('stopPlaying — added in Task 28');
  }

  Future<List<ZegoDeviceInfo>> getCameras() async {
    requireAlive();
    throw UnimplementedError('getCameras — added in Task 29');
  }

  Future<List<ZegoDeviceInfo>> getMicrophones() async {
    requireAlive();
    throw UnimplementedError('getMicrophones — added in Task 29');
  }

  Future<void> useCamera(String deviceId) async {
    requireAlive();
    throw UnimplementedError('useCamera — added in Task 29');
  }

  Future<void> useMicrophone(String deviceId) async {
    requireAlive();
    throw UnimplementedError('useMicrophone — added in Task 29');
  }

  Future<void> muteMicrophone(bool mute) async {
    requireAlive();
    throw UnimplementedError('muteMicrophone — added in Task 29');
  }

  Future<void> enableCamera(bool enable) async {
    requireAlive();
    throw UnimplementedError('enableCamera — added in Task 29');
  }

  Future<ZegoPermissionStatus> checkPermissions({
    bool camera = true,
    bool mic = true,
  }) async {
    requireAlive();
    throw UnimplementedError('checkPermissions — added in Task 29');
  }

  void _wireEventStreams() {
    _bridgeSubs.add(
      _eventBridge.onRoomStateUpdate.listen((event) {
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
      _eventBridge.onRoomUserUpdate.listen(_userUpdateController.add),
    );
    _bridgeSubs.add(
      _eventBridge.onRoomStreamUpdate.listen(_streamUpdateController.add),
    );
  }

  /// Tears down all subscriptions and closes controllers. Safe to call
  /// multiple times.
  Future<void> destroy() async {
    if (isDisposed) return;
    markDisposed();
    ZegoLog.info('ZegoEngine.destroy');

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
