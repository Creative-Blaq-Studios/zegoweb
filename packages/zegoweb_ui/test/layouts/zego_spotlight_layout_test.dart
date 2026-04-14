import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb_ui/src/layouts/zego_spotlight_layout.dart';
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
  group('ZegoSpotlightLayout', () {
    testWidgets('renders single tile for active speaker', (tester) async {
      final participants = List.generate(
        4,
        (i) => ZegoParticipant(userId: 'u$i', userName: 'User $i'),
      );
      await tester.pumpWidget(_wrap(ZegoSpotlightLayout(
        participants: participants,
        activeSpeakerIndex: 2,
      )));
      expect(find.byType(ZegoParticipantTile), findsOneWidget);
      expect(find.text('User 2'), findsOneWidget);
    });

    testWidgets('renders first participant when no active speaker', (tester) async {
      final participants = [
        const ZegoParticipant(userId: 'u0', userName: 'First'),
        const ZegoParticipant(userId: 'u1', userName: 'Second'),
      ];
      await tester.pumpWidget(_wrap(ZegoSpotlightLayout(
        participants: participants,
        activeSpeakerIndex: -1,
      )));
      expect(find.byType(ZegoParticipantTile), findsOneWidget);
      expect(find.text('First'), findsOneWidget);
    });

    testWidgets('renders empty for no participants', (tester) async {
      await tester.pumpWidget(_wrap(const ZegoSpotlightLayout(
        participants: [],
      )));
      expect(find.byType(ZegoParticipantTile), findsNothing);
    });
  });
}
