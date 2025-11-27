import 'package:flutter_test/flutter_test.dart';
import 'package:attendr/app.dart';

void main() {
  testWidgets('App initializes correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LectureTrackerApp());

    // Verify that the app initializes
    expect(find.byType(LectureTrackerApp), findsOneWidget);
  });
}
