import 'package:flutter/material.dart';
import 'package:stylee_app/models/test_result.dart';
import 'question_factory.dart';
import 'quiz_questions.dart';

/// Экран для прохождения теста пошагово
class QuizWizard extends StatefulWidget {
  final TestResult? existingResult;
  final void Function(TestResult result) onComplete;

  const QuizWizard({
    super.key,
    this.existingResult,
    required this.onComplete,
  });

  @override
  State<QuizWizard> createState() => _QuizWizardState();
}

class _QuizWizardState extends State<QuizWizard> {
  int _currentQuestionIndex = 0;
  Map<String, dynamic> _answers = {};
  bool _isFinishing = false;

  @override
  void initState() {
    super.initState();
    // Загрузить существующие ответы если есть
    if (widget.existingResult != null) {
      _answers = {
        'height': widget.existingResult?.height,
        'bust': widget.existingResult?.bust,
        'waist': widget.existingResult?.waist,
        'hips': widget.existingResult?.hips,
        'city': widget.existingResult?.city,
        'preferredStyles': widget.existingResult?.preferredStyles,
        'favoriteColors': widget.existingResult?.favoriteColors,
        'avoidedColors': widget.existingResult?.avoidedColors,
        'fitPreference': widget.existingResult?.fitPreference,
        'specialNotes': widget.existingResult?.specialNotes,
      };
    }
  }

  void _handleAnswer(Map<String, dynamic> answer) {
    setState(() {
      _answers.addAll(answer);
      _currentQuestionIndex++;
    });
  }

  void _finishQuiz() {
    // Собрать все данные в TestResult
    final result = TestResult(
      height: _answers['height'] != null ? double.tryParse(_answers['height'].toString()) : null,
      bust: _answers['bust'] != null ? double.tryParse(_answers['bust'].toString()) : null,
      waist: _answers['waist'] != null ? double.tryParse(_answers['waist'].toString()) : null,
      hips: _answers['hips'] != null ? double.tryParse(_answers['hips'].toString()) : null,
      city: _answers['city'] as String?,
      preferredStyles: _answers['preferredStyles'] is List ? List<String>.from(_answers['preferredStyles']!) : null,
      favoriteColors: _answers['favoriteColors'] is List ? List<String>.from(_answers['favoriteColors']!) : null,
      avoidedColors: _answers['avoidedColors'] is List ? List<String>.from(_answers['avoidedColors']!) : null,
      fitPreference: _answers['fitPreference'] as String?,
      specialNotes: _answers['specialNotes'] as String?,
    );
    widget.onComplete(result);
  }

  @override
  Widget build(BuildContext context) {
    if (_currentQuestionIndex >= QuizQuestions.questions.length) {
      if (!_isFinishing) {
        _isFinishing = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _finishQuiz();
          }
        });
      }
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final questionData = QuizQuestions.questions[_currentQuestionIndex];
    final questionId = questionData['id'] as String;

    return QuestionFactory.createQuestionPage(
      questionId: questionId,
      questionData: questionData,
      answers: _answers,
      onContinue: _handleAnswer,
      setState: (callback) => setState(callback),
    );
  }
}
