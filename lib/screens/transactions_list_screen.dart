import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../config/app_mode.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';
import '../utils/currency.dart';
import 'add_transaction_screen.dart';

class TransactionsListScreen extends StatefulWidget {
  const TransactionsListScreen({super.key, required this.month});

  final DateTime month;

  @override
  State<TransactionsListScreen> createState() => _TransactionsListScreenState();
}

class _TransactionsListScreenState extends State<TransactionsListScreen> {
  List<Transaction> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final items =
        await DatabaseService.instance.listForMonth(widget.month);
    if (mounted) {
      setState(() {
        _items = items;
        _loading = false;
      });
    }
  }

  Future<void> _edit(Transaction tx) async {
    final result = await Navigator.push<Transaction>(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(existing: tx),
      ),
    );
    if (result != null) {
      await DatabaseService.instance.update(result);
      await _load();
    }
  }

  Future<void> _delete(Transaction tx) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Apagar registro?'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
    if (ok == true && tx.id != null) {
      await DatabaseService.instance.delete(tx.id!);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel =
        DateFormat('MMMM yyyy', 'pt_BR').format(widget.month);
    return Scaffold(
      appBar: AppBar(title: Text('Registros — $monthLabel')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Nenhum registro neste mês.\nToque em + na tela inicial.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: _items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final tx = _items[i];
                    final color = tx.isSale ? Colors.green : Colors.red;
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color.withValues(alpha: 0.15),
                          child: Icon(
                            tx.isSale
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: color.shade700,
                          ),
                        ),
                        title: Text(
                          tx.isSale
                              ? AppModeStore.labels.incomeShort
                              : AppModeStore.labels.expenseShort,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          [
                            DateFormat('dd/MM/yyyy').format(tx.date),
                            if (tx.description.isNotEmpty) tx.description,
                          ].join(' · '),
                        ),
                        trailing: Text(
                          formatCents(tx.amountCents),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: color.shade800,
                            fontSize: 16,
                          ),
                        ),
                        onTap: () => _edit(tx),
                        onLongPress: () => _delete(tx),
                      ),
                    );
                  },
                ),
    );
  }
}
