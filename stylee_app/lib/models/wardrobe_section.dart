/// Модель секции гардероба (папки/категории)
class WardrobeSection {
  /// Уникальный ID секции
  final String id;

  /// Название секции (макс. 30 символов)
  final String name;

  /// Иконка-эмодзи
  final String icon;

  /// Цвет фона иконки (hex-цвет)
  final int iconColor;

  /// true — системная секция ('general' — общий список)
  final bool isSystem;

  /// ID вещей в этой секции
  final List<String> itemIds;

  /// Порядок секций (для drag&drop)
  final int order;

  /// Дата создания
  final DateTime createdAt;

  static const int _defaultIconColor = 0xFFD4A5B7;

  WardrobeSection({
    required this.id,
    required this.name,
    this.icon = '👗',
    this.iconColor = _defaultIconColor,
    this.isSystem = false,
    this.itemIds = const [],
    required this.order,
    required this.createdAt,
  });

  /// Создать системную секцию (общий список)
  factory WardrobeSection.general({required String id}) {
    return WardrobeSection(
      id: id,
      name: 'Общий список',
      icon: '📁',
      iconColor: 0xFF9E9E9E,
      isSystem: true,
      itemIds: const [],
      order: -1,
      createdAt: DateTime.now(),
    );
  }

  /// Создать кастомную секцию
  factory WardrobeSection.custom({
    required String id,
    required String name,
    String icon = '👗',
    int iconColor = _defaultIconColor,
    int order = 0,
  }) {
    return WardrobeSection(
      id: id,
      name: name.length > 30 ? name.substring(0, 30) : name,
      icon: icon,
      iconColor: iconColor,
      isSystem: false,
      itemIds: const [],
      order: order,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'iconColor': iconColor,
      'isSystem': isSystem,
      'itemIds': itemIds,
      'order': order,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory WardrobeSection.fromMap(Map<String, dynamic> map) {
    return WardrobeSection(
      id: map['id'] as String,
      name: map['name'] as String? ?? 'Без названия',
      icon: map['icon'] as String? ?? '👗',
      iconColor: (map['iconColor'] as num?)?.toInt() ?? _defaultIconColor,
      isSystem: map['isSystem'] as bool? ?? false,
      itemIds: map['itemIds'] != null ? List<String>.from(map['itemIds']) : [],
      order: (map['order'] as num?)?.toInt() ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }

  WardrobeSection copyWith({
    String? id,
    String? name,
    String? icon,
    int? iconColor,
    bool? isSystem,
    List<String>? itemIds,
    int? order,
    DateTime? createdAt,
  }) {
    return WardrobeSection(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      isSystem: isSystem ?? this.isSystem,
      itemIds: itemIds ?? this.itemIds,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
