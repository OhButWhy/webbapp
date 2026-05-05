/// Модель для хранения информации о дизлайке
class Dislike {
  final String id;
  final String description; // что именно дизлайнули (краткое описание товара/образа)
  final String category; // категория (например: 'clothing', 'color', 'style')
  final DateTime createdAt; // когда был дизлайк

  Dislike({
    required this.id,
    required this.description,
    required this.category,
    required this.createdAt,
  });

  /// Преобразование в JSON для сохранения в Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'category': category,
      'createdAt': createdAt,
    };
  }

  /// Создание объекта из JSON из Firestore
  factory Dislike.fromMap(Map<String, dynamic> map) {
    return Dislike(
      id: map['id'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'general',
      createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  @override
  String toString() => 'Dislike(id: $id, description: $description, category: $category)';
}
