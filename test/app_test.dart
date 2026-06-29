import 'package:flutter_test/flutter_test.dart';
import 'package:lucro_dia/models/transaction.dart';
import 'package:lucro_dia/utils/currency.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;

import 'package:lucro_dia/services/database_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('parseMoneyToCents handles Brazilian format', () {
    expect(parseMoneyToCents('150,50'), 15050);
    expect(parseMoneyToCents('R\$ 10'), 1000);
  });

  test('MonthSummary balance', () {
    const s = MonthSummary(
      salesCents: 50000,
      purchasesCents: 30000,
      salesUntilTodayCents: 20000,
      purchasesUntilTodayCents: 10000,
      transactionCount: 3,
    );
    expect(s.balanceCents, 20000);
    expect(s.isProfit, isTrue);
  });

  test('database insert and summary', () async {
    final month = DateTime(2026, 6);
    // O banco de teste (ffi) persiste entre execuções; limpa o mês antes.
    for (final t in await DatabaseService.instance.listForMonth(month)) {
      if (t.id != null) await DatabaseService.instance.delete(t.id!);
    }
    await DatabaseService.instance.insert(
      Transaction(
        type: TransactionType.sale,
        amountCents: 10000,
        date: DateTime(2026, 6, 10),
        description: 'teste venda',
      ),
    );
    await DatabaseService.instance.insert(
      Transaction(
        type: TransactionType.purchase,
        amountCents: 4000,
        date: DateTime(2026, 6, 12),
      ),
    );
    final summary =
        await DatabaseService.instance.summaryForMonth(month);
    expect(summary.salesCents, 10000);
    expect(summary.purchasesCents, 4000);
    expect(summary.balanceCents, 6000);
    expect(summary.transactionCount, 2);
  });
}
