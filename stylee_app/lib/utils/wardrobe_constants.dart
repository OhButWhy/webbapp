import 'package:flutter/material.dart';

/// Все константы и данные для фильтров гардероба
class WardrobeConstants {
  // ═══════════════════════════════════════════════
  //  ФИЛЬТРЫ ПО ЦВЕТАМ
  // ═══════════════════════════════════════════════

  static const List<ColorFilter> colorFilters = [
    ColorFilter('Все', Colors.transparent, true),
    ColorFilter('Красный', Colors.red),
    ColorFilter('Синий', Colors.blue),
    ColorFilter('Зелёный', Colors.green),
    ColorFilter('Чёрный', Colors.black),
    ColorFilter('Белый', Colors.white),
    ColorFilter('Бежевый', Colors.amber),
    ColorFilter('Серый', Colors.grey),
  ];

  // ═══════════════════════════════════════════════
  //  ФИЛЬТРЫ ПО ТИПУ
  // ═══════════════════════════════════════════════

  static const List<TypeFilter> typeFilters = [
    TypeFilter('Все', Icons.filter_list, null),
    TypeFilter('Верх', Icons.accessibility_new, {'top'}),
    TypeFilter('Низ', Icons.short_text, {'bottom'}),
    TypeFilter('Обувь', Icons.shop, {'shoes'}),
    TypeFilter('Аксессуары', Icons.watch, {'accessory'}),
    TypeFilter('Верхняя одежда', Icons.downloading, {'outerwear'}),
    TypeFilter('Платья', Icons.checkroom, {'dress'}),
  ];

  // ═══════════════════════════════════════════════
  //  ФИЛЬТРЫ ПО СЕЗОНУ
  // ═══════════════════════════════════════════════

  static const List<String> seasonTags = [
    'Все',
    'Лето',
    'Зима',
    'Весна',
    'Осень',
    'Всесезонный',
  ];
}

/// Информация о цветовом фильтре
class ColorFilter {
  final String name;
  final Color color;
  final bool isDefault;

  const ColorFilter(this.name, this.color, [this.isDefault = false]);
}

/// Информация о тип-фильтре
class TypeFilter {
  final String name;
  final IconData icon;
  final Set<String>? tagMatch; // теги, которые должен содержать элемент

  const TypeFilter(this.name, this.icon, [this.tagMatch]);
}
