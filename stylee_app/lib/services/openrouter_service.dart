import 'dart:convert';
import 'dart:typed_data';

import 'package:stylee_app/models/dislike.dart';
import 'package:stylee_app/services/backend_api_service.dart';
import 'package:stylee_app/utils/read_file_bytes.dart';

class OpenRouterService {
  final BackendApiService _backend = BackendApiService.instance;

  OpenRouterService();

  Future<String> getStyleAdvice(
    String userMessage, {
    required String userEmail,
    List<Dislike> dislikes = const [],
  }) async {
    final response = await _backend.sendAiChat(
      email: userEmail,
      message: userMessage,
    );
    return response['answer']?.toString() ?? '';
  }

  Future<String> getStyleAdviceWithImage({
    required String userEmail,
    required String userMessage,
    required String imagePath,
    List<Dislike> dislikes = const [],
  }) async {
    final bytes = await readFileBytes(imagePath);
    final mimeType = _guessMimeType(imagePath);
    return getStyleAdviceWithImageBytes(
      userEmail: userEmail,
      userMessage: userMessage,
      imageBytes: bytes,
      imageMimeType: mimeType,
    );


  String _guessMimeType(String pathOrName) {
    final lower = pathOrName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }
  }

  Future<String> getStyleAdviceWithImageBytes({
    required String userEmail,
    required String userMessage,
    required Uint8List imageBytes,
    required String imageMimeType,
  }) async {
    final base64Image = base64Encode(imageBytes);
    final response = await _backend.sendAiChat(
      email: userEmail,
      message: userMessage,
      imageBase64: base64Image,
      imageMimeType: imageMimeType,
    );
    return response['answer']?.toString() ?? '';
  }
}
