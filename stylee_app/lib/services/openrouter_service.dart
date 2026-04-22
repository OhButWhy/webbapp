import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:stylee_app/models/dislike.dart';

class OpenRouterService {
  final String _apiKey = dotenv.env['OPENROUTER_API_KEY'] ?? '';
  
  /// Вспомогательный сервис для работы с дизлайками (ленивая инициализация)
  late DislikeService _dislikeService;

  OpenRouterService() {
    _dislikeService = DislikeService();
  }

  /// Текстовый запрос к ИИ-стилисту
  /// 
  /// Parameters:
  ///   - userMessage: сообщение пользователя
  ///   - dislikes: список дизлайков пользователя (опционально)
  Future<String> getStyleAdvice(
    String userMessage, {
    List<Dislike> dislikes = const [],
  }) async {
    if (_apiKey.isEmpty) {
      return '❌ Ошибка: API ключ не настроен. Добавьте OPENROUTER_API_KEY в файл .env';
    }

    const String model = 'qwen/qwen-vl-plus';

    print('🔍 DEBUG: Отправляю запрос к Qwen-VL (текст)...');

    final response = await http.post(
      Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
        'HTTP-Referer': 'https://stylee-app.com',
        'X-Title': 'Stylee App',
      },
      body: jsonEncode({
        'model': model,
        'messages': [
          {
            'role': 'system',
            'content': _buildSystemPrompt(dislikes)
          },
          {'role': 'user', 'content': userMessage},
        ],
        'temperature': 0.7,
        'max_tokens': 1000,
      }),
    );

    print('📡 DEBUG: Статус код: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      return '❌ Ошибка ${response.statusCode}: ${response.body}';
    }
  }

  /// Запрос к ИИ-стилисту с изображением
  /// 
  /// Parameters:
  ///   - userMessage: сообщение пользователя
  ///   - imagePath: путь к файлу изображения
  ///   - dislikes: список дизлайков пользователя (опционально)
  Future<String> getStyleAdviceWithImage({
    required String userMessage,
    required String imagePath,
    List<Dislike> dislikes = const [],
  }) async {
    if (_apiKey.isEmpty) {
      return '❌ Ошибка: API ключ не настроен. Добавьте OPENROUTER_API_KEY в файл .env';
    }

    const String model = 'qwen/qwen-vl-plus';

    print('🔍 DEBUG: Отправляю запрос к Qwen-VL с изображением...');

    // Конвертируем изображение в base64
    final file = File(imagePath);
    if (!file.existsSync()) {
      return '❌ Ошибка: файл изображения не найден';
    }

    final bytes = await file.readAsBytes();
    final base64Image = base64Encode(bytes);

    // Определяем формат изображения
    String mimeType = 'image/jpeg';
    if (imagePath.toLowerCase().endsWith('.png')) {
      mimeType = 'image/png';
    } else if (imagePath.toLowerCase().endsWith('.webp')) {
      mimeType = 'image/webp';
    }

    final response = await http.post(
      Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
        'HTTP-Referer': 'https://stylee-app.com',
        'X-Title': 'Stylee App',
      },
      body: jsonEncode({
        'model': model,
        'messages': [
          {
            'role': 'system',
            'content': _buildSystemPrompt(dislikes)
          },
          {
            'role': 'user',
            'content': [
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:$mimeType;base64,$base64Image',
                },
              },
              {
                'type': 'text',
                'text': userMessage.isEmpty
                    ? 'Опиши эту одежду и дай стилистические рекомендации. Что подойдёт к этому образу?'
                    : userMessage,
              },
            ],
          },
        ],
        'temperature': 0.7,
        'max_tokens': 1000,
      }),
    );

    print('📡 DEBUG: Статус код: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      return '❌ Ошибка ${response.statusCode}: ${response.body}';
    }
  }

  /// Построить системный промпт с учетом дизлайков пользователя
  /// 
  /// Parameters:
  ///   - dislikes: список дизлайков для исключения из рекомендаций
  /// 
  /// Returns: String (полный системный промпт)
  String _buildSystemPrompt(List<Dislike> dislikes) {
    final basePrompt = '''Ты ИИ-стилист для приложения Stylee. Отвечай ТОЛЬКО на русском языке.

Твоя задача — анализировать одежду на фото и помогать подбирать образы.

ПРАВИЛА:
1. Если получено фото — опиши что видишь (цвет, фасон, стиль, тип одежды)
2. Давай конкретные рекомендации по сочетанию
3. Учитывай occasion (мероприятие), сезон, погоду
4. Предлагай дополнительные элементы гардероба
5. Будь дружелюбной и стильной 😊
6. Используй эмодзи для наглядности''';

    // Добавляем раздел с исключениями, если есть дизлайки
    final excludeSection = _dislikeService.buildExcludeSection(dislikes);

    return basePrompt + excludeSection;
  }

Пример ответа на фото:
"Вижу синее платье миди с V-образным вырезом 👗

Отлично подойдёт для:
🍷 Свидания в ресторане
🎉 Вечеринки с друзьями
💼 Офиса (с пиджаком)

Рекомендую дополнить:
👠 Бежевые лодочки на каблуке
👜 Маленькая сумочка-кроссбоди
✨ Минималистичные серьги-пусеты

Цветовая гамма: синий + бежевый + золото ✨"
''';
}
