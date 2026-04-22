import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stylee_app/auth/login_or_register.dart';
import 'package:stylee_app/screens/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stylee_app/screens/onboarding_test_screen.dart';
import 'package:stylee_app/models/test_result.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // Пользователь залогинен — проверяем наличие результата теста
            return const UserGate();
          } else {
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}

class UserGate extends StatefulWidget {
  const UserGate({super.key});

  @override
  State<UserGate> createState() => _UserGateState();
}

class _UserGateState extends State<UserGate> {
  bool _loading = true;
  bool _hasTestResult = false;

  @override
  void initState() {
    super.initState();
    _checkTestResult();
  }

  Future<void> _checkTestResult() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _loading = false;
        _hasTestResult = false;
      });
      return;
    }
    final docRef = FirebaseFirestore.instance.collection('Users').doc(user.email);
    final doc = await docRef.get();
    final data = doc.data();
    // Инициализируем единое избранное для нового проекта.
    if (data == null || data['favoriteImages'] == null) {
      await docRef.set({'favoriteImages': <String>[]}, SetOptions(merge: true));
    }
    // Инициализируем дизлайки для новых пользователей
    if (data == null || data['dislikes'] == null) {
      await docRef.set({'dislikes': <Map<String, dynamic>>[]}, SetOptions(merge: true));
    }
    setState(() {
      _loading = false;
      _hasTestResult = data != null && data['testResult'] != null;
    });
  }

  /// Сохраняет результат теста персонализации в Firestore (Users/{email}/testResult)
  /// Используется merge, чтобы не затереть другие поля пользователя
  void _onTestComplete(TestResult result) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance.collection('Users').doc(user.email).set({
      'testResult': result.toMap(),
    }, SetOptions(merge: true));
    // После сохранения результата теста — возвращаем пользователя в основной flow
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!_hasTestResult) {
      return OnboardingTestScreen(onComplete: _onTestComplete);
    }
    return const HomePage();
  }
}