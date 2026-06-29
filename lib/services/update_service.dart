import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// Checagem de atualização via API pública de releases do GitHub.
///
/// Nada do usuário é enviado: o app apenas consulta qual a última versão
/// publicada e, se for mais nova, oferece o download do APK certo para o
/// aparelho. Os dados financeiros nunca saem do celular.
class UpdateInfo {
  const UpdateInfo({
    required this.versionName,
    required this.apkUrl,
    required this.releaseNotes,
  });

  final String versionName;
  final String apkUrl;
  final String releaseNotes;
}

class UpdateService {
  UpdateService._();
  static final UpdateService instance = UpdateService._();

  /// Repositório que hospeda as releases (precisa ser público).
  static const _owner = 'abobicaduco';
  static const _repo = 'lucro-dia';
  static const _latestUrl =
      'https://api.github.com/repos/$_owner/$_repo/releases/latest';

  Future<UpdateInfo?> checkForUpdate() async {
    try {
      final response = await http.get(
        Uri.parse(_latestUrl),
        headers: const {'Accept': 'application/vnd.github+json'},
      ).timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final tag = (json['tag_name'] as String?) ?? '';
      final remoteVersion = normalizeVersion(tag);
      if (remoteVersion.isEmpty) return null;

      final info = await PackageInfo.fromPlatform();
      final currentVersion = normalizeVersion(info.version);

      // Só oferece se a versão publicada for realmente mais nova.
      if (compareVersions(remoteVersion, currentVersion) <= 0) return null;

      // Lembrete no máximo uma vez por dia — mas todo dia, até a pessoa
      // atualizar. Se já mostramos hoje para esta versão, não repete.
      if (await alreadyPromptedToday(remoteVersion)) return null;

      final assets = (json['assets'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      final apkUrl = await _pickApkForDevice(assets);
      if (apkUrl == null) return null;

      return UpdateInfo(
        versionName: remoteVersion,
        apkUrl: apkUrl,
        releaseNotes: (json['body'] as String?)?.trim() ?? '',
      );
    } catch (_) {
      return null;
    }
  }

  /// Escolhe o APK que combina com a arquitetura do aparelho; se não achar,
  /// usa o APK universal (que roda em qualquer celular).
  Future<String?> _pickApkForDevice(List<Map<String, dynamic>> assets) async {
    String urlOf(Map<String, dynamic> a) =>
        (a['browser_download_url'] as String?) ?? '';
    String nameOf(Map<String, dynamic> a) =>
        ((a['name'] as String?) ?? '').toLowerCase();

    final apks = assets.where((a) => nameOf(a).endsWith('.apk')).toList();
    if (apks.isEmpty) return null;

    List<String> abis = const [];
    try {
      final android = await DeviceInfoPlugin().androidInfo;
      abis = android.supportedAbis;
    } catch (_) {}

    for (final abi in abis) {
      final tag = abi.toLowerCase();
      for (final a in apks) {
        if (nameOf(a).contains(tag)) return urlOf(a);
      }
    }

    // Fallback: universal, depois qualquer APK disponível.
    for (final a in apks) {
      if (nameOf(a).contains('universal')) return urlOf(a);
    }
    return urlOf(apks.first);
  }

  /// Mantém só dígitos e pontos: "v1.2.0" -> "1.2.0".
  static String normalizeVersion(String v) =>
      v.replaceAll(RegExp(r'[^0-9.]'), '').trim();

  /// Compara "1.2.0" vs "1.10.3" numericamente. >0 se a > b.
  static int compareVersions(String a, String b) {
    final pa = a.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final pb = b.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final len = pa.length > pb.length ? pa.length : pb.length;
    for (var i = 0; i < len; i++) {
      final x = i < pa.length ? pa[i] : 0;
      final y = i < pb.length ? pb[i] : 0;
      if (x != y) return x > y ? 1 : -1;
    }
    return 0;
  }

  /// Já avisamos hoje sobre esta versão?
  Future<bool> alreadyPromptedToday(String version) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('update_prompt_date') == _todayKey() &&
        prefs.getString('update_prompt_version') == version;
  }

  /// Registra que o aviso desta versão foi mostrado hoje.
  Future<void> markPromptedToday(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('update_prompt_date', _todayKey());
    await prefs.setString('update_prompt_version', version);
  }

  String _todayKey() {
    final n = DateTime.now();
    return '${n.year}-${n.month}-${n.day}';
  }

  /// Pega só a parte amigável das notas (antes do changelog automático do
  /// GitHub, que começa com um cabeçalho "## ..."), com tamanho limitado.
  String _shortNotes(String notes) {
    var text = notes.trim();
    final header = text.indexOf(RegExp(r'^#{1,6}\s', multiLine: true));
    if (header > 0) text = text.substring(0, header).trim();
    if (text.length > 240) text = '${text.substring(0, 240).trim()}…';
    return text;
  }

  Future<void> showUpdateDialog(BuildContext context, UpdateInfo update) async {
    if (!context.mounted) return;
    // Marca já na exibição: assim só aparece uma vez por dia, mesmo que o app
    // seja fechado em seguida — e volta a aparecer amanhã se não atualizar.
    await markPromptedToday(update.versionName);
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Atualização disponível'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Saiu a versão ${update.versionName} do Lucro do Dia. '
                'Você quer atualizar agora?',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              if (_shortNotes(update.releaseNotes).isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(_shortNotes(update.releaseNotes)),
              ],
              const SizedBox(height: 12),
              const Text(
                'Seus registros ficam só no celular. A atualização baixa o app '
                'novo; seus dados não são enviados para ninguém.\n\n'
                'Se escolher "Agora não", a gente te lembra de novo amanhã.',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Agora não'),
          ),
          FilledButton(
            onPressed: () async {
              if (update.apkUrl.isNotEmpty) {
                final uri = Uri.parse(update.apkUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Atualizar'),
          ),
        ],
      ),
    );
  }
}
