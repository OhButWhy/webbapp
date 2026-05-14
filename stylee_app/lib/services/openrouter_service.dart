import 'dart:convert';
import 'dart:io';

import 'package:stylee_app/models/dislike.dart';
import 'package:stylee_app/services/backend_api_service.dart';

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
    final file = File(imagePath);
    if (!file.existsSync()) {
      return '❌ Ошибка: файл изображения не найден';
    }

    final bytes = await file.readAsBytes();
    final base64Image = base64Encode(bytes);
    String mimeType = 'image/jpeg';
    if (imagePath.toLowerCase().endsWith('.png')) {
      mimeType = 'image/png';
    } else if (imagePath.toLowerCase().endsWith('.webp')) {
      mimeType = 'image/webp';
    }

    final response = await _backend.sendAiChat(
      email: userEmail,
      message: userMessage,
      imageBase64: base64Image,
      imageMimeType: mimeType,
      imagePath: imagePath,
    );
    return response['answer']?.toString() ?? '';
  }
}
