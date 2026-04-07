import 'package:flutter_test/flutter_test.dart';
import 'package:bloom_focus/app.dart';

void main() {
  testWidgets('Bloom Focus app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const BloomFocusApp());

    expect(find.text('Plant'), findsOneWidget);
  });
}