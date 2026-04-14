import 'package:flutter/material.dart';
import 'package:zegoweb_ui/src/widgets/zego_participant_tile.dart';
import 'package:zegoweb_ui/src/zego_participant.dart';

/// A sidebar layout with a large speaker tile on the left and a vertical
/// column of smaller tiles on the right.
///
/// The speaker area takes flex 3 and the sidebar takes flex 1. The
/// [activeSpeakerIndex] determines which participant is shown as the
/// main speaker; the remaining participants appear in the sidebar column.
class ZegoSidebarLayout extends StatelessWidget {
  const ZegoSidebarLayout({
    super.key,
    required this.participants,
    this.activeSpeakerIndex = 0,
    this.spacing = 4.0,
    this.showName = true,
    this.showMicIndicator = true,
    this.videoViewBuilder,
    this.pinnedUserId,
    this.onPinToggle,
  });

  /// All participants in the call.
  final List<ZegoParticipant> participants;

  /// Index of the active speaker within [participants].
  final int activeSpeakerIndex;

  /// Spacing between tiles. Defaults to 4.0.
  final double spacing;

  /// Whether to show participant names on tiles.
  final bool showName;

  /// Whether to show mic indicators on tiles.
  final bool showMicIndicator;

  /// Optional builder for creating video view widgets from stream objects.
  final VideoViewBuilder? videoViewBuilder;

  /// The userId of the currently pinned participant, if any.
  final String? pinnedUserId;

  /// Called when a participant tile is long-pressed to toggle pin.
  final void Function(String userId)? onPinToggle;

  @override
  Widget build(BuildContext context) {
    if (participants.isEmpty) {
      return const SizedBox.shrink();
    }

    // Single participant — just show them full-size.
    if (participants.length == 1) {
      return ZegoParticipantTile(
        participant: participants.first,
        showName: showName,
        showMicIndicator: showMicIndicator,
        mirror: participants.first.isLocal,
        videoViewBuilder: videoViewBuilder,
        isPinned: participants.first.userId == pinnedUserId,
        onLongPress: onPinToggle != null
            ? () => onPinToggle!(participants.first.userId)
            : null,
      );
    }

    final clampedIndex = activeSpeakerIndex < 0
        ? 0
        : activeSpeakerIndex.clamp(0, participants.length - 1);
    final speaker = participants[clampedIndex];
    final sidebarParticipants = [
      ...participants.sublist(0, clampedIndex),
      ...participants.sublist(clampedIndex + 1),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Speaker area (flex: 3)
        Expanded(
          flex: 3,
          child: ZegoParticipantTile(
            participant: speaker,
            showName: showName,
            showMicIndicator: showMicIndicator,
            mirror: speaker.isLocal,
            videoViewBuilder: videoViewBuilder,
            isPinned: speaker.userId == pinnedUserId,
            onLongPress: onPinToggle != null
                ? () => onPinToggle!(speaker.userId)
                : null,
          ),
        ),
        SizedBox(width: spacing),
        // Sidebar column (flex: 1)
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _buildSidebarTiles(sidebarParticipants),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSidebarTiles(List<ZegoParticipant> sidebarParticipants) {
    final tiles = <Widget>[];
    for (int i = 0; i < sidebarParticipants.length; i++) {
      final participant = sidebarParticipants[i];
      tiles.add(
        Expanded(
          child: ZegoParticipantTile(
            participant: participant,
            showName: showName,
            showMicIndicator: showMicIndicator,
            mirror: participant.isLocal,
            videoViewBuilder: videoViewBuilder,
            isPinned: participant.userId == pinnedUserId,
            onLongPress: onPinToggle != null
                ? () => onPinToggle!(participant.userId)
                : null,
          ),
        ),
      );
      if (i < sidebarParticipants.length - 1) {
        tiles.add(SizedBox(height: spacing));
      }
    }
    return tiles;
  }
}
