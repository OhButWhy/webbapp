import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stylee_app/auth/login_or_register.dart';
import 'package:stylee_app/screens/home_page.dart';
import 'package:stylee_app/screens/onboarding_test_screen.dart';
import 'package:stylee_app/models/test_result.dart';
import 'package:stylee_app/services/backend_api_service.dart';

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
  final _backend = BackendApiService.instance;
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
    await _backend.bootstrapUser(user.email!);
    final profile = await _backend.getProfile(user.email!);
    setState(() {
      _loading = false;
      _hasTestResult = profile['testResult'] != null;
    });
  }

  /// Сохраняет результат теста персонализации в Firestore (Users/{email}/testResult)
  /// Используется merge, чтобы не затереть другие поля пользователя
  void _onTestComplete(TestResult result) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _backend.saveTestResult(user.email!, result.toMap());
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