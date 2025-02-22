
/**
 * @file Webhook setup screen for the Illit app
 * @description
 * This file contains the WebhookSetupScreen widget, which prompts the user to
 * configure a Discord webhook before proceeding to the game list.
 *
 * Key features:
 * - Displays a text field for webhook URL
 * - Saves the webhook via ApiService
 * - Navigates to GameListScreen on success
 *
 * @dependencies
 * - flutter/material.dart: For UI components
 * - api_service.dart: For saving the webhook
 * - game_list_screen.dart: For navigation
 */

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'game_list_screen.dart';

class WebhookSetupScreen extends StatefulWidget {
  const WebhookSetupScreen({super.key});

  @override
  _WebhookSetupScreenState createState() => _WebhookSetupScreenState();
}

class _WebhookSetupScreenState extends State<WebhookSetupScreen> {
  final TextEditingController _webhookController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isSaving = false;

  Future<void> _saveWebhook() async {
    if (_webhookController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira uma URL de webhook válida')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _apiService.setWebhook(_webhookController.text);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GameListScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar webhook: $e')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Webhook', style: TextStyle(color: Color(0xFF333333))),
        backgroundColor: const Color(0xFFF8C1CC),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8C1CC), Color(0xFFF5F5F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Bem-vindo ao ILLIT!\nConfigure seu Webhook do Discord para receber backups:',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _webhookController,
              style: const TextStyle(color: Color(0xFF333333)),
              decoration: InputDecoration(
                labelText: 'URL do Webhook',
                labelStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Color(0xFFB2EBF2)),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 20),
            _isSaving
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _saveWebhook,
                    child: const Text('Salvar e Continuar'),
                  ),
            const SizedBox(height: 16),
            const Text(
              'Dica: Crie um webhook no Discord em um canal e cole a URL aqui.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF333333), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
