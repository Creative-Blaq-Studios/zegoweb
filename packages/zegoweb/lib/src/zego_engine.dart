// packages/zegoweb/lib/src/zego_engine.dart
import 'dart:async';
import 'dart:js_interop';

import 'package:meta/meta.dart';

import 'interop/event_bridge.dart';
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

  // Tasks 25-30 add room/stream methods onto these stubs.
  Future<void> loginRoom(String roomId, ZegoUser user) async {
    requireAlive();
    throw UnimplementedError('loginRoom — added in Task 25');
  }

  Future<void> logoutRoom([String? roomId]) async {
    requireAlive();
    throw UnimplementedError('logoutRoom — added in Task 25');
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
    // Tasks 25/27/28 add subscriptions here.
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
