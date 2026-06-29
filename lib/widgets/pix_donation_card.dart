import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../utils/pix.dart';

/// Cartão de doação via Pix reutilizável (tela Sobre e tela Apoiar).
///
/// Mostra QR Code, chave e "copia e cola" — tudo gerado localmente no aparelho.
class PixDonationCard extends StatelessWidget {
  const PixDonationCard({super.key, this.showIntro = true});

  /// Quando falso, esconde o texto introdutório (útil em telas que já explicam).
  final bool showIntro;

  void _copy(BuildContext context, String text, String aviso) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(aviso),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final pixCode = Pix.copiaECola();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showIntro) ...[
          const Text(
            'Este app é gratuito e sem propaganda. Se ele te ajudou e você '
            'quiser contribuir, qualquer valor é bem-vindo — você escolhe '
            'quanto. Obrigado! 💚',
            style: TextStyle(height: 1.5),
          ),
          const SizedBox(height: 16),
        ],
        Center(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: QrImageView(
              data: pixCode,
              version: QrVersions.auto,
              size: 210,
              backgroundColor: Colors.white,
              errorStateBuilder: (context, error) => const SizedBox(
                width: 210,
                height: 210,
                child: Center(child: Text('Não foi possível gerar o QR')),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'Aponte a câmera do seu banco para o QR',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ),
        const SizedBox(height: 16),
        _CopyRow(
          rotulo: 'Chave Pix (e-mail)',
          valor: Pix.chave,
          onTap: () => _copy(context, Pix.chave, 'Chave Pix copiada'),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => _copy(
              context,
              pixCode,
              'Código Pix copiado — cole no app do seu banco',
            ),
            icon: const Icon(Icons.copy),
            label: const Text('Copiar Pix copia e cola'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
          ),
        ),
      ],
    );
  }
}

class _CopyRow extends StatelessWidget {
  const _CopyRow({
    required this.rotulo,
    required this.valor,
    required this.onTap,
  });

  final String rotulo;
  final String valor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
