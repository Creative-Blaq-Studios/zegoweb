import 'package:flutter/material.dart';
import 'package:zegoweb_ui/src/widgets/zego_participant_tile.dart';
import 'package:zegoweb_ui/src/zego_participant.dart';

/// A layout that shows only the active speaker full-screen.
///
/// When [activeSpeakerIndex] is -1 or out of range, the first participant
/// is displayed. Returns [SizedBox.shrink] when [participants] is empty.
class ZegoSpotlightLayout extends StatelessWidget {
  const ZegoSpotlightLayout({
    super.key,
    required this.participants,
    this.activeSpeakerIndex = -1,
    this.showName = true,
    this.showMicIndicator = true,
    this.videoViewBuilder,
    this.pinnedUserId,
    this.onPinToggle,
  });

  final List<ZegoParticipant> participants;
  final int activeSpeakerIndex;
  final bool showName;
  final bool showMicIndicator;
  final VideoViewBuilder? videoViewBuilder;

  /// The userId of the currently pinned participant, if any.
  final String? pinnedUserId;

  /// Called when the tile is long-pressed to toggle pin.
  final void Function(String userId)? onPinToggle;

  @override
  Widget build(BuildContext context) {
    if (participants.isEmpty) return const SizedBox.shrink();

    final idx = (activeSpeakerIndex >= 0 && activeSpeakerIndex < participants.length)
        ? activeSpeakerIndex
        : 0;
    final speaker = participants[idx];

    return ZegoParticipantTile(
      participant: speaker,
      showName: showName,
      showMicIndicator: showMicIndicator,
      mirror: speaker.isLocal,
      isActiveSpeaker: true,
      videoViewBuilder: videoViewBuilder,
      isPinned: speaker.userId == pinnedUserId,
      onLongPress: onPinToggle != null
          ? () => onPinToggle!(speaker.userId)
          : null,
    );
  }
}
