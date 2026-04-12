import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb_ui/src/layouts/zego_grid_layout.dart';
import 'package:zegoweb_ui/src/zego_participant.dart';
import 'package:zegoweb_ui/src/widgets/zego_participant_tile.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(width: 400, height: 400, child: child),
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
  group('ZegoGridLayout', () {
    testWidgets('renders 4 participant tiles', (tester) async {
      await tester.pumpWidget(_wrap(
        ZegoGridLayout(participants: _participants(4)),
      ));

      expect(find.byType(ZegoParticipantTile), findsNWidgets(4));
    });

    testWidgets('renders 5 participant tiles', (tester) async {
      await tester.pumpWidget(_wrap(
        ZegoGridLayout(participants: _participants(5)),
      ));

      expect(find.byType(ZegoParticipantTile), findsNWidgets(5));
    });

    testWidgets('renders 7 participant tiles', (tester) async {
      await tester.pumpWidget(_wrap(
        ZegoGridLayout(participants: _participants(7)),
      ));

      expect(find.byType(ZegoParticipantTile), findsNWidgets(7));
    });

    testWidgets('renders empty for 0 participants', (tester) async {
      await tester.pumpWidget(_wrap(
        const ZegoGridLayout(participants: []),
      ));

      expect(find.byType(ZegoParticipantTile), findsNothing);
    });
  });
}
