import 'package:flutter/material.dart';
import 'package:zegoweb_ui/src/zego_call_theme.dart';
import 'package:zegoweb_ui/src/zego_participant.dart';

/// Signature for a builder that creates a video view widget from a stream.
typedef VideoViewBuilder = Widget Function(Object stream, bool mirror);

/// A single tile that renders a participant's video feed or a camera-off
/// placeholder with initials, along with optional name and mic overlays.
///
/// When [participant.stream] is not `null` and [participant.isCameraOff] is
/// `false`, the tile delegates to [videoViewBuilder] to render the video.
/// If no builder is provided, a generic placeholder is shown instead.
///
/// Uses [ZegoCallTheme.resolve] for theming (tile background, border radius,
/// name text style, mic indicator color).
class ZegoParticipantTile extends StatelessWidget {
  const ZegoParticipantTile({
    super.key,
    required this.participant,
    this.showName = true,
    this.showMicIndicator = true,
    this.mirror = false,
    this.isActiveSpeaker = false,
    this.videoViewBuilder,
  });

  /// The participant data to display.
  final ZegoParticipant participant;

  /// Whether to show the name label overlay at the bottom-left.
  final bool showName;

  /// Whether to show the mic status indicator at the top-right.
  final bool showMicIndicator;

  /// Whether to mirror the video (typically true for local participants).
  final bool mirror;

  /// Whether this participant is the active speaker (shows a primary border).
  final bool isActiveSpeaker;

  /// Optional builder that creates a video view widget from a stream object.
  ///
  /// When running on web, this should be set to create a [ZegoVideoView].
  /// When `null` and a stream is available, a fallback placeholder is shown.
  final VideoViewBuilder? videoViewBuilder;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final themeExt = Theme.of(context).extension<ZegoCallTheme>();
    final theme = ZegoCallTheme.resolve(themeExt, colorScheme, textTheme);

    final borderRadius = BorderRadius.circular(theme.tileBorderRadius ?? 12.0);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: isActiveSpeaker
            ? Border.all(color: colorScheme.primary, width: 2.5)
            : null,
      ),
      child: ClipRRect(
        borderRadius: isActiveSpeaker
            ? borderRadius - const BorderRadius.all(Radius.circular(2.5))
            : borderRadius,
        child: Container(
          color: theme.tileBackgroundColor,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildContent(theme, colorScheme),
              if (showName) _buildNameOverlay(theme),
              if (showMicIndicator) _buildMicIndicator(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ZegoCallTheme theme, ColorScheme colorScheme) {
    final hasVideo = participant.stream != null && !participant.isCameraOff;

    if (hasVideo) {
      if (videoViewBuilder != null) {
        return videoViewBuilder!(participant.stream!, mirror);
      }
      // Fallback when no builder is provided but a stream exists.
      return Container(
        color: Colors.black,
        child: const Center(
          child: Icon(Icons.videocam, color: Colors.white38, size: 48),
        ),
      );
    }

    // Camera-off placeholder with initials.
    return Center(
      child: CircleAvatar(
        radius: 32,
        backgroundColor: colorScheme.primaryContainer,
        child: Text(
          participant.initials,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }

  Widget _buildNameOverlay(ZegoCallTheme theme) {
    return Positioned(
      left: 8,
      bottom: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xCC000000),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          participant.userName ?? participant.userId,
          style: theme.nameTextStyle ??
              const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildMicIndicator(ZegoCallTheme theme) {
    return Positioned(
      right: 8,
      top: 8,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          participant.isMuted ? Icons.mic_off : Icons.mic,
          size: 16,
          color: theme.micIndicatorColor ?? Colors.white,
        ),
      ),
    );
  }
}
