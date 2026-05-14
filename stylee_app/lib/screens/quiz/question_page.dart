import 'package:flutter/material.dart';

/// Шаблон для страницы вопроса теста
class QuestionPage extends StatefulWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final VoidCallback onContinue;
  final bool canContinue;

  const QuestionPage({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
    required this.onContinue,
    this.canContinue = true,
  });

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  bool _isContinuing = false;

  void _handleContinue() {
    if (_isContinuing) return;

    setState(() => _isContinuing = true);
    widget.onContinue();
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

            // Questions/Answers — скролл!
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.children,
                ),
              ),
            ),

            // Continue Button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isContinuing || !widget.canContinue
                      ? null
                      : _handleContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isContinuing || !widget.canContinue
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
