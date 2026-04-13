import 'package:flutter/material.dart';
import 'package:zegoweb/zegoweb.dart';

import 'package:zegoweb_ui/src/layouts/zego_grid_layout.dart';
import 'package:zegoweb_ui/src/layouts/zego_pip_layout.dart';
import 'package:zegoweb_ui/src/layouts/zego_sidebar_layout.dart';
import 'package:zegoweb_ui/src/widgets/zego_controls_bar.dart';
import 'package:zegoweb_ui/src/widgets/zego_pre_join_view.dart';
import 'package:zegoweb_ui/src/zego_call_config.dart';
import 'package:zegoweb_ui/src/zego_call_controller.dart';
import 'package:zegoweb_ui/src/zego_call_state.dart';
import 'package:zegoweb_ui/src/zego_call_theme.dart';
import 'package:zegoweb_ui/src/zego_layout_mode.dart';

/// High-level drop-in widget that handles the entire call lifecycle.
///
/// Push as a full route for the simplest integration:
/// ```dart
/// Navigator.push(context, MaterialPageRoute(
///   builder: (_) => ZegoCallScreen(
///     engineConfig: myEngineConfig,
///     callConfig: ZegoCallConfig(roomId: 'r1', userId: 'u1'),
///   ),
/// ));
/// ```
class ZegoCallScreen extends StatefulWidget {
  const ZegoCallScreen({
    super.key,
    required this.engineConfig,
    required this.callConfig,
    this.onCallEnded,
    this.onError,
  });

  /// Engine configuration forwarded to [ZegoCallController].
  final ZegoEngineConfig engineConfig;

  /// Call configuration forwarded to [ZegoCallController].
  final ZegoCallConfig callConfig;

  /// Called after the call has ended and the engine is torn down.
  final VoidCallback? onCallEnded;

  /// Called when an error occurs during the call lifecycle.
  final void Function(ZegoError error)? onError;

  @override
  State<ZegoCallScreen> createState() => _ZegoCallScreenState();
}

class _ZegoCallScreenState extends State<ZegoCallScreen> {
  late final ZegoCallController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ZegoCallController(
      engineConfig: widget.engineConfig,
      callConfig: widget.callConfig,
    );
    _controller.addListener(_onControllerChanged);

    if (widget.callConfig.showPreJoinView) {
      _controller.startPreview();
    } else {
      _controller.join().catchError((_) {});
    }
  }

  void _onControllerChanged() {
    if (!mounted) return;

    if (_controller.state == ZegoCallState.idle &&
        _controller.lastError != null) {
      widget.onError?.call(_controller.lastError!);
    }

    setState(() {});
  }

  Future<void> _handleJoin() async {
    try {
      await _controller.join();
    } on ZegoError catch (e) {
      widget.onError?.call(e);
    } catch (e) {
      widget.onError?.call(ZegoError(-1, e.toString()));
    }
  }

  Future<void> _handleHangUp() async {
    await _controller.leave();
    widget.onCallEnded?.call();
  }

  void _handleLayoutSwitch() {
    final modes = ZegoLayoutMode.values;
    final nextIndex =
        (modes.indexOf(_controller.currentLayout) + 1) % modes.length;
    _controller.switchLayout(modes[nextIndex]);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ZegoCallTheme.resolve(
      Theme.of(context).extension<ZegoCallTheme>(),
      Theme.of(context).colorScheme,
      Theme.of(context).textTheme,
    );

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_controller.state) {
      case ZegoCallState.idle:
      case ZegoCallState.preJoin:
        if (widget.callConfig.showPreJoinView) {
          return ZegoPreJoinView(
            userName: widget.callConfig.userName ?? widget.callConfig.userId,
            onJoin: _handleJoin,
            previewWidget: _controller.localStream != null
                ? ZegoVideoView(
                    stream: _controller.localStream!,
                    mirror: true,
                  )
                : null,
          );
        }
        return const Center(child: CircularProgressIndicator());

      case ZegoCallState.joining:
        return const Center(child: CircularProgressIndicator());

      case ZegoCallState.inCall:
        return Column(
          children: [
            Expanded(child: _buildLayout()),
            ZegoControlsBar(
              config: widget.callConfig,
              isMicOn: _controller.isMicOn,
              isCameraOn: _controller.isCameraOn,
              isScreenSharing: _controller.isScreenSharing,
              onToggleMic: _controller.toggleMic,
              onToggleCamera: _controller.toggleCamera,
              onToggleScreenShare: _controller.isScreenSharing
                  ? _controller.stopScreenShare
                  : _controller.startScreenShare,
              onDevicePicker: () {}, // TODO: wire device picker dialog
              onLayoutSwitcher: _handleLayoutSwitch,
              onHangUp: _handleHangUp,
            ),
          ],
        );

      case ZegoCallState.leaving:
        return const Center(child: CircularProgressIndicator());
    }
  }

  Widget _videoViewBuilder(Object stream, bool mirror) {
    return ZegoVideoView(stream: stream, mirror: mirror);
  }

  Widget _buildLayout() {
    final participants = _controller.participants;

    switch (_controller.currentLayout) {
      case ZegoLayoutMode.grid:
        return ZegoGridLayout(
          participants: participants,
          videoViewBuilder: _videoViewBuilder,
        );

      case ZegoLayoutMode.sidebar:
        return ZegoSidebarLayout(
          participants: participants,
          activeSpeakerIndex: _controller.activeSpeakerIndex,
          videoViewBuilder: _videoViewBuilder,
        );

      case ZegoLayoutMode.pip:
        if (participants.length < 2) {
          return ZegoGridLayout(
            participants: participants,
            videoViewBuilder: _videoViewBuilder,
          );
        }
        final local = participants.firstWhere(
          (p) => p.isLocal,
          orElse: () => participants.last,
        );
        final remote = participants.firstWhere(
          (p) => !p.isLocal,
          orElse: () => participants.first,
        );
        return ZegoPipLayout(
          fullScreenParticipant: remote,
          floatingParticipant: local,
          videoViewBuilder: _videoViewBuilder,
        );
    }
  }
}
