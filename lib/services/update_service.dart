import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// Verifica apenas se há versão nova — nenhum dado do usuário é enviado.
class UpdateInfo {
  const UpdateInfo({
    required this.versionCode,
    required this.versionName,
    required this.apkUrl,
    required this.releaseNotes,
  });

  final int versionCode;
  final String versionName;
  final String apkUrl;
  final String releaseNotes;

  factory UpdateInfo.fromJson(Map<String, dynamic> json) => UpdateInfo(
        versionCode: json['version_code'] as int,
        versionName: json['version_name'] as String? ?? '',
        apkUrl: json['apk_url'] as String? ?? '',
        releaseNotes: json['release_notes'] as String? ?? '',
      );
}

class UpdateService {
  UpdateService._();
  static final UpdateService instance = UpdateService._();

  static const versionUrl =
      'https://abobiferramentas.com/api/lucro-dia-version.json';

  Future<UpdateInfo?> checkForUpdate() async {
    try {
      final response = await http
          .get(Uri.parse(versionUrl))
          .timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final remote = UpdateInfo.fromJson(json);
      final info = await PackageInfo.fromPlatform();
      final currentCode = int.tryParse(info.buildNumber) ?? 0;

      if (remote.versionCode <= currentCode) return null;

      final prefs = await SharedPreferences.getInstance();
      final skipped = prefs.getInt('skipped_version_code') ?? 0;
      if (skipped >= remote.versionCode) return null;

      return remote;
    } catch (_) {
      return null;
    }
  }

  Future<void> skipVersion(int versionCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('skipped_version_code', versionCode);
  }

  Future<void> showUpdateDialog(BuildContext context, UpdateInfo update) async {
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
                'Versão ${update.versionName} está disponível.',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              if (update.releaseNotes.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(update.releaseNotes),
              ],
              const SizedBox(height: 12),
              const Text(
                'Seus registros ficam só no celular. A atualização baixa o app novo; seus dados não são enviados para ninguém.',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await skipVersion(update.versionCode);
              if (ctx.mounted) Navigator.pop(ctx);
            },
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
