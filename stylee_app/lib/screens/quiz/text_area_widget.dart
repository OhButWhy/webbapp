import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Виджет текстового поля с debounce-черновиком и тегами-подсказками
class TextAreaWidget extends StatefulWidget {
  final String initialValue;
  final String? placeholder;
  final int? maxChars;
  final List<String>? quickTags;
  final Function(String text) onChanged;
  final Function(String text) onSave;

  const TextAreaWidget({
    super.key,
    required this.initialValue,
    this.placeholder,
    this.maxChars = 1000,
    this.quickTags,
    required this.onChanged,
    required this.onSave,
  });

  @override
  State<TextAreaWidget> createState() => _TextAreaWidgetState();
}

class _TextAreaWidgetState extends State<TextAreaWidget> {
  late final TextEditingController _controller;
  Timer? _draftTimer;

  static const String _draftPrefix = 'quiz_draft_';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _loadDraft();
  }

  Future<void> _loadDraft() async {
    if (_controller.text.isNotEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_draftPrefix${widget.placeholder ?? 'default'}';
      final draft = prefs.getString(key);
      if (draft != null && draft.isNotEmpty && mounted) {
        _controller.text = draft;
        widget.onChanged(draft);
      }
    } catch (e) {
      developer.log('Failed to load draft: $e', level: 40, name: 'TextAreaWidget');
    }
  }

  void _scheduleDraftSave() {
    _draftTimer?.cancel();
    _draftTimer = Timer(const Duration(seconds: 3), () async {
      _saveDraft(_controller.text);
    });
  }

  Future<void> _saveDraft(String text) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_draftPrefix${widget.placeholder ?? 'default'}';
      await prefs.setString(key, text);
    } catch (e) {
      developer.log('Failed to save draft: $e', level: 40, name: 'TextAreaWidget');
    }
  }

  void _insertTag(String tag) {
    final text = _controller.text;
    final newText = text.isEmpty ? tag : '$text, $tag';
    _controller.text = newText;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
    _onTextChanged(newText);
  }

  void _onTextChanged(String text) {
    widget.onChanged(text);
    _scheduleDraftSave();
  }

  @override
  void dispose() {
    _draftTimer?.cancel();
    _saveDraft(_controller.text);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLen = _controller.text.length;
    final maxChars = widget.maxChars ?? 1000;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Текстовое поле
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: _controller,
            autofocus: false,
            maxLines: 6,
            maxLength: maxChars,
            textInputAction: TextInputAction.newline,
            keyboardType: TextInputType.multiline,
            autocorrect: true,
            enableSuggestions: true,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              hintText: widget.placeholder ?? 'Введите текст...',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              counterText: '',
            ),
            onChanged: _onTextChanged,
          ),
        ),

        // Счётчик символов
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '$currentLen/$maxChars',
                style: TextStyle(
                  fontSize: 12,
                  color: currentLen > maxChars * 0.9
                      ? Colors.orange.shade600
                      : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Теги-подсказки
        if (widget.quickTags != null && widget.quickTags!.isNotEmpty) ...[
          Text(
            'Быстрый ввод:',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.quickTags!.map((tag) {
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _insertTag(tag),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE91E63).withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFE91E63).withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_circle_outline, size: 14, color: const Color(0xFFE91E63)),
                        const SizedBox(width: 6),
                        Text(
                          tag,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFE91E63),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
