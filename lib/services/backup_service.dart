
/**
 * @file Backup Service for the Illit app
 * @description
 * This file contains the BackupService class, which handles all game backup
 * operations locally, including game management, ZIP creation, SHA calculation,
 * and webhook sending.
 *
 * Key features:
 * - Manages game configurations in config.json
 * - Creates ZIP backups of save directories
 * - Calculates SHA256 for save directories
 * - Sends backups to Discord webhook
 *
 * @dependencies
 * - dart:io: For file operations and ZIP creation
 * - dart:convert: For JSON/base64 encoding/decoding
 * - crypto: For SHA256 calculation
 * - http: For sending webhook requests
 * - archive: For ZIP compression
 * - path: For path manipulation
 */

import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class BackupService {
  static const String _configFile = 'config.json';
  Map<String, dynamic> _config = {'games': {}, 'webhook_url': ''};

  BackupService() {
    _loadConfig();
  }

  /// Loads the configuration from config.json or initializes a default one.
  void _loadConfig() {
    final file = File(_configFile);
    if (file.existsSync()) {
      try {
        _config = json.decode(file.readAsStringSync());
      } catch (e) {
        print('Erro ao carregar config.json: $e');
        _config = {'games': {}, 'webhook_url': ''};
        _saveConfig();
      }
    } else {
      _saveConfig();
    }
  }

  /// Saves the current configuration to config.json.
  void _saveConfig() {
    final file = File(_configFile);
    file.writeAsStringSync(json.encode(_config), flush: true);
  }

  /// Fetches the list of games with their current SHA.
  List<Map<String, dynamic>> fetchGames() {
    _loadConfig();
    final games = _config['games'] as Map<String, dynamic>;
    return games.entries.map((entry) {
      final saveDir = entry.value['save_dir'] as String;
      final currentSha = _calculateSha(saveDir);
      return {
        'key': entry.key,
        'value': {
          ...entry.value,
          'current_sha': currentSha,
        }
      };
    }).toList();
  }

  /// Calculates SHA256 for a directory by combining file contents.
  String _calculateSha(String directory) {
    try {
      final dir = Directory(directory);
      if (!dir.existsSync()) {
        return sha256.convert([]).toString(); // SHA vazio se o diretório não existir
      }

      final files = dir.listSync(recursive: true).whereType<File>().toList();
      // Combinar todos os bytes dos arquivos em uma lista
      final allBytes = <int>[];
      for (final file in files) {
        final bytes = file.readAsBytesSync();
        allBytes.addAll(bytes);
      }
      // Calcular o SHA256 de todos os bytes de uma vez
      return sha256.convert(allBytes).toString();
    } catch (e) {
      print('Erro ao calcular SHA: $e');
      return sha256.convert([]).toString(); // SHA vazio em caso de erro
    }
  }

  /// Creates a backup ZIP for a game and returns its base64 content and SHA.
  Future<(String, String)> createBackup(String gameName) async {
    _loadConfig();
    final games = _config['games'] as Map<String, dynamic>;
    if (!games.containsKey(gameName)) {
      throw Exception('Jogo não encontrado');
    }

    final saveDir = games[gameName]['save_dir'] as String;
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final archive = Archive();

    try {
      final dir = Directory(saveDir);
      if (!dir.existsSync()) throw Exception('Diretório de saves não existe');
      final files = dir.listSync(recursive: true).whereType<File>();
      for (final file in files) {
        final relativePath = path.relative(file.path, from: saveDir);
        final bytes = file.readAsBytesSync();
        archive.addFile(ArchiveFile(relativePath, bytes.length, bytes));
      }

      final zipBytes = ZipEncoder().encode(archive);
      if (zipBytes == null) throw Exception('Falha ao criar ZIP');
      final zipContent = base64Encode(zipBytes);
      final currentSha = _calculateSha(saveDir);

      games[gameName]['last_backup_sha'] = currentSha;
      _config['games'] = games;
      _saveConfig();

      return (zipContent, currentSha);
    } catch (e) {
      throw Exception('Erro ao criar backup: $e');
    }
  }

  /// Adds a new game to the configuration.
  void addGame(String name, String saveDir, String executable) {
    _loadConfig();
    final games = _config['games'] as Map<String, dynamic>;
    if (games.containsKey(name)) {
      throw Exception('Jogo já existe');
    }
    games[name] = {
      'save_dir': saveDir,
      'game_executable': executable,
      'last_backup_sha': null,
    };
    _config['games'] = games;
    _saveConfig();
  }

  /// Removes a game from the configuration.
  void removeGame(String gameName) {
    _loadConfig();
    final games = _config['games'] as Map<String, dynamic>;
    if (!games.containsKey(gameName)) {
      throw Exception('Jogo não encontrado');
    }
    games.remove(gameName);
    _config['games'] = games;
    _saveConfig();
  }

  /// Gets the saved webhook URL.
  String getWebhook() {
    _loadConfig();
    return _config['webhook_url'] as String;
  }

  /// Saves a new webhook URL.
  void setWebhook(String url) {
    _loadConfig();
    _config['webhook_url'] = url;
    _saveConfig();
  }

  /// Sends a backup ZIP to the Discord webhook.
  Future<void> sendToWebhook(String url, String zipContent, String gameName, bool isManual) async {
    final zipBytes = base64Decode(zipContent);
    const int discordMaxSize = 8 * 1024 * 1024; // 8 MB
    if (zipBytes.length > discordMaxSize) {
      throw Exception('ZIP muito grande (${zipBytes.length ~/ 1024} KB). Limite do Discord é 8 MB.');
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
    
    final response = await request.send().timeout(const Duration(seconds: 30));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erro ao enviar ao webhook: HTTP ${response.statusCode}');
    }
  }
}
