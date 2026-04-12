import 'package:flutter_test/flutter_test.dart';

import 'package:zegoweb_prebuilt_example/main.dart';

void main() {
  testWidgets('Example app renders', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('zegoweb_prebuilt example'), findsOneWidget);
  });
}
