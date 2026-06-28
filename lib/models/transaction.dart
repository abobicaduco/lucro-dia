enum TransactionType { sale, purchase }

class Transaction {
  Transaction({
    this.id,
    required this.type,
    required this.amountCents,
    required this.date,
    this.description = '',
  });

  final int? id;
  final TransactionType type;
  final int amountCents;
  final DateTime date;
  final String description;

  bool get isSale => type == TransactionType.sale;

  Map<String, Object?> toMap() => {
        'id': id,
        'type': type.name,
        'amount_cents': amountCents,
        'date': date.toIso8601String(),
        'description': description,
      };

  factory Transaction.fromMap(Map<String, Object?> map) => Transaction(
        id: map['id'] as int?,
        type: TransactionType.values.byName(map['type'] as String),
        amountCents: (map['amount_cents'] as num).toInt(),
        date: DateTime.parse(map['date'] as String),
        description: (map['description'] as String?) ?? '',
      );

  Transaction copyWith({
    int? id,
    TransactionType? type,
    int? amountCents,
    DateTime? date,
    String? description,
  }) =>
      Transaction(
        id: id ?? this.id,
        type: type ?? this.type,
        amountCents: amountCents ?? this.amountCents,
        date: date ?? this.date,
        description: description ?? this.description,
      );
}

class MonthSummary {
  const MonthSummary({
    required this.salesCents,
    required this.purchasesCents,
    required this.salesUntilTodayCents,
    required this.purchasesUntilTodayCents,
    required this.transactionCount,
  });

  final int salesCents;
  final int purchasesCents;
  final int salesUntilTodayCents;
  final int purchasesUntilTodayCents;
  final int transactionCount;

  int get balanceCents => salesCents - purchasesCents;
  int get balanceUntilTodayCents =>
      salesUntilTodayCents - purchasesUntilTodayCents;

  bool get isProfit => balanceCents >= 0;
  bool get isProfitUntilToday => balanceUntilTodayCents >= 0;
}
