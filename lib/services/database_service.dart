import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' hide Transaction;

import '../models/transaction.dart';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'lucro_dia_local.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT NOT NULL,
            amount_cents INTEGER NOT NULL,
            date TEXT NOT NULL,
            description TEXT NOT NULL DEFAULT ''
          )
        ''');
        await db.execute(
          'CREATE INDEX idx_transactions_date ON transactions(date)',
        );
      },
    );
  }

  Future<int> insert(Transaction tx) async {
    final db = await database;
    return db.insert('transactions', tx.toMap()..remove('id'));
  }

  Future<int> update(Transaction tx) async {
    final db = await database;
    return db.update(
      'transactions',
      tx.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [tx.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await database;
    return db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Transaction>> listForMonth(DateTime month) async {
    final db = await database;
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1);
    final rows = await db.query(
      'transactions',
      where: 'date >= ? AND date < ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC, id DESC',
    );
    return rows.map(Transaction.fromMap).toList();
  }

  Future<MonthSummary> summaryForMonth(DateTime month) async {
    final txs = await listForMonth(month);
    final now = DateTime.now();
    final isCurrentMonth =
        month.year == now.year && month.month == now.month;
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    var sales = 0;
    var purchases = 0;
    var salesToday = 0;
    var purchasesToday = 0;

    for (final tx in txs) {
      if (tx.isSale) {
        sales += tx.amountCents;
        if (isCurrentMonth && !tx.date.isAfter(todayEnd)) {
          salesToday += tx.amountCents;
        }
      } else {
        purchases += tx.amountCents;
        if (isCurrentMonth && !tx.date.isAfter(todayEnd)) {
          purchasesToday += tx.amountCents;
        }
      }
    }

    if (!isCurrentMonth) {
      salesToday = sales;
      purchasesToday = purchases;
    }

    return MonthSummary(
      salesCents: sales,
      purchasesCents: purchases,
      salesUntilTodayCents: salesToday,
      purchasesUntilTodayCents: purchasesToday,
      transactionCount: txs.length,
    );
  }
}
