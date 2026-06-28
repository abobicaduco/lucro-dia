import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacidade')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Icon(Icons.lock_outline, size: 48),
          SizedBox(height: 16),
          Text(
            'Seus dados ficam só no celular',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text(
            'Todas as vendas e compras são salvas apenas na memória interna '
            'deste aparelho. Nada é enviado para servidores do desenvolvedor.\n\n'
            'A única conexão com a internet é opcional: verificar se existe '
            'uma versão nova do app. Nenhum dado financeiro sai do seu celular.',
            style: TextStyle(height: 1.5),
          ),
        ],
      ),
    );
  }
}
