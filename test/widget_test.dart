import 'package:flutter_test/flutter_test.dart';

import 'package:checkingo/main.dart';

void main() {
  testWidgets('CheckinGo app launches splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CheckinGoApp());
    expect(find.textContaining('Checkin'), findsOneWidget);
  });
}
