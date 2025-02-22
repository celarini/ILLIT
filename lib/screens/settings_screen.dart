
/**
 * @file Settings screen for the Illit app
 * @description
 * This file contains the SettingsScreen widget, which allows users to configure
 * a Discord webhook URL for receiving backup notifications, persisted via the backend.
 *
 * Key features:
 * - Input field for webhook URL
 * - Save button with visual feedback
 * - Loads initial webhook from backend
 *
 * @dependencies
 * - flutter/material.dart: For UI components
 * - api_service.dart: For saving/loading webhook
 *
 * @notes
 * - The webhook URL is saved to config.json via the backend
 * - Basic validation ensures non-empty URL
 */

import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _webhookController;
  bool _isSaved = false;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _webhookController = TextEditingController();
    _loadWebhook();
  }

  Future<void> _loadWebhook() async {
    try {
      final webhook = await _apiService.getWebhook();
      setState(() {
        _webhookController.text = webhook;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar webhook: $e')),
      );
    }
  }

  @override
  void dispose() {
    _webhookController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Configurações',
          style: TextStyle(color: Color(0xFF333333)),
        ),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configure seu Webhook do Discord',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (_webhookController.text.isNotEmpty) {
                    try {
                      await _apiService.setWebhook(_webhookController.text);
                      setState(() {
                        _isSaved = true;
                      });
                      Future.delayed(const Duration(seconds: 2), () {
                        if (mounted) {
                          setState(() {
                            _isSaved = false;
                          });
                          Navigator.pop(context);
                        }
                      });
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erro ao salvar webhook: $e')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Por favor, insira uma URL válida')),
                    );
                  }
                },
                child: _isSaved
                    ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check, size: 20),
                          SizedBox(width: 8),
                          Text('Salvo!'),
                        ],
                      )
                    : const Text('Salvar Webhook'),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Dica: Crie um webhook no Discord em um canal e cole a URL aqui para receber seus backups!',
              style: TextStyle(color: Color(0xFF333333), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
