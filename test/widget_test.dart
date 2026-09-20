import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seiza_kore/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: SeizaKoreApp()),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // ロケール（日本語 / 英語）によって表示が変わるため、いずれかが見つかればよい。
    final foundJa = find.text('ほしぞら大百科').evaluate().isNotEmpty;
    final foundEn = find.text('Night Sky Encyclopedia').evaluate().isNotEmpty;
    expect(foundJa || foundEn, isTrue);
  });
}
