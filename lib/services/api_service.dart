
/**
 * @file API Service for the Illit app
 * @description
 * This file contains the ApiService class, which handles all HTTP requests to
 * the FastAPI backend running at http://127.0.0.1:8000. It provides methods
 * to fetch games, create backups, add/remove games, and manage webhooks.
 *
 * Key features:
 * - Centralized API communication
 * - Parses backend responses for success/error status
 * - Returns ZIP content and SHA for backups
 * - Manages webhook persistence
 *
 * @dependencies
 * - http/http.dart: For making HTTP requests
 * - dart:convert: For JSON/base64 encoding/decoding
 *
 * @notes
 * - Assumes the backend is running locally at http://127.0.0.1:8000
 * - Compatible with the updated api.py FastAPI backend
 * - Throws exceptions with backend-provided messages for better UX
 */

import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String _baseUrl = 'http://127.0.0.1:8000';

  /// Fetches the list of games from the backend, including current SHA.
  /// Returns a list of game objects or throws an exception on failure.
  Future<List<dynamic>> fetchGames() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/games'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['games'] as List<dynamic>;
      } else {
        throw Exception('Failed to fetch games: HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching games: $e');
    }
  }

  /// Creates a backup for the specified game.
  /// Returns a tuple with ZIP content (base64) and current SHA, throws an exception on failure.
  Future<(String, String)> createBackup(String gameName) async {
    try {
      final response = await http.post(Uri.parse('$_baseUrl/backup/$gameName'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return (data['zip_content'] as String, data['sha'] as String);
        } else {
          throw Exception(data['message'] ?? 'Unknown error creating backup');
        }
      } else {
        throw Exception('Failed to create backup: HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating backup: $e');
    }
  }

  /// Adds a new game to the backend.
  Future<bool> addGame(String name, String saveDir, String executable) async {
    if (name.isEmpty || saveDir.isEmpty || executable.isEmpty) {
      throw Exception('All fields (name, save directory, executable) must be provided');
    }
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/add_game'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'save_dir': saveDir,
          'executable': executable,
        }),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return true;
        } else {
          throw Exception(data['message'] ?? 'Unknown error adding game');
        }
      } else {
        throw Exception('Failed to add game: HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding game: $e');
    }
  }

  /// Removes a game from the backend.
  Future<bool> removeGame(String gameName) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/remove_game/$gameName'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return true;
        } else {
          throw Exception(data['message'] ?? 'Unknown error removing game');
        }
      } else {
        throw Exception('Failed to remove game: HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error removing game: $e');
    }
  }

  /// Fetches the saved webhook URL from the backend.
  Future<String> getWebhook() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/webhook'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['webhook_url'] as String;
      } else {
        throw Exception('Failed to fetch webhook: HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching webhook: $e');
    }
  }

  /// Saves the webhook URL to the backend.
  Future<bool> setWebhook(String url) async {
    if (url.isEmpty) {
      throw Exception('Webhook URL must be provided');
    }
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/webhook'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'url': url}),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return true;
        } else {
          throw Exception(data['message'] ?? 'Unknown error saving webhook');
        }
      } else {
        throw Exception('Failed to save webhook: HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error saving webhook: $e');
    }
  }
}
