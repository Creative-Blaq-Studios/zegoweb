import 'package:flutter_test/flutter_test.dart';

import 'package:zegoweb_ui_example/main.dart';

void main() {
  testWidgets('App renders setup screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ZegoUiExampleApp());

    expect(find.text('zegoweb_ui Demo'), findsOneWidget);
    expect(find.text('Start Call'), findsOneWidget);
  });
}
