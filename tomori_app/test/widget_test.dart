import 'package:flutter_test/flutter_test.dart';
import 'package:tomori_app/app/tomori_app.dart';

void main() {
  testWidgets('shows TOMORI home greeting', (WidgetTester tester) async {
    await tester.pumpWidget(const TomoriApp());
    await tester.pumpAndSettle();

    expect(find.text('おはようございます！'), findsOneWidget);
    expect(find.text('ホーム'), findsOneWidget);
  });
}
