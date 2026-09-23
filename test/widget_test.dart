import 'package:flutter_test/flutter_test.dart';
import 'package:sign_language_app/main.dart';
import 'package:sign_language_app/screens/home_screen.dart';

void main() {
  testWidgets('App smoke test - verifies HomeScreen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
