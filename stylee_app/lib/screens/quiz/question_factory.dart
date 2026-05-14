import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'city_search_widget.dart';
import 'multi_select_widget.dart';
import 'text_area_widget.dart';
import 'question_page.dart';

/// Фабрика для создания страниц вопросов
class QuestionFactory {
  /// Создать виджет вопроса по ID
  static Widget createQuestionPage({
    required String questionId,
    required Map<String, dynamic> questionData,
    required Map<String, dynamic> answers,
    required Function(Map<String, dynamic>) onContinue,
    required void Function(void Function()) setState,
  }) {
    final title = questionData['title'] ?? 'Вопрос';
    final subtitle = questionData['subtitle'];
    final type = questionData['type'] ?? 'text';
    final options = List<String>.from(questionData['options'] ?? []);
    final placeholder = questionData['placeholder'];

    switch (type) {
      case 'multi_select': {
        final existingItems = answers[questionId] is List
            ? List<String>.from(answers[questionId])
            : <String>[];
        answers[questionId] = existingItems;

        return _MultiSelectPage(
          questionId: questionId,
          title: title,
          subtitle: subtitle,
          options: options,
          initialSelection: existingItems,
          answers: answers,
          onContinue: onContinue,
        );
      }

      case 'single_select': {
        final current = answers[questionId] as String? ?? '';
        answers[questionId] = current;

        return QuestionPage(
          title: title,
          subtitle: subtitle,
          canContinue: current.isNotEmpty,
          onContinue: () => onContinue({questionId: answers[questionId]}),
          children: [
            const Text(
              'Выберите один вариант:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            ...options.map((option) => _buildRadioTile(
              option: option,
              selectedValue: answers[questionId] as String? ?? '',
              answers: answers,
              questionId: questionId,
              setState: setState,
            )),
          ],
        );
      }

      case 'city_select': {
        final existingCity = answers[questionId] as String? ?? '';

        return _CitySelectQuestionPage(
          questionId: questionId,
          existingCity: existingCity,
          title: title,
          subtitle: subtitle,
          answers: answers,
          onContinue: onContinue,
        );
      }

      case 'text': {
        final textValue = answers[questionId] as String? ?? '';
        final controller = TextEditingController(text: textValue);

        return QuestionPage(
          title: title,
          subtitle: subtitle,
          canContinue: textValue.isNotEmpty,
          onContinue: () {
            final result = controller.text;
            answers[questionId] = result;
            onContinue({questionId: result});
          },
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: placeholder ?? 'Введите ответ',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              controller: controller,
              onChanged: (val) {
                answers[questionId] = val;
                setState(() {});
              },
            ),
            const SizedBox(height: 12),
          ],
        );
      }

      case 'measurements': {
        final height = (answers['height'] ?? '').toString();
        final bust = (answers['bust'] ?? '').toString();
        final waist = (answers['waist'] ?? '').toString();
        final hips = (answers['hips'] ?? '').toString();

        final heightController = TextEditingController(
            text: height != '' && height != '0' ? height : '');
        final bustController = TextEditingController(
            text: bust != '' && bust != '0' ? bust : '');
        final waistController = TextEditingController(
            text: waist != '' && waist != '0' ? waist : '');
        final hipsController = TextEditingController(
            text: hips != '' && hips != '0' ? hips : '');

        return QuestionPage(
          title: title,
          subtitle: subtitle,
          canContinue: true,
          onContinue: () => onContinue({
            'height': double.tryParse(heightController.text) ?? 0,
            'bust': double.tryParse(bustController.text) ?? 0,
            'waist': double.tryParse(waistController.text) ?? 0,
            'hips': double.tryParse(hipsController.text) ?? 0,
          }),
          children: [
            _buildMeasurementField('Рост (см)', heightController),
            _buildMeasurementField('Обхват груди (см)', bustController),
            _buildMeasurementField('Обхват талии (см)', waistController),
            _buildMeasurementField('Обхват бёдер (см)', hipsController),
            const SizedBox(height: 12),
          ],
        );
      }

      case 'text_area': {
        final existingText = answers[questionId] as String? ?? '';

        return _TextAreaPage(
          questionId: questionId,
          title: title,
          subtitle: subtitle,
          initialValue: existingText,
          placeholder: placeholder,
          answers: answers,
          onContinue: onContinue,
        );
      }

      default:
        return QuestionPage(
          title: title,
          subtitle: subtitle,
          canContinue: false,
          onContinue: () => onContinue({}),
          children: [
            const Text('Неизвестный тип вопроса'),
          ],
        );
    }
  }

  static Widget _buildMeasurementField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  static Widget _buildRadioCircle(bool isSelected) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? const Color(0xFFE91E63) : Colors.transparent,
        border: Border.all(
          color: isSelected ? const Color(0xFFE91E63) : Colors.grey.shade400,
          width: isSelected ? 5 : 1.8,
        ),
      ),
    );
  }

  static Widget _buildRadioTile({
    required String option,
    required String selectedValue,
    required Map<String, dynamic> answers,
    required String questionId,
    required void Function(void Function()) setState,
  }) {
    final isSelected = selectedValue == option;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            answers[questionId] = option;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFE91E63).withValues(alpha: 0.08)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFE91E63)
                  : Colors.grey.shade300,
              width: isSelected ? 1.8 : 1,
            ),
          ),
          child: Row(
            children: [
              _buildRadioCircle(isSelected),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? const Color(0xFF333333)
                        : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Отдельная Stateful-страница для multi_select — чтобы избежать
/// бесконечных перерисовок от parent setState и управлять асинхронным сохранением
class _MultiSelectPage extends StatefulWidget {
  final String questionId;
  final String title;
  final String? subtitle;
  final List<String> options;
  final List<String> initialSelection;
  final Map<String, dynamic> answers;
  final Function(Map<String, dynamic>) onContinue;

  const _MultiSelectPage({
    required this.questionId,
    required this.title,
    this.subtitle,
    required this.options,
    required this.initialSelection,
    required this.answers,
    required this.onContinue,
  });

  @override
  State<_MultiSelectPage> createState() => _MultiSelectPageState();
}

class _MultiSelectPageState extends State<_MultiSelectPage> {
  List<String> _selectedItems = [];
  bool _isContinuing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedItems = List.from(widget.initialSelection);
  }

  /// Генерируем hint в зависимости от типа вопроса
  String? get _hint {
    final qId = widget.questionId;
    if (qId == 'favorite_colors' || qId == 'avoided_colors') {
      return 'Выберите 2–5 цветов для более точных рекомендаций';
    }
    if (qId == 'styles') {
      return 'Выберите 2–4 стиля, которые вам ближе';
    }
    return null;
  }

  void _onSelectionChanged(List<String> items) {
    setState(() {
      _selectedItems = items;
      _errorMessage = null;
    });
    widget.answers[widget.questionId] = items;

    // Сохраняем в SharedPreferences локально (fallback)
    SelectionStorage.save(widget.questionId, items);
  }

  Future<void> _handleContinue() async {
    if (_isContinuing || _selectedItems.isEmpty) return;

    setState(() {
      _isContinuing = true;
      _errorMessage = null;
    });

    try {
      // Локальное сохранение не должно блокировать переход дальше.
      final saved = await SelectionStorage.save(widget.questionId, _selectedItems)
          .timeout(const Duration(seconds: 2), onTimeout: () => false);

      // HEX-данные сохраняем отдельно и тоже не держим экран в ожидании.
      await HexSelectionStorage.save(
        widget.questionId,
        _selectedItems
            .map((name) => {
                  'name': name,
                  'hex': _ColorPickerHelper.getHexValue(widget.questionId, name),
                })
            .toList(),
      ).timeout(const Duration(seconds: 2), onTimeout: () => false);

      if (!saved) {
        // Если локальное сохранение не удалось — не блокируем пользователя
        _errorMessage = 'Не удалось сохранить предпочтения локально. Попробуйте ещё раз.';
        setState(() {
          _isContinuing = false;
        });
        // Показываем snackbar и всё равно переходим дальше
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_errorMessage!),
              backgroundColor: Colors.orange.shade700,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }

      if (mounted) {
        setState(() {
          _isContinuing = false;
        });
        widget.onContinue({widget.questionId: List<String>.from(_selectedItems)});
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isContinuing = false;
          _errorMessage = 'Не удалось сохранить предпочтения. Попробуйте ещё раз.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage!),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Повторить',
              textColor: Colors.white,
              onPressed: _handleContinue,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = _selectedItems.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF5E6E8),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed:
                        _isContinuing ? null : () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.subtitle!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Content (scrollable)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MultiSelectWidget(
                      options: widget.options,
                      initialSelection: _selectedItems,
                      hint: _hint,
                      onSelectionChanged: _onSelectionChanged,
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                size: 18, color: Colors.red.shade700),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                    fontSize: 13, color: Colors.red.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Continue button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isContinuing || !canContinue ? null : _handleContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isContinuing || !canContinue
                        ? Colors.grey.shade400
                        : const Color(0xFFE91E63),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: Colors.grey.shade400,
                    disabledForegroundColor: Colors.white70,
                  ),
                  child: _isContinuing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Продолжить',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Хелпер для получения HEX-значения
class _ColorPickerHelper {
  static String getHexValue(String questionId, String name) {
    const colorHex = {
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
    const styleHex = {
      'Классический': '#2C3E50',
      'Кэжуал': '#E67E22',
      'Спорт-шик': '#E91E63',
      'Бохо': '#8B4513',
      'Минимализм': '#BDC3C7',
      'Зондбе': '#6C3483',
      'Авангард': '#E74C3C',
      'Другое': '#95A5A6',
    };
    const fitHex = {
      'Свободная': '#27AE60',
      'Средняя': '#2980B9',
      'Облегающая': '#C0392B',
    };

    if (questionId.contains('color')) return colorHex[name] ?? '#CCCCCC';
    if (questionId.contains('style')) return styleHex[name] ?? '#95A5A6';
    if (questionId.contains('fit')) return fitHex[name] ?? '#95A5A6';
    return '#CCCCCC';
  }
}

/// Страница текстового поля (text_area) — отдельный StatefulWidget
class _TextAreaPage extends StatefulWidget {
  final String questionId;
  final String title;
  final String? subtitle;
  final String initialValue;
  final String? placeholder;
  final Map<String, dynamic> answers;
  final Function(Map<String, dynamic>) onContinue;

  const _TextAreaPage({
    required this.questionId,
    required this.title,
    this.subtitle,
    required this.initialValue,
    this.placeholder,
    required this.answers,
    required this.onContinue,
  });

  @override
  State<_TextAreaPage> createState() => _TextAreaPageState();
}

class _TextAreaPageState extends State<_TextAreaPage> {
  String _currentText = '';
  bool _isContinuing = false;
  String? _errorMessage;

  /// Теги-подсказки для особого поля
  static const List<String> _quickTags = [
    'Аллергия на шерсть',
    'Не люблю каблуки',
    'Предпочитаю свободный крой',
    'Не переношу синтетику',
    'Люблю длинные платья',
    'Аллергия на латекс',
    'Предпочитаю минимализм',
  ];

  @override
  void initState() {
    super.initState();
    _currentText = widget.initialValue;
  }

  void _onTextChanged(String text) {
    setState(() {
      _currentText = text;
      _errorMessage = null;
    });
    widget.answers[widget.questionId] = text;
  }

  Future<void> _handleContinue() async {
    if (_isContinuing) return;
    setState(() {
      _isContinuing = true;
      _errorMessage = null;
    });
    try {
      // Сохраняем локально
      final text = _currentText.trim();
      await TextAreaDraftStorage.save(widget.questionId, text);

      if (mounted) {
        widget.onContinue({widget.questionId: text});
      }
    } catch (e) {
      developer.log('TextArea save error: $e', level: 40, name: '_TextAreaPage');
      if (mounted) {
        setState(() {
          _isContinuing = false;
          _errorMessage = 'Не удалось сохранить. Попробуйте ещё раз.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage!),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Повторить',
              textColor: Colors.white,
              onPressed: _handleContinue,
            ),
          ),
        );
      }
    }
  }

  void _skip() {
    if (_isContinuing) return;
    widget.onContinue({widget.questionId: _currentText.trim()});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6E8),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: _isContinuing ? null : () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.subtitle!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextAreaWidget(
                      initialValue: _currentText,
                      placeholder: widget.placeholder,
                      quickTags: _quickTags,
                      onChanged: _onTextChanged,
                      onSave: (text) {},
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                size: 18, color: Colors.red.shade700),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                    fontSize: 13, color: Colors.red.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isContinuing ? null : _handleContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isContinuing
                            ? Colors.grey.shade400
                            : const Color(0xFFE91E63),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                        disabledBackgroundColor: Colors.grey.shade400,
                        disabledForegroundColor: Colors.white70,
                      ),
                      child: _isContinuing
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Продолжить',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: TextButton(
                      onPressed: _isContinuing ? null : _skip,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade500,
                      ),
                      child: const Text(
                        'Пропустить',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Сохранение черновика text_area
class TextAreaDraftStorage {
  static Future<bool> save(String questionId, String text) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('quiz_draft_$questionId', text);
      return true;
    } catch (e) {
      developer.log('Failed to save text area draft: $e', level: 40, name: 'TextAreaDraftStorage');
      return false;
    }
  }

  static Future<String> load(String questionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('quiz_draft_$questionId') ?? '';
    } catch (e) {
      developer.log('Failed to load draft: $e', level: 40, name: 'TextAreaDraftStorage');
      return '';
    }
  }
}

/// Страница вопроса с поиском города (отдельный StatefulWidget чтобы избежать
/// бесконечных перерисовок от parent setState)
class _CitySelectQuestionPage extends StatefulWidget {
  final String questionId;
  final String existingCity;
  final String title;
  final String? subtitle;
  final Map<String, dynamic> answers;
  final Function(Map<String, dynamic>) onContinue;

  const _CitySelectQuestionPage({
    required this.questionId,
    required this.existingCity,
    required this.title,
    required this.subtitle,
    required this.answers,
    required this.onContinue,
  });

  @override
  State<_CitySelectQuestionPage> createState() => _CitySelectQuestionPageState();
}

class _CitySelectQuestionPageState extends State<_CitySelectQuestionPage> {
  CityResult? _selectedCity;
  bool _isContinuing = false;

  void _onCitySelected(CityResult city) {
    setState(() {
      _selectedCity = city;
    });
    widget.answers[widget.questionId] = '${city.name}, ${city.displayName.split(',').take(2).skip(1).join(',').trim()}';
  }

  void _handleContinue() {
    if (_isContinuing || _selectedCity == null) return;
    setState(() => _isContinuing = true);
    widget.onContinue({
      widget.questionId: _selectedCity!.displayName,
    });
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = _selectedCity != null;
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6E8),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: _isContinuing
                        ? null
                        : () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.subtitle!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // City search (scrollable)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CitySearchWidget(
                      initialValue: widget.existingCity,
                      onCitySelected: _onCitySelected,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Continue button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isContinuing || !canContinue ? null : _handleContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isContinuing || !canContinue
                        ? Colors.grey.shade400
                        : const Color(0xFFE91E63),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: Colors.grey.shade400,
                    disabledForegroundColor: Colors.white70,
                  ),
                  child: _isContinuing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Продолжить',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
