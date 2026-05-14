import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// HEX-код для некоторых цветов
const Map<String, String> _colorHexMap = {
  'Чёрный': '#000000',
  'Белый': '#FFFFFF',
  'Серый': '#808080',
  'Бежевый': '#F5F5DC',
  'Синий': '#0000FF',
  'Голубой': '#89CFF0',
  'Зелёный': '#008000',
  'Красный': '#FF0000',
  'Жёлтый': '#FFFF00',
  'Розовый': '#FFC0CB',
  'Фиолетовый': '#800080',
  'Коричневый': '#A52A2A',
  'Оранжевый': '#FFA500',
  'Другой': '#CCCCCC',
};

/// HEX-код для некоторых стилей
const Map<String, String> _styleHexMap = {
  'Классический': '#2C3E50',
  'Кэжуал': '#E67E22',
  'Спорт-шик': '#E91E63',
  'Бохо': '#8B4513',
  'Минимализм': '#BDC3C7',
  'Зондбе': '#6C3483',
  'Авангард': '#E74C3C',
  'Другое': '#95A5A6',
};

/// HEX-код для посадок
const Map<String, String> _fitHexMap = {
  'Свободная': '#27AE60',
  'Средняя': '#2980B9',
  'Облегающая': '#C0392B',
};

Map<String, String> _getHexMap(List<String> options) {
  if (options.contains('Чёрный') && options.contains('Белый')) return _colorHexMap;
  if (options.contains('Классический')) return _styleHexMap;
  if (options.contains('Свободная')) return _fitHexMap;
  return {};
}

/// Виджет множественного выбора с анимированными чипами
class MultiSelectWidget extends StatefulWidget {
  final List<String> options;
  final List<String> initialSelection;
  final String? hint;
  final Function(List<String> selectedItems) onSelectionChanged;

  const MultiSelectWidget({
    super.key,
    required this.options,
    required this.initialSelection,
    this.hint,
    required this.onSelectionChanged,
  });

  @override
  State<MultiSelectWidget> createState() => _MultiSelectWidgetState();
}

class _MultiSelectWidgetState extends State<MultiSelectWidget> {
  late List<String> _selectedItems;

  @override
  void initState() {
    super.initState();
    _selectedItems = List.from(widget.initialSelection);
  }

  void _toggleOption(String option) {
    setState(() {
      if (_selectedItems.contains(option)) {
        _selectedItems.remove(option);
      } else {
        _selectedItems.add(option);
      }
    });
    widget.onSelectionChanged(List.from(_selectedItems));
  }

  @override
  Widget build(BuildContext context) {
    final hexMap = _getHexMap(widget.options);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.hint != null) ...[
          Text(
            widget.hint!,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
        ],
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: widget.options.map((option) {
            final isSelected = _selectedItems.contains(option);
            final hex = hexMap[option];
            return _buildAnimatedChip(option, isSelected, hex);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAnimatedChip(String label, bool isSelected, String? hex) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _toggleOption(label),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFE91E63).withValues(alpha: 0.12)
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFE91E63)
                    : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFFE91E63).withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hex != null) ...[
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: _parseHex(hex),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? const Color(0xFFE91E63)
                        : Colors.black87,
                  ),
                ),
                const SizedBox(width: 6),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  child: isSelected
                      ? const Icon(
                          Icons.check_circle,
                          size: 18,
                          color: Color(0xFFE91E63),
                        )
                      : const SizedBox(width: 18, height: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _parseHex(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      if (clean.length == 6) {
        return Color(int.parse('FF$clean', radix: 16));
      }
    } catch (e) {
      developer.log('Invalid hex: $hex', level: 40, name: 'MultiSelectWidget');
    }
    return Colors.grey.shade400;
  }
}

/// Сохранение/загрузка выбранных значений в SharedPreferences
class SelectionStorage {
  static const String _prefKeyPrefix = 'quiz_selection_';

  static Future<List<String>> load(String questionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_prefKeyPrefix$questionId';
      final jsonStr = prefs.getString(key);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (e) {
      developer.log('Failed to load selection for $questionId: $e',
          level: 40, name: 'SelectionStorage');
    }
    return [];
  }

  static Future<bool> save(String questionId, List<String> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_prefKeyPrefix$questionId';
      final jsonStr = jsonEncode(items);
      await prefs.setString(key, jsonStr);
      return true;
    } catch (e) {
      developer.log('Failed to save selection for $questionId: $e',
          level: 40, name: 'SelectionStorage');
      return false;
    }
  }
}

/// HEX-сохранение: {название: HEX}
class HexSelectionStorage {
  static const String _hexPrefKey = 'quiz_selection_hex_';

  static Future<bool> save(String questionId, List<Map<String, String>> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_hexPrefKey$questionId';
      final jsonStr = jsonEncode(items);
      return await prefs.setString(key, jsonStr);
    } catch (e) {
      developer.log('Failed to save hex selection: $e', level: 40, name: 'HexSelectionStorage');
      return false;
    }
  }

  static Future<List<Map<String, String>>> load(String questionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_hexPrefKey$questionId';
      final jsonStr = prefs.getString(key);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        return decoded.map((e) => Map<String, String>.from(e as Map)).toList();
      }
    } catch (e) {
      developer.log('Failed to load hex selection: $e', level: 40, name: 'HexSelectionStorage');
    }
    return [];
  }
}
