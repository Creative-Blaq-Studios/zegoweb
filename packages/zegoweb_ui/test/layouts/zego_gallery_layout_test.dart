import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb_ui/src/layouts/zego_gallery_layout.dart';
import 'package:zegoweb_ui/src/zego_participant.dart';
import 'package:zegoweb_ui/src/widgets/zego_participant_tile.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(width: 800, height: 600, child: child),
    ),
  );
}

void main() {
  group('ZegoGalleryLayout', () {
    testWidgets('renders main tile and filmstrip for 4 participants', (tester) async {
      final participants = List.generate(
        4,
        (i) => ZegoParticipant(userId: 'u$i', userName: 'User $i'),
      );
      await tester.pumpWidget(_wrap(ZegoGalleryLayout(
        participants: participants,
        activeSpeakerIndex: 0,
      )));
      // 1 main tile + 3 filmstrip tiles = 4 total
      expect(find.byType(ZegoParticipantTile), findsNWidgets(4));
    });

    testWidgets('renders single tile when only 1 participant', (tester) async {
      const participants = [
        ZegoParticipant(userId: 'u0', userName: 'Solo'),
      ];
      await tester.pumpWidget(_wrap(const ZegoGalleryLayout(
        participants: participants,
        activeSpeakerIndex: 0,
      )));
      expect(find.byType(ZegoParticipantTile), findsOneWidget);
    });

    testWidgets('renders empty for no participants', (tester) async {
      await tester.pumpWidget(_wrap(const ZegoGalleryLayout(
        participants: [],
      )));
      expect(find.byType(ZegoParticipantTile), findsNothing);
    });
  });
}
