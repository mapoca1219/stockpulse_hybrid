import 'package:flutter_test/flutter_test.dart';
import 'package:stockpulse_hybrid/main.dart';

void main() {
  testWidgets('StockPulse Hybrid smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const StockPulseApp());
    expect(find.text('STOCKPULSE'), findsOneWidget);
  });
}
