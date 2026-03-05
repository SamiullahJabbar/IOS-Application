// Basic smoke test for Body Scan Pro app
import 'package:flutter_test/flutter_test.dart';
import 'package:body_scan_app/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const BodyScanApp());
    await tester.pumpAndSettle();
    // App should render without crashing
    expect(find.byType(BodyScanApp), findsOneWidget);
  });
}
