import 'package:flutter_test/flutter_test.dart';
import 'package:pnl_tracker/main.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const PnlTrackerApp());
    expect(find.text('P&L Tracker'), findsOneWidget);
  });
}
