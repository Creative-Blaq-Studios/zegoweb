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

  /// Whether to show the mic status indicator inside the name chip.
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ZegoCallTheme theme, ColorScheme colorScheme) {
    final hasStream = participant.stream != null && videoViewBuilder != null;
    final showVideo = hasStream && !participant.isCameraOff;

    // When camera is off, show the initials placeholder. If a stream still
    // exists (mic-only), render a hidden video view underneath so the
    // <video> HTML element stays mounted and audio keeps playing.
    if (!showVideo) {
      final placeholder = Center(
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
      if (hasStream && !participant.isLocal) {
        // Keep the video view alive (zero-size) for audio playback.
        return Stack(
          fit: StackFit.expand,
          children: [
            Offstage(child: videoViewBuilder!(participant.stream!, mirror)),
            placeholder,
          ],
        );
      }
      return placeholder;
    }

    return videoViewBuilder!(participant.stream!, mirror);
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showMicIndicator) ...[
              Icon(
                participant.isMuted ? Icons.mic_off : Icons.mic,
                size: 14,
                color: participant.isMuted
                    ? const Color(0xFFEA4335)
                    : const Color(0xFF4CAF50),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              participant.userName ?? participant.userId,
              style: theme.nameTextStyle ??
                  const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
