import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lucro_dia/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('fluxo venda, compra e resumo', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('Lucro do Dia'), findsOneWidget);

    await tester.tap(find.text('Venda'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '500,00');
    await tester.enterText(find.byType(TextFormField).last, 'venda teste');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.textContaining('R\$'), findsWidgets);
    expect(find.textContaining('lucrando'), findsOneWidget);

    await tester.tap(find.text('Compra'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '200,00');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('300,00'), findsWidgets);

    await tester.tap(find.byIcon(Icons.list_alt));
    await tester.pumpAndSettle();
    expect(find.text('venda teste'), findsOneWidget);
  });
}
