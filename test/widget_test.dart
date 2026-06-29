import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seiza_kore/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: SeizaKoreApp()),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('星座コレ！'), findsWidgets);
  });
}
