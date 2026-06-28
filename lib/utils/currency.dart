import 'package:intl/intl.dart';

final _brl = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

String formatCents(int cents) => _brl.format(cents / 100);

int parseMoneyToCents(String input) {
  final cleaned = input
      .replaceAll(RegExp(r'[^\d,.-]'), '')
      .replaceAll('.', '')
      .replaceAll(',', '.');
  final value = double.tryParse(cleaned) ?? 0;
  return (value * 100).round();
}

String centsToInput(int cents) {
  if (cents == 0) return '';
  return (cents / 100).toStringAsFixed(2).replaceAll('.', ',');
}
