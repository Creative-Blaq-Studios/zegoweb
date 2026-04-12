import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb_ui/src/widgets/zego_pre_join_view.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: child,
    ),
  );
}

void main() {
  group('ZegoPreJoinView', () {
    testWidgets('shows Join button', (tester) async {
      await tester.pumpWidget(_wrap(
        ZegoPreJoinView(
          userName: 'Alice',
          onJoin: () {},
        ),
      ));

      expect(find.widgetWithText(FilledButton, 'Join'), findsOneWidget);
    });

    testWidgets('shows user name', (tester) async {
      await tester.pumpWidget(_wrap(
        ZegoPreJoinView(
          userName: 'Bob Smith',
          onJoin: () {},
        ),
      ));

      expect(find.text('Bob Smith'), findsOneWidget);
    });

    testWidgets('calls onJoin callback', (tester) async {
      var joinCalled = false;

      await tester.pumpWidget(_wrap(
        ZegoPreJoinView(
          userName: 'Alice',
          onJoin: () => joinCalled = true,
        ),
      ));

      await tester.tap(find.widgetWithText(FilledButton, 'Join'));
      expect(joinCalled, isTrue);
    });

    testWidgets('shows loading indicator when isLoading is true',
        (tester) async {
      await tester.pumpWidget(_wrap(
        ZegoPreJoinView(
          userName: 'Alice',
          onJoin: () {},
          isLoading: true,
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows previewWidget when provided', (tester) async {
      await tester.pumpWidget(_wrap(
        ZegoPreJoinView(
          userName: 'Alice',
          onJoin: () {},
          previewWidget: const Placeholder(key: Key('preview')),
        ),
      ));

      expect(find.byKey(const Key('preview')), findsOneWidget);
    });
  });
}
