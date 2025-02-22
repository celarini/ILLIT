
/**
 * @file Game list screen for the Illit app
 * @description 
 * This file contains the GameListScreen widget, which displays a list of games,
 * allows adding/removing games, creating backups, and monitoring SHA changes.
 * 
 * Key features:
 * - Fetches and displays list of games with current SHA
 * - Adds/removes games with buttons
 * - Creates backups manually or automatically on SHA change
 * - Sends ZIPs to Discord webhook if configured, with size check
 * - Monitors SHA changes efficiently
 * 
 * @dependencies
 * - flutter/material.dart: For UI components
 * - http/http.dart: For sending webhook notifications with file attachments
 * - dart:convert: For JSON/base64 encoding/decoding
 * - dart:async: For Timer and async operations
 * - settings_screen.dart: For navigation to SettingsScreen
 * - api_service.dart: For backend communication
 */

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'settings_screen.dart';
import '../services/api_service.dart';

class GameListScreen extends StatefulWidget {
  const GameListScreen({super.key});

  @override
  _GameListScreenState createState() => _GameListScreenState();
}

class _GameListScreenState extends State<GameListScreen> {
  List<dynamic> games = [];
  bool isMonitoring = false;
  String? webhookUrl;
  Timer? _monitoringTimer;
  final ApiService _apiService = ApiService();

  Future<void> fetchGames() async {
    try {
      final fetchedGames = await _apiService.fetchGames();
      setState(() {
        games = fetchedGames;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar jogos: $e')),
      );
    }
  }

  Future<void> createBackup(String gameName, {bool isManual = false}) async {
    try {
      final (zipContent, sha) = await _apiService.createBackup(gameName);
      if (webhookUrl != null && webhookUrl!.isNotEmpty) {
        await _sendBackupToWebhook(webhookUrl!, zipContent, gameName, isManual);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isManual ? 'Backup manual criado!' : 'Backup automático criado!')),
      );
      await fetchGames();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar backup: $e')),
      );
    }
  }

  Future<void> _sendBackupToWebhook(String url, String zipContent, String gameName, bool isManual) async {
    try {
      // Converter base64 para bytes e verificar tamanho
      final zipBytes = base64Decode(zipContent);
      const int discordMaxSize = 8 * 1024 * 1024; // 8 MB limite padrão do Discord
      if (zipBytes.length > discordMaxSize) {
        throw Exception('O arquivo ZIP (${zipBytes.length ~/ 1024} KB) excede o limite de 8 MB do Discord.');
      }

      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        zipBytes,
        filename: 'backup_${gameName}_${DateTime.now().toIso8601String()}.zip',
      ));
      request.fields['content'] = isManual 
          ? 'Backup manual de $gameName criado!'
          : 'Backup automático de $gameName criado devido a mudança no save!';
      
      // Configurar timeout maior
      final response = await request.send().timeout(const Duration(seconds: 30));
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Erro ao enviar backup ao webhook: HTTP ${response.statusCode}');
      }
      print('Backup enviado ao webhook com sucesso! Tamanho: ${zipBytes.length ~/ 1024} KB');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar backup ao webhook: $e')),
      );
      print('Erro ao enviar backup: $e');
    }
  }

  Future<void> addGame(String name, String saveDir, String executable) async {
    try {
      final success = await _apiService.addGame(name, saveDir, executable);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jogo adicionado com sucesso!')),
        );
        await fetchGames();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao adicionar jogo: $e')),
      );
    }
  }

  Future<void> removeGame(String gameName) async {
    try {
      final success = await _apiService.removeGame(gameName);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jogo removido com sucesso!')),
        );
        await fetchGames();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao remover jogo: $e')),
      );
    }
  }

  void toggleMonitoring() {
    setState(() {
      isMonitoring = !isMonitoring;
    });
    if (isMonitoring) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Monitoramento iniciado')),
      );
      _monitoringTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (mounted) _checkForChanges();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Monitoramento parado')),
      );
      _monitoringTimer?.cancel();
      _monitoringTimer = null;
    }
  }

  Future<void> _checkForChanges() async {
    try {
      final updatedGames = await _apiService.fetchGames();
      for (var newGame in updatedGames) {
        final gameName = newGame['key'];
        final currentSha = newGame['value']['current_sha'];
        final lastBackupSha = newGame['value']['last_backup_sha'];
        if (currentSha != lastBackupSha && lastBackupSha != null) {
          await createBackup(gameName, isManual: false);
        }
      }
      setState(() {
        games = updatedGames;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao verificar mudanças: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchGames();
    _loadWebhook();
  }

  Future<void> _loadWebhook() async {
    try {
      final webhook = await _apiService.getWebhook();
      setState(() {
        webhookUrl = webhook.isNotEmpty ? webhook : null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar webhook: $e')),
      );
    }
  }

  @override
  void dispose() {
    _monitoringTimer?.cancel();
    super.dispose();
  }

  void showAddGameDialog() {
    final nameController = TextEditingController();
    final saveDirController = TextEditingController();
    final exeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFF0F5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Adicionar Novo Jogo', style: TextStyle(color: Color(0xFFF8C1CC))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Color(0xFF333333)),
              decoration: const InputDecoration(
                labelText: 'Nome do Jogo',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFB2EBF2))),
              ),
            ),
            TextField(
              controller: saveDirController,
              style: const TextStyle(color: Color(0xFF333333)),
              decoration: const InputDecoration(
                labelText: 'Diretório de Saves',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFB2EBF2))),
              ),
            ),
            TextField(
              controller: exeController,
              style: const TextStyle(color: Color(0xFF333333)),
              decoration: const InputDecoration(
                labelText: 'Executável',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFB2EBF2))),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              addGame(nameController.text, saveDirController.text, exeController.text);
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌬️아일릿', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF333333))),
        backgroundColor: const Color(0xFFF8C1CC),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF333333)),
            onPressed: showAddGameDialog,
          ),
          IconButton(
            icon: Icon(isMonitoring ? Icons.stop : Icons.play_arrow, color: Color(0xFF333333)),
            onPressed: toggleMonitoring,
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF333333)),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
            },
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: games.length,
        itemBuilder: (context, index) {
          var game = games[index];
          return Card(
            color: const Color(0xFFFFF0F5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.gamepad, color: Color(0xFFF8C1CC), size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          game['key'],
                          style: const TextStyle(
                            color: Color(0xFF333333),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        isMonitoring ? Icons.visibility : Icons.visibility_off,
                        color: isMonitoring ? const Color(0xFFB2EBF2) : Colors.grey,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    game['value']['save_dir'],
                    style: const TextStyle(color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () => createBackup(game['key'], isManual: true),
                        child: const Text('Backup'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => removeGame(game['key']),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Remover'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
