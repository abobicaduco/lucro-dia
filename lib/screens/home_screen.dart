import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../config/app_mode.dart';
import '../config/build_config.dart';
import '../models/transaction.dart';
import '../services/ads_service.dart';
import '../services/database_service.dart';
import '../services/update_service.dart';
import '../utils/currency.dart';
import 'add_transaction_screen.dart';
import 'transactions_list_screen.dart';
import 'about_screen.dart';
import 'donation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  MonthSummary? _summary;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
    // Primeira execução: pergunta se o uso é comércio ou pessoal.
    if (!AppModeStore.chosen) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _chooseMode());
    }
    // Auto-update OTA só no build do GitHub. Na Play é proibido baixar APK
    // de fora da loja, então a checagem nem roda.
    if (BuildConfig.selfUpdateEnabled) _checkUpdate();
  }

  Future<void> _chooseMode() async {
    final mode = await showDialog<AppMode>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Como você vai usar o app?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Você pode trocar depois na tela "Sobre".',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => Navigator.pop(ctx, AppMode.comercio),
              icon: const Icon(Icons.storefront),
              label: const Text('Tenho um comércio (vendas e compras)'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(ctx, AppMode.pessoal),
              icon: const Icon(Icons.person),
              label: const Text('Finanças pessoais (entradas e gastos)'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ],
        ),
      ),
    );
    if (mode != null) {
      await AppModeStore.set(mode);
      if (mounted) setState(() {});
    }
  }

  Future<void> _checkUpdate() async {
    final update = await UpdateService.instance.checkForUpdate();
    if (update != null && mounted) {
      await UpdateService.instance.showUpdateDialog(context, update);
    }
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    final summary = await DatabaseService.instance.summaryForMonth(_month);
    if (mounted) {
      setState(() {
        _summary = summary;
        _loading = false;
      });
    }
  }

  Future<void> _changeMonth(int delta) async {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta);
    });
    await _refresh();
  }

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return _month.year == now.year && _month.month == now.month;
  }

  Future<void> _add(TransactionType type) async {
    final result = await Navigator.push<Transaction>(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(initialType: type),
      ),
    );
    if (result != null) {
      await DatabaseService.instance.insert(result);
      await _refresh();
    }
  }

  Future<void> _showRegisterSheet() async {
    final type = await showModalBottomSheet<TransactionType>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'O que você quer registrar?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => Navigator.pop(ctx, TransactionType.sale),
                icon: const Icon(Icons.arrow_upward),
                label: Text(AppModeStore.labels.registerIncomeBtn),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: () => Navigator.pop(ctx, TransactionType.purchase),
                icon: const Icon(Icons.arrow_downward),
                label: Text(AppModeStore.labels.registerExpenseBtn),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (type != null) await _add(type);
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat('MMMM yyyy', 'pt_BR').format(_month);
    final s = _summary;
    final l = AppModeStore.labels;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lucro do Dia'),
        actions: [
          IconButton(
            tooltip: 'Apoiar o app',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DonationScreen()),
              );
            },
            icon: const Icon(Icons.favorite_outline),
            color: const Color(0xFFD81B60),
          ),
          IconButton(
            tooltip: 'Sobre',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
              // O modo de uso pode ter mudado na tela Sobre.
              if (mounted) setState(() {});
            },
            icon: const Icon(Icons.info_outline),
          ),
          IconButton(
            tooltip: 'Ver todos os registros',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TransactionsListScreen(month: _month),
                ),
              );
              await _refresh();
            },
            icon: const Icon(Icons.list_alt),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _MonthPicker(
                    label: monthLabel,
                    onPrev: () => _changeMonth(-1),
                    onNext: () => _changeMonth(1),
                  ),
                  const SizedBox(height: 16),
                  if (s != null) ...[
                    _StatusBanner(summary: s),
                    const SizedBox(height: 16),
                    _BigCard(
                      title: l.monthResultTitle,
                      value: formatCents(s.balanceCents),
                      subtitle: s.isProfit
                          ? l.positiveSubtitle
                          : l.negativeSubtitle,
                      color: s.isProfit ? Colors.green : Colors.red,
                      icon: s.isProfit ? Icons.trending_up : Icons.trending_down,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _MiniCard(
                            title: l.incomeCard,
                            value: formatCents(s.salesCents),
                            color: Colors.green,
                            icon: Icons.arrow_upward,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MiniCard(
                            title: l.expenseCard,
                            value: formatCents(s.purchasesCents),
                            color: Colors.red,
                            icon: Icons.arrow_downward,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (_isCurrentMonth) ...[
                      Text(
                        'Até hoje (${DateFormat('dd/MM').format(DateTime.now())})',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _LineRow(
                              label: l.incomeUntilToday,
                              value: formatCents(s.salesUntilTodayCents),
                              color: Colors.green,
                            ),
                            const Divider(height: 20),
                            _LineRow(
                              label: l.expenseUntilToday,
                              value: formatCents(s.purchasesUntilTodayCents),
                              color: Colors.red,
                            ),
                            const Divider(height: 20),
                            _LineRow(
                              label: 'Saldo até hoje',
                              value: formatCents(s.balanceUntilTodayCents),
                              color: s.isProfitUntilToday
                                  ? Colors.green
                                  : Colors.red,
                              bold: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      '${s.transactionCount} registro(s) neste mês',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 20),
                  _SupportCard(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DonationScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BannerAdView(),
          NavigationBar(
            selectedIndex: 0,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Início'),
              NavigationDestination(icon: Icon(Icons.add_circle_outline), label: 'Registrar'),
              NavigationDestination(icon: Icon(Icons.list_alt), label: 'Histórico'),
            ],
            onDestinationSelected: (i) async {
              if (i == 1) {
                await _showRegisterSheet();
              } else if (i == 2) {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TransactionsListScreen(month: _month),
                  ),
                );
                await _refresh();
              }
            },
          ),
        ],
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      color: const Color(0xFFFFF1F4),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.favorite, color: Color(0xFFD81B60), size: 30),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gostou do app? Apoie com um Pix 💚',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 2),
                    Text(
                      BuildConfig.adsEnabled
                          ? 'App gratuito. Qualquer valor ajuda a manter o projeto.'
                          : 'Gratuito e sem propaganda. Qualquer valor ajuda.',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthPicker extends StatelessWidget {
  const _MonthPicker({
    required this.label,
    required this.onPrev,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            IconButton(onPressed: onPrev, icon: const Icon(Icons.chevron_left)),
            Expanded(
              child: Text(
                label[0].toUpperCase() + label.substring(1),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(onPressed: onNext, icon: const Icon(Icons.chevron_right)),
          ],
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.summary});

  final MonthSummary summary;

  @override
  Widget build(BuildContext context) {
    final profit = summary.isProfit;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (profit ? Colors.green : Colors.red).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (profit ? Colors.green : Colors.red).withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Icon(
            profit ? Icons.sentiment_satisfied_alt : Icons.sentiment_dissatisfied,
            size: 36,
            color: profit ? Colors.green.shade700 : Colors.red.shade700,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              profit
                  ? AppModeStore.labels.bannerPositive
                  : AppModeStore.labels.bannerNegative,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: profit ? Colors.green.shade900 : Colors.red.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BigCard extends StatelessWidget {
  const _BigCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  final String title;
  final String value;
  final String subtitle;
  final MaterialColor color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color.shade700),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color.shade800,
              ),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String title;
  final String value;
  final MaterialColor color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color.shade700, size: 22),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LineRow extends StatelessWidget {
  const _LineRow({
    required this.label,
    required this.value,
    required this.color,
    this.bold = false,
  });

  final String label;
  final String value;
  final MaterialColor color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            color: color.shade800,
            fontSize: bold ? 18 : 15,
          ),
        ),
      ],
    );
  }
}
