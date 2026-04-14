import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb_ui/src/zego_participant.dart';
import 'package:zegoweb_ui/src/widgets/zego_participant_tile.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(width: 300, height: 200, child: child),
    ),
  );
}

void main() {
  group('ZegoParticipantTile', () {
    testWidgets('shows participant name', (tester) async {
      const participant = ZegoParticipant(
        userId: 'u1',
        userName: 'Alice Smith',
        isCameraOff: true,
      );

      await tester.pumpWidget(_wrap(
        const ZegoParticipantTile(
          participant: participant,
          showName: true,
          showMicIndicator: true,
        ),
      ));

      expect(find.text('Alice Smith'), findsOneWidget);
    });

    testWidgets('shows initials when camera is off', (tester) async {
      const participant = ZegoParticipant(
        userId: 'u1',
        userName: 'Alice Smith',
        isCameraOff: true,
      );

      await tester.pumpWidget(_wrap(
        const ZegoParticipantTile(
          participant: participant,
          showName: true,
          showMicIndicator: true,
        ),
      ));

      expect(find.text('AS'), findsOneWidget);
    });

    testWidgets('shows mic_off icon in name chip when muted', (tester) async {
      const participant = ZegoParticipant(
        userId: 'u1',
        userName: 'Alice',
        isCameraOff: true,
        isMuted: true,
      );

      await tester.pumpWidget(_wrap(
        const ZegoParticipantTile(
          participant: participant,
          showName: true,
          showMicIndicator: true,
        ),
      ));

      expect(find.byIcon(Icons.mic_off), findsOneWidget);
      expect(find.byIcon(Icons.mic), findsNothing);
    });

    testWidgets('shows mic icon in name chip when not muted', (tester) async {
      const participant = ZegoParticipant(
        userId: 'u1',
        userName: 'Alice',
        isCameraOff: true,
        isMuted: false,
      );

      await tester.pumpWidget(_wrap(
        const ZegoParticipantTile(
          participant: participant,
          showName: true,
          showMicIndicator: true,
        ),
      ));

      expect(find.byIcon(Icons.mic), findsOneWidget);
      expect(find.byIcon(Icons.mic_off), findsNothing);
    });

    testWidgets('hides name when showName is false', (tester) async {
      const participant = ZegoParticipant(
        userId: 'u1',
        userName: 'Alice Smith',
        isCameraOff: true,
      );

      await tester.pumpWidget(_wrap(
        const ZegoParticipantTile(
          participant: participant,
          showName: false,
          showMicIndicator: true,
        ),
      ));

      expect(find.text('Alice Smith'), findsNothing);
    });

    testWidgets('hides mic indicator when showMicIndicator is false',
        (tester) async {
      const participant = ZegoParticipant(
        userId: 'u1',
        userName: 'Alice',
        isCameraOff: true,
        isMuted: true,
      );

      await tester.pumpWidget(_wrap(
        const ZegoParticipantTile(
          participant: participant,
          showName: true,
          showMicIndicator: false,
        ),
      ));

      expect(find.byIcon(Icons.mic_off), findsNothing);
      expect(find.byIcon(Icons.mic), findsNothing);
    });
  });
}
