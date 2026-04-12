import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb_ui/src/layouts/zego_sidebar_layout.dart';
import 'package:zegoweb_ui/src/zego_participant.dart';
import 'package:zegoweb_ui/src/widgets/zego_participant_tile.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(width: 800, height: 400, child: child),
    ),
  );
}

List<ZegoParticipant> _participants(int count) {
  return List.generate(
    count,
    (i) => ZegoParticipant(
      userId: 'u$i',
      userName: 'User $i',
      isCameraOff: true,
    ),
  );
}

void main() {
  group('ZegoSidebarLayout', () {
    testWidgets('renders tiles for all participants', (tester) async {
      final participants = _participants(4);
      await tester.pumpWidget(_wrap(
        ZegoSidebarLayout(
          participants: participants,
          activeSpeakerIndex: 0,
        ),
      ));

      expect(find.byType(ZegoParticipantTile), findsNWidgets(4));
    });

    testWidgets('renders with single participant', (tester) async {
      final participants = _participants(1);
      await tester.pumpWidget(_wrap(
        ZegoSidebarLayout(
          participants: participants,
          activeSpeakerIndex: 0,
        ),
      ));

      expect(find.byType(ZegoParticipantTile), findsOneWidget);
    });

    testWidgets('renders speaker tile and sidebar tiles', (tester) async {
      final participants = _participants(3);
      await tester.pumpWidget(_wrap(
        ZegoSidebarLayout(
          participants: participants,
          activeSpeakerIndex: 1,
        ),
      ));

      // Should have speaker (1) + sidebar (2) = 3 tiles
      expect(find.byType(ZegoParticipantTile), findsNWidgets(3));
    });

    testWidgets('renders empty for zero participants', (tester) async {
      await tester.pumpWidget(_wrap(
        const ZegoSidebarLayout(
          participants: [],
          activeSpeakerIndex: 0,
        ),
      ));

      expect(find.byType(ZegoParticipantTile), findsNothing);
    });
  });
}
