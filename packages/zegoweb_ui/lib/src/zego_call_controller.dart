import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:zegoweb/zegoweb.dart';

import 'package:zegoweb_ui/src/zego_call_config.dart';
import 'package:zegoweb_ui/src/zego_call_state.dart';
import 'package:zegoweb_ui/src/zego_layout_mode.dart';
import 'package:zegoweb_ui/src/zego_participant.dart';

/// Manages the entire call lifecycle, participant state, and media controls.
///
/// Owns a [ZegoEngine] instance — creates it on [join], destroys it on
/// [leave]. Widgets rebuild via [ListenableBuilder] or [AnimatedBuilder].
class ZegoCallController extends ChangeNotifier {
  ZegoCallController({
    required this.engineConfig,
    required this.callConfig,
  }) : _currentLayout = callConfig.layout;

  /// Engine configuration used to create the [ZegoEngine] on [join].
  final ZegoEngineConfig engineConfig;

  /// Call configuration (room, user, UI flags).
  final ZegoCallConfig callConfig;

  // ---------------------------------------------------------------------------
  // Reactive state
  // ---------------------------------------------------------------------------

  ZegoCallState _state = ZegoCallState.idle;

  /// Current call state.
  ZegoCallState get state => _state;

  final List<ZegoParticipant> _participants = [];

  /// Unmodifiable snapshot of the current participant list.
  List<ZegoParticipant> get participants => List.unmodifiable(_participants);

  ZegoLocalStream? _localStream;

  /// The local media stream, available after [join] completes.
  ZegoLocalStream? get localStream => _localStream;

  ZegoLayoutMode _currentLayout;

  /// The currently active layout mode.
  ZegoLayoutMode get currentLayout => _currentLayout;

  bool _isMicOn = true;

  /// Whether the local microphone is enabled.
  bool get isMicOn => _isMicOn;

  bool _isCameraOn = true;

  /// Whether the local camera is enabled.
  bool get isCameraOn => _isCameraOn;

  bool _isScreenSharing = false;

  /// Whether screen sharing is currently active.
  bool get isScreenSharing => _isScreenSharing;

  ZegoError? _lastError;

  /// The most recent error, if any.
  ZegoError? get lastError => _lastError;

  int _activeSpeakerIndex = 0;

  /// Index of the active speaker within [participants].
  int get activeSpeakerIndex => _activeSpeakerIndex;

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  ZegoEngine? _engine;
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  final Map<String, ZegoRemoteStream> _remoteStreams = {};

  List<ZegoDeviceInfo> _cameras = [];
  List<ZegoDeviceInfo> get cameras => _cameras;

  List<ZegoDeviceInfo> _microphones = [];
  List<ZegoDeviceInfo> get microphones => _microphones;

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  /// Initialize the engine and create a local stream for pre-join preview.
  /// Does NOT join the room — call [join] for that.
  Future<void> startPreview() async {
    if (_engine != null) return; // already initialized
    _setState(ZegoCallState.preJoin);

    try {
      await ZegoWeb.loadScript();
      _engine = await ZegoWeb.createEngine(engineConfig);
      _localStream = await _engine!.createLocalStream();
      _cameras = await _engine!.getCameras();
      _microphones = await _engine!.getMicrophones();
      notifyListeners();
    } catch (e) {
      _lastError = e is ZegoError ? e : ZegoError(-1, e.toString());
      notifyListeners();
    }
  }

  /// Join the call: create engine (if needed), login room, publish local stream.
  Future<void> join() async {
    if (_state != ZegoCallState.idle && _state != ZegoCallState.preJoin) return;
    _setState(ZegoCallState.joining);

    try {
      if (_engine == null) {
        await ZegoWeb.loadScript();
        _engine = await ZegoWeb.createEngine(engineConfig);
      }

      _subscriptions.addAll([
        _engine!.onRoomStreamUpdate.listen(_onRoomStreamUpdate),
        _engine!.onRoomUserUpdate.listen(_onRoomUserUpdate),
        _engine!.onError.listen(_onError),
      ]);

      await _engine!.loginRoom(
        callConfig.roomId,
        ZegoUser(
          userId: callConfig.userId,
          userName: callConfig.userName ?? callConfig.userId,
        ),
      );

      _localStream ??= await _engine!.createLocalStream();
      final streamId = 'stream-${callConfig.userId}';
      await _engine!.startPublishing(streamId, _localStream!);

      // Add local participant.
      _participants.insert(
        0,
        ZegoParticipant(
          userId: callConfig.userId,
          userName: callConfig.userName,
          stream: _localStream,
          isLocal: true,
        ),
      );

      _setState(ZegoCallState.inCall);
    } on ZegoError catch (e) {
      _lastError = e;
      _setState(ZegoCallState.idle);
      notifyListeners();
      rethrow;
    } catch (e) {
      _lastError = ZegoError(-1, e.toString());
      _setState(ZegoCallState.idle);
      notifyListeners();
      rethrow;
    }
  }

  /// Leave the call and tear down the engine.
  Future<void> leave() async {
    if (_state == ZegoCallState.idle || _state == ZegoCallState.leaving) return;
    _setState(ZegoCallState.leaving);

    try {
      for (final sub in _subscriptions) {
        await sub.cancel();
      }
      _subscriptions.clear();

      await _engine?.destroy();
      _engine = null;
    } catch (_) {
      // Best-effort teardown.
    }

    _localStream = null;
    _participants.clear();
    _remoteStreams.clear();
    _activeSpeakerIndex = 0;
    _setState(ZegoCallState.idle);
  }

  /// Toggle the microphone.
  void toggleMic() {
    if (_engine == null || _localStream == null) return;
    _isMicOn = !_isMicOn;
    _engine!.muteMicrophone(!_isMicOn);
    _updateLocalParticipant();
    notifyListeners();
  }

  /// Toggle the camera.
  void toggleCamera() {
    if (_engine == null || _localStream == null) return;
    _isCameraOn = !_isCameraOn;
    _engine!.enableCamera(_isCameraOn);
    _updateLocalParticipant();
    notifyListeners();
  }

  /// Switch to a specific layout mode.
  void switchLayout(ZegoLayoutMode mode) {
    if (_currentLayout == mode) return;
    _currentLayout = mode;
    notifyListeners();
  }

  /// Switch camera device.
  Future<void> switchCamera(String deviceId) async {
    await _engine?.useCamera(deviceId);
  }

  /// Switch microphone device.
  Future<void> switchMicrophone(String deviceId) async {
    await _engine?.useMicrophone(deviceId);
  }

  /// Start screen sharing (placeholder — requires createStream with screen
  /// config).
  Future<void> startScreenShare() async {
    _isScreenSharing = true;
    notifyListeners();
  }

  /// Stop screen sharing.
  Future<void> stopScreenShare() async {
    _isScreenSharing = false;
    notifyListeners();
  }

  /// Get available cameras.
  Future<List<ZegoDeviceInfo>> getCameras() async {
    return await _engine?.getCameras() ?? [];
  }

  /// Get available microphones.
  Future<List<ZegoDeviceInfo>> getMicrophones() async {
    return await _engine?.getMicrophones() ?? [];
  }

  // ---------------------------------------------------------------------------
  // Event handlers
  // ---------------------------------------------------------------------------

  Future<void> _onRoomStreamUpdate(ZegoRoomStreamUpdate update) async {
    if (update.type == ZegoUpdateType.add) {
      for (final streamInfo in update.streams) {
        try {
          final remote = await _engine!.startPlaying(streamInfo.streamId);
          _remoteStreams[streamInfo.streamId] = remote;
          _participants.add(ZegoParticipant(
            userId: streamInfo.user.userId,
            userName: streamInfo.user.userName,
            stream: remote,
          ));
        } catch (_) {}
      }
    } else {
      for (final streamInfo in update.streams) {
        try {
          await _engine!.stopPlaying(streamInfo.streamId);
        } catch (_) {}
        _remoteStreams.remove(streamInfo.streamId);
        _participants.removeWhere(
          (p) => p.userId == streamInfo.user.userId && !p.isLocal,
        );
      }
    }
    notifyListeners();
  }

  void _onRoomUserUpdate(ZegoRoomUserUpdate update) {
    // User join/leave is already handled via stream updates.
    // This could be used to track users without streams.
    notifyListeners();
  }

  void _onError(ZegoError error) {
    _lastError = error;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  void _setState(ZegoCallState newState) {
    if (_state == newState) return;
    _state = newState;
    notifyListeners();
  }

  void _updateLocalParticipant() {
    final idx = _participants.indexWhere((p) => p.isLocal);
    if (idx >= 0) {
      _participants[idx] = _participants[idx].copyWith(
        isMuted: !_isMicOn,
        isCameraOff: !_isCameraOn,
      );
    }
  }

  @override
  void dispose() {
    if (_state != ZegoCallState.idle) {
      leave();
    }
    super.dispose();
  }
}
