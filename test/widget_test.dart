import 'package:flutter_test/flutter_test.dart';
import 'package:color_word/main.dart';

void main() {
  testWidgets('ColorWord app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ColorWordApp());
    expect(find.text('ColorWord'), findsOneWidget);
  });
}
