import 'package:flutter/material.dart';
import 'package:zegoweb_ui/src/layouts/grid_reflow.dart';
import 'package:zegoweb_ui/src/widgets/zego_participant_tile.dart';
import 'package:zegoweb_ui/src/zego_participant.dart';

/// A grid layout that arranges [ZegoParticipantTile] widgets in rows using
/// [gridReflow] to determine the number of tiles per row.
///
/// Each row is a [Row] with [Expanded] children, and all rows are arranged
/// in a [Column] with [Expanded] children. Local participants have their
/// video mirrored.
class ZegoGridLayout extends StatelessWidget {
  const ZegoGridLayout({
    super.key,
    required this.participants,
    this.activeSpeakerIndex,
    this.spacing = 4.0,
    this.showName = true,
    this.showMicIndicator = true,
    this.videoViewBuilder,
  });

  /// The list of participants to display in the grid.
  final List<ZegoParticipant> participants;

  /// Index of the currently active speaker (gets a primary border).
  final int? activeSpeakerIndex;

  /// Spacing between tiles (both horizontal and vertical). Defaults to 4.0.
  final double spacing;

  /// Whether to show participant names on tiles.
  final bool showName;

  /// Whether to show mic indicators on tiles.
  final bool showMicIndicator;

  /// Optional builder for creating video view widgets from stream objects.
  final VideoViewBuilder? videoViewBuilder;

  @override
  Widget build(BuildContext context) {
    final rowSizes = gridReflow(participants.length);

    if (rowSizes.isEmpty) {
      return const SizedBox.shrink();
    }

    int index = 0;
    final rows = <Widget>[];

    for (final tilesInRow in rowSizes) {
      final tiles = <Widget>[];
      for (int i = 0; i < tilesInRow; i++) {
        final participant = participants[index];
        tiles.add(
          Expanded(
            child: ZegoParticipantTile(
              participant: participant,
              showName: showName,
              showMicIndicator: showMicIndicator,
              mirror: participant.isLocal,
              isActiveSpeaker: activeSpeakerIndex == index,
              videoViewBuilder: videoViewBuilder,
            ),
          ),
        );
        index++;
      }

      rows.add(
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _intersperse(tiles, SizedBox(width: spacing)),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _intersperse(rows, SizedBox(height: spacing)),
    );
  }

  /// Inserts [separator] between each element of [widgets].
  List<Widget> _intersperse(List<Widget> widgets, Widget separator) {
    if (widgets.length <= 1) return widgets;
    final result = <Widget>[];
    for (int i = 0; i < widgets.length; i++) {
      result.add(widgets[i]);
      if (i < widgets.length - 1) {
        result.add(separator);
      }
    }
    return result;
  }
}
