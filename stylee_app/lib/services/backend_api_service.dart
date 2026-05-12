import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class BackendApiService {
  BackendApiService._();

  static final BackendApiService instance = BackendApiService._();

  final String _baseUrl = dotenv.env['STYLEE_BACKEND_URL']?.trim().isNotEmpty == true
      ? dotenv.env['STYLEE_BACKEND_URL']!.trim()
      : 'http://127.0.0.1:8000';

  Uri _uri(String path, [Map<String, String>? queryParameters]) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$_baseUrl$normalizedPath').replace(queryParameters: queryParameters);
  }

  Future<Map<String, dynamic>> _get(String path, [Map<String, String>? queryParameters]) async {
    final response = await http.get(_uri(path, queryParameters));
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    final response = await http.post(
      _uri(path),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> _put(String path, Map<String, dynamic> body) async {
    final response = await http.put(
      _uri(path),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> _delete(String path, [Map<String, dynamic>? body]) async {
    final response = await http.delete(
      _uri(path),
      headers: body == null ? null : {'Content-Type': 'application/json'},
      body: body == null ? null : jsonEncode(body),
    );
    return _decodeResponse(response);
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Backend error ${response.statusCode}: ${response.body}');
    }

    if (response.body.isEmpty) {
      return <String, dynamic>{};
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw Exception('Unexpected backend response format');
  }

  Future<Map<String, dynamic>> bootstrapUser(String email) {
    return _post('/users/$email/bootstrap', {});
  }

  Future<Map<String, dynamic>> getProfile(String email) {
    return _get('/users/$email/profile');
  }

  Future<bool> isUsernameAvailable(String email, String username) async {
    final data = await _get('/users/$email/profile/username-available', {'username': username});
    return data['available'] == true;
  }

  Future<Map<String, dynamic>> saveProfile({
    required String email,
    required String username,
    required String bio,
    required String? profileImagePath,
  }) {
    return _put('/users/$email/profile', {
      'username': username,
      'bio': bio,
      'profile_image_path': profileImagePath,
    });
  }

  Future<Map<String, dynamic>> saveTestResult(String email, Map<String, dynamic> testResult) {
    return _post('/users/$email/test-result', testResult);
  }

  Future<Map<String, dynamic>> getTestResult(String email) {
    return _get('/users/$email/test-result');
  }

  Future<List<String>> getFavorites(String email) async {
    final data = await _get('/users/$email/favorites');
    return List<String>.from(data['favoriteImages'] ?? const []);
  }

  Future<List<String>> addFavorite(String email, String imageUrl) async {
    final data = await _post('/users/$email/favorites', {'imageUrl': imageUrl});
    return List<String>.from(data['favoriteImages'] ?? const []);
  }

  Future<List<String>> removeFavorite(String email, String imageUrl) async {
    final data = await _delete('/users/$email/favorites', {'imageUrl': imageUrl});
    return List<String>.from(data['favoriteImages'] ?? const []);
  }

  Future<List<Map<String, dynamic>>> getDislikes(String email) async {
    final data = await _get('/users/$email/dislikes');
    return List<Map<String, dynamic>>.from(data['dislikes'] ?? const []);
  }

  Future<List<Map<String, dynamic>>> addDislike({
    required String email,
    required String description,
    required String category,
  }) async {
    final data = await _post('/users/$email/dislikes', {
      'description': description,
      'category': category,
    });
    return List<Map<String, dynamic>>.from(data['dislikes'] ?? const []);
  }

  Future<List<Map<String, dynamic>>> removeDislike(String email, String dislikeId) async {
    final data = await _delete('/users/$email/dislikes/$dislikeId');
    return List<Map<String, dynamic>>.from(data['dislikes'] ?? const []);
  }

  Future<List<Map<String, dynamic>>> clearDislikes(String email) async {
    final data = await _delete('/users/$email/dislikes');
    return List<Map<String, dynamic>>.from(data['dislikes'] ?? const []);
  }

  Future<List<Map<String, dynamic>>> getChats(String email) async {
    final data = await _get('/users/$email/chats');
    return List<Map<String, dynamic>>.from(data['chats'] ?? const []);
  }

  Future<Map<String, dynamic>> createChat(String email, {String? title}) {
    return _post('/users/$email/chats', {'title': title});
  }

  Future<void> deleteChat(String email, String chatId) async {
    await _delete('/users/$email/chats/$chatId');
  }

  Future<List<Map<String, dynamic>>> getMessages(String email, String chatId) async {
    final data = await _get('/users/$email/chats/$chatId/messages');
    return List<Map<String, dynamic>>.from(data['messages'] ?? const []);
  }

  Future<Map<String, dynamic>> sendAiChat({
    required String email,
    String? chatId,
    String message = '',
    String? imageBase64,
    String? imageMimeType,
    String? imagePath,
  }) {
    return _post('/ai/chat', {
      'email': email,
      'chatId': chatId,
      'message': message,
      'imageBase64': imageBase64,
      'imageMimeType': imageMimeType,
      'imagePath': imagePath,
    });
  }

  Future<String> previewPrompt(String email) async {
    final data = await _get('/ai/prompt-preview', {'email': email});
    return data['systemPrompt']?.toString() ?? '';
  }

  Future<List<Map<String, dynamic>>> searchMarketplaceByImage({
    String? imageUrl,
    String? imagePath,
    String? query,
  }) async {
    final data = await _post('/marketplace/search-by-image', {
      'imageUrl': imageUrl,
      'imagePath': imagePath,
      'query': query,
    });
    return List<Map<String, dynamic>>.from(data['results'] ?? const []);
  }
}
