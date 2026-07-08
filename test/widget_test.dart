import 'package:flutter_test/flutter_test.dart';
import 'package:cyber_shield/app.dart';

void main() {
  testWidgets('Cyber Shield app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const CyberShieldApp());

    expect(find.text('Cyber Shield'), findsWidgets);
  });
}