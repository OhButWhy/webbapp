import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stylee_app/models/test_result.dart';
import 'package:stylee_app/screens/quiz/quiz_wizard.dart';

class WardrobeQuizCard extends StatelessWidget {
  final bool hasCompletedTest;
  final User currentUser;
  final CollectionReference usersCollection;
  final Function(TestResult) onQuizComplete;

  const WardrobeQuizCard({
    super.key,
    required this.hasCompletedTest,
    required this.currentUser,
    required this.usersCollection,
    required this.onQuizComplete,
  });

  void _openQuiz(BuildContext context, {TestResult? existingResult}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizWizard(
          existingResult: existingResult,
          onComplete: (newResult) {
            onQuizComplete(newResult);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: hasCompletedTest ? usersCollection.doc(currentUser.email).get() : null,
      builder: (context, snapshot) {
        TestResult? existingResult;
        if (hasCompletedTest && snapshot.hasData && snapshot.data!.data() != null) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data != null && data['testResult'] != null) {
            existingResult = TestResult.fromMap(data['testResult'] as Map<String, dynamic>);
          }
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GestureDetector(
            onTap: () => _openQuiz(context, existingResult: existingResult),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE8A0BF), Color(0xFFE8A0BF), Color(0xFFFFC1D6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE8A0BF).withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.auto_fix_high_outlined, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasCompletedTest
                              ? 'Перепройти тест персонализации'
                              : 'Тест персонализации',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          hasCompletedTest
                              ? 'Обновите свой стиль и получайте точные рекомендации'
                              : 'Узнайте свой стиль — AI подберёт образы',
                          style: const TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
