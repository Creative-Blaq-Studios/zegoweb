import 'package:flutter/material.dart';
import 'package:zegoweb_ui/src/widgets/zego_participant_tile.dart';
import 'package:zegoweb_ui/src/zego_participant.dart';

/// A layout with one large speaker tile and a horizontal filmstrip of
/// thumbnail tiles at the bottom.
///
/// The [activeSpeakerIndex] participant (or first if -1) occupies the main
/// area (~80% height). Remaining participants appear in a scrollable row.
class ZegoGalleryLayout extends StatelessWidget {
  const ZegoGalleryLayout({
    super.key,
    required this.participants,
    this.activeSpeakerIndex = -1,
    this.filmstripHeight = 100.0,
    this.spacing = 4.0,
    this.showName = true,
    this.showMicIndicator = true,
    this.videoViewBuilder,
  });

  final List<ZegoParticipant> participants;
  final int activeSpeakerIndex;
  final double filmstripHeight;
  final double spacing;
  final bool showName;
  final bool showMicIndicator;
  final VideoViewBuilder? videoViewBuilder;

  @override
  Widget build(BuildContext context) {
    if (participants.isEmpty) return const SizedBox.shrink();

    final speakerIdx = (activeSpeakerIndex >= 0 && activeSpeakerIndex < participants.length)
        ? activeSpeakerIndex
        : 0;
    final speaker = participants[speakerIdx];
    final others = <ZegoParticipant>[
      for (var i = 0; i < participants.length; i++)
        if (i != speakerIdx) participants[i],
    ];

    if (others.isEmpty) {
      return ZegoParticipantTile(
        participant: speaker,
        showName: showName,
        showMicIndicator: showMicIndicator,
        mirror: speaker.isLocal,
        isActiveSpeaker: true,
        videoViewBuilder: videoViewBuilder,
      );
    }

    return Column(
      children: [
        Expanded(
          child: ZegoParticipantTile(
            participant: speaker,
            showName: showName,
            showMicIndicator: showMicIndicator,
            mirror: speaker.isLocal,
            isActiveSpeaker: true,
            videoViewBuilder: videoViewBuilder,
          ),
        ),
        SizedBox(height: spacing),
        SizedBox(
          height: filmstripHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: others.length,
            separatorBuilder: (_, __) => SizedBox(width: spacing),
            itemBuilder: (_, index) {
              final p = others[index];
              return AspectRatio(
                aspectRatio: 4 / 3,
                child: ZegoParticipantTile(
                  participant: p,
                  showName: showName,
                  showMicIndicator: showMicIndicator,
                  mirror: p.isLocal,
                  videoViewBuilder: videoViewBuilder,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
