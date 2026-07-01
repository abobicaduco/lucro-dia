import 'package:shared_preferences/shared_preferences.dart';

/// Modo de uso do app: quem tem comércio vs. finanças pessoais.
/// Muda apenas os textos/rótulos; o modelo de dados é o mesmo
/// (entrada = venda/receita, saída = compra/despesa).
enum AppMode { comercio, pessoal }

/// Guarda o modo escolhido (persistido em SharedPreferences). Acesso estático
/// para os widgets lerem os rótulos sem precisar passar por toda a árvore.
class AppModeStore {
  AppModeStore._();

  static const _key = 'app_mode';
  static AppMode? _mode;

  /// null enquanto o usuário ainda não escolheu (primeira execução).
  static bool get chosen => _mode != null;

  /// Modo atual (default comércio quando ainda não escolhido).
  static AppMode get mode => _mode ?? AppMode.comercio;

  static Labels get labels => Labels.of(mode);

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_key);
    _mode = (v == null) ? null : AppMode.values.asNameMap()[v];
  }

  static Future<void> set(AppMode m) async {
    _mode = m;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, m.name);
  }
}

/// Conjunto de textos que variam conforme o modo.
class Labels {
  const Labels({
    required this.incomeShort,
    required this.expenseShort,
    required this.registerIncomeBtn,
    required this.registerExpenseBtn,
    required this.monthResultTitle,
    required this.positiveSubtitle,
    required this.negativeSubtitle,
    required this.bannerPositive,
    required this.bannerNegative,
    required this.incomeCard,
    required this.expenseCard,
    required this.incomeUntilToday,
    required this.expenseUntilToday,
    required this.descHint,
    required this.aboutText,
  });

  final String incomeShort;
  final String expenseShort;
  final String registerIncomeBtn;
  final String registerExpenseBtn;
  final String monthResultTitle;
  final String positiveSubtitle;
  final String negativeSubtitle;
  final String bannerPositive;
  final String bannerNegative;
  final String incomeCard;
  final String expenseCard;
  final String incomeUntilToday;
  final String expenseUntilToday;
  final String descHint;
  final String aboutText;

  static Labels of(AppMode m) =>
      m == AppMode.pessoal ? _pessoal : _comercio;

  static const _comercio = Labels(
    incomeShort: 'Venda',
    expenseShort: 'Compra',
    registerIncomeBtn: 'Registrar venda (entrou dinheiro)',
    registerExpenseBtn: 'Registrar compra (saiu dinheiro)',
    monthResultTitle: 'Lucro do mês',
    positiveSubtitle: 'Você está lucrando neste mês',
    negativeSubtitle: 'Você está no prejuízo neste mês',
    bannerPositive: 'Parabéns! Suas vendas estão maiores que suas compras.',
    bannerNegative: 'Atenção: você gastou mais do que vendeu neste mês.',
    incomeCard: 'Vendas',
    expenseCard: 'Compras',
    incomeUntilToday: 'Vendas até hoje',
    expenseUntilToday: 'Gastos até hoje',
    descHint: 'Ex: venda de brigadeiro',
    aboutText:
        'O Lucro do Dia ajuda você a registrar suas vendas e compras do dia '
        'a dia e entender, sem complicação, se está lucrando ou no prejuízo '
        'no mês.\n\n'
        'Foi feito para ser simples: você anota quanto entrou e quanto saiu, '
        'e o app mostra na hora o seu resultado, em palavras fáceis.',
  );

  static const _pessoal = Labels(
    incomeShort: 'Entrada',
    expenseShort: 'Gasto',
    registerIncomeBtn: 'Registrar entrada (recebi dinheiro)',
    registerExpenseBtn: 'Registrar gasto (saiu dinheiro)',
    monthResultTitle: 'Saldo do mês',
    positiveSubtitle: 'Você está no positivo neste mês',
    negativeSubtitle: 'Você está no negativo neste mês',
    bannerPositive: 'Boa! Suas entradas estão maiores que seus gastos.',
    bannerNegative: 'Atenção: você gastou mais do que recebeu neste mês.',
    incomeCard: 'Entradas',
    expenseCard: 'Gastos',
    incomeUntilToday: 'Entradas até hoje',
    expenseUntilToday: 'Gastos até hoje',
    descHint: 'Ex: salário, mercado, aluguel',
    aboutText:
        'O Lucro do Dia ajuda você a registrar o que entra e o que sai do seu '
        'dinheiro no dia a dia e entender, sem complicação, se sobrou ou faltou '
        'no mês.\n\n'
        'Foi feito para ser simples: você anota quanto recebeu e quanto gastou, '
        'e o app mostra na hora o seu resultado, em palavras fáceis.',
  );
}
