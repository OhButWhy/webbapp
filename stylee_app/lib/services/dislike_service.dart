import 'package:stylee_app/services/backend_api_service.dart';
import 'package:stylee_app/models/dislike.dart';

/// Сервис для управления дизлайками пользователя
/// 
/// Ответственность:
/// - Сохранение дизлайков в Firestore
/// - Загрузка дизлайков пользователя
/// - Построение фильтра для системного промпта ИИ
class DislikeService {
  final BackendApiService _backend = BackendApiService.instance;

  /// Сохранить новый дизлайк для пользователя
  /// 
  /// Parameters:
  ///   - userEmail: email пользователя (ключ в Users коллекции)
  ///   - description: краткое описание того, что дизлайнули (например: "розовые брюки")
  ///   - category: категория дизлайка (clothing, color, style, pattern, brand)
  /// 
  /// Returns: Future<void>
  Future<void> saveDisilike({
    required String userEmail,
    required String description,
    required String category,
  }) async {
    try {
      final dislike = Dislike(
        id: description.toLowerCase().replaceAll(' ', '_'), // простой ID на основе описания
        description: description,
        category: category,
        createdAt: DateTime.now(),
      );

      await _backend.addDislike(
        email: userEmail,
        description: dislike.description,
        category: dislike.category,
      );

      print('Дизлайк сохранён: $description');
    } catch (e) {
      print('Ошибка сохранения дизлайка: $e');
      rethrow;
    }
  }

  /// Получить список всех дизлайков пользователя
  /// 
  /// Parameters:
  ///   - userEmail: email пользователя
  /// 
  /// Returns: List<Dislike> (пустой список, если нет дизлайков)
  Future<List<Dislike>> getDislikes(String userEmail) async {
    try {
      final dislikesList = await _backend.getDislikes(userEmail);
      return dislikesList.map((d) => Dislike.fromMap(d)).toList();
    } catch (e) {
      print('Ошибка загрузки дизлайков: $e');
      return [];
    }
  }

  /// Построить раздел для системного промпта на основе дизлайков
  /// 
  /// Используется в OpenRouterService для фильтрации рекомендаций
  /// 
  /// Parameters:
  ///   - dislikes: список дизлайков пользователя
  /// 
  /// Returns: String (раздел текста для промпта, может быть пустым)
  String buildExcludeSection(List<Dislike> dislikes) {
    if (dislikes.isEmpty) {
      return '';
    }

    final excludeList = dislikes
        .map((d) => '• ${d.description} (${d.category})')
        .join('\n');

    return '''

ИСКЛЮЧЕНИЯ (пользователь отметил как неподходящее):
$excludeList

Избегай рекомендовать похожие варианты. Это очень важно для пользовательского опыта!''';
  }

  /// Удалить дизлайк (опционально, для будущего)
  /// 
  /// Parameters:
  ///   - userEmail: email пользователя
  ///   - dislikeId: ID дизлайка для удаления
  /// 
  /// Returns: Future<void>
  Future<void> removeDisilike({
    required String userEmail,
    required String dislikeId,
  }) async {
    try {
      final dislikes = await getDislikes(userEmail);
      final dislikeToRemove = dislikes.firstWhere(
        (d) => d.id == dislikeId,
        orElse: () => throw Exception('Дизлайк не найден'),
      );

      await _backend.removeDislike(userEmail, dislikeToRemove.id);

      print('Дизлайк удалён: $dislikeId');
    } catch (e) {
      print('Ошибка удаления дизлайка: $e');
      rethrow;
    }
  }

  /// Очистить все дизлайки (опционально, для сброса профиля)
  Future<void> clearAllDislikes(String userEmail) async {
    try {
      await _backend.clearDislikes(userEmail);

      print('Все дизлайки очищены');
    } catch (e) {
      print('Ошибка очистки дизлайков: $e');
      rethrow;
    }
  }
}
