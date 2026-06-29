import 'package:flutter/material.dart';

import '../widgets/pix_donation_card.dart';

class DonationScreen extends StatelessWidget {
  const DonationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Apoiar o app')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFCE4EC),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Color(0xFFD81B60),
                    size: 44,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Gostou do Lucro do Dia?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Ele é gratuito, sem propaganda e sem coletar seus dados. '
                  'Se quiser retribuir e ajudar o app a continuar, faça um Pix '
                  'de qualquer valor. 💚',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        color: Colors.black87,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: PixDonationCard(showIntro: false),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Toda contribuição é voluntária. Muito obrigado!',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
