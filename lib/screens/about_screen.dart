import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_mode.dart';
import '../widgets/pix_donation_card.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  static const _email = 'abobicarlo@gmail.com';

  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() => _version = 'Versão ${info.version} (${info.buildNumber})');
      }
    } catch (_) {}
  }

  void _copy(String text, String aviso) {
    Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(aviso)));
  }

  Future<void> _abrirEmail(String assunto) async {
    final uri = Uri(
      scheme: 'mailto',
      path: _email,
      query: 'subject=${Uri.encodeComponent(assunto)}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _copy(_email, 'E-mail copiado: $_email');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sobre')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          // Cabeçalho
          Center(
            child: Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B7F5C),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.show_chart,
                      color: Colors.white, size: 52),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Lucro do Dia',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                if (_version.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    _version,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Sobre o app
          _Secao(
            icon: Icons.info_outline,
            titulo: 'Sobre o app',
            child: Text(
              AppModeStore.labels.aboutText,
              style: const TextStyle(height: 1.5),
            ),
          ),

          // Modo de uso (comércio x pessoal)
          _Secao(
            icon: Icons.tune,
            titulo: 'Modo de uso',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Escolha como o app fala com você. Isso muda só os nomes '
                  '(venda/compra ou entrada/gasto); seus registros continuam os '
                  'mesmos.',
                  style: TextStyle(height: 1.5),
                ),
                const SizedBox(height: 12),
                SegmentedButton<AppMode>(
                  segments: const [
                    ButtonSegment(
                      value: AppMode.comercio,
                      label: Text('Comércio'),
                      icon: Icon(Icons.storefront),
                    ),
                    ButtonSegment(
                      value: AppMode.pessoal,
                      label: Text('Pessoal'),
                      icon: Icon(Icons.person),
                    ),
                  ],
                  selected: {AppModeStore.mode},
                  onSelectionChanged: (s) async {
                    await AppModeStore.set(s.first);
                    if (mounted) setState(() {});
                  },
                ),
              ],
            ),
          ),

          // Privacidade
          _Secao(
            icon: Icons.lock_outline,
            titulo: 'Privacidade',
            child: const Text(
              'Seus dados ficam só no seu celular. Todas as vendas e compras são '
              'salvas apenas na memória interna deste aparelho. Nada é enviado para '
              'servidores do desenvolvedor.\n\n'
              'A única conexão com a internet é opcional: verificar se existe uma '
              'versão nova do app. Nenhum dado financeiro sai do seu celular.',
              style: TextStyle(height: 1.5),
            ),
          ),

          // Doações Pix
          _Secao(
            icon: Icons.favorite_outline,
            titulo: 'Apoie com um Pix',
            child: const PixDonationCard(),
          ),

          // Contato
          _Secao(
            icon: Icons.mail_outline,
            titulo: 'Fale comigo',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tem uma sugestão, encontrou um erro ou precisa de ajuda? '
                  'Pode me escrever — vou gostar de saber sua opinião.',
                  style: TextStyle(height: 1.5),
                ),
                const SizedBox(height: 12),
                _LinhaCopiavel(
                  rotulo: 'E-mail',
                  valor: _email,
                  onCopiar: () => _copy(_email, 'E-mail copiado'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () =>
                            _abrirEmail('Lucro do Dia — Sugestão'),
                        icon: const Icon(Icons.lightbulb_outline),
                        label: const Text('Enviar sugestão'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _abrirEmail('Lucro do Dia — Ajuda'),
                        icon: const Icon(Icons.help_outline),
                        label: const Text('Pedir ajuda'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          Center(
            child: Text(
              'Feito com 💚 para quem trabalha por conta',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _Secao extends StatelessWidget {
  const _Secao({
    required this.icon,
    required this.titulo,
    required this.child,
  });

  final IconData icon;
  final String titulo;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF1B7F5C)),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _LinhaCopiavel extends StatelessWidget {
  const _LinhaCopiavel({
    required this.rotulo,
    required this.valor,
    required this.onCopiar,
  });

  final String rotulo;
  final String valor;
  final VoidCallback onCopiar;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onCopiar,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rotulo,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    valor,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.copy, size: 20, color: Color(0xFF1B7F5C)),
          ],
        ),
      ),
    );
  }
}
