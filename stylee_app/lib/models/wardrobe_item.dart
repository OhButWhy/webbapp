import 'package:cloud_firestore/cloud_firestore.dart';

/// Модель вещи в гардеробе
class WardrobeItem {
  final String id;
  final String imageUrl;
  final String name; // произвольное имя вещи
  final String sectionId; // ID секции, куда принадлежит
  final List<String> tags; // теги: color, type, season и т.д.
  final DateTime addedAt;

  WardrobeItem({
    required this.id,
    required this.imageUrl,
    this.name = '',
    this.sectionId = 'general', // 'general' — общий список по умолчанию
    this.tags = const [],
    required this.addedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'name': name,
      'sectionId': sectionId,
      'tags': tags,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory WardrobeItem.fromMap(Map<String, dynamic> map) {
    return WardrobeItem(
      id: map['id'] as String,
      imageUrl: map['imageUrl'] as String,
      name: map['name'] as String? ?? '',
      sectionId: map['sectionId'] as String? ?? 'general',
      tags: map['tags'] != null ? List<String>.from(map['tags']) : [],
      addedAt: map['addedAt'] != null
          ? DateTime.parse(map['addedAt'] as String)
          : DateTime.now(),
    );
  }

  factory WardrobeItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WardrobeItem(
      id: doc.id,
      imageUrl: data['imageUrl'] ?? '',
      name: data['name'] as String? ?? '',
      sectionId: data['sectionId'] as String? ?? 'general',
      tags: data['tags'] != null ? List<String>.from(data['tags']) : [],
      addedAt: data['addedAt'] != null
          ? DateTime.parse(data['addedAt'] as String)
          : DateTime.now(),
    );
  }
}
