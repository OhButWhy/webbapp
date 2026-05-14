import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  final Function()? onForgotPassword;
  const LoginPage({
    super.key,
    required this.onTap,
    this.onForgotPassword,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  bool _isLoading = false;

  Future<void> signIn() async {
    if (emailTextController.text.isEmpty || passwordTextController.text.isEmpty) {
      _showError('Заполните все поля');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailTextController.text.trim(),
        password: passwordTextController.text,
      );

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } on FirebaseAuthMultiFactorException catch (e) {
      try {
        final resolved = await _resolveMultiFactorSignIn(e);
        if (mounted) {
          setState(() => _isLoading = false);
        }

        if (!resolved && mounted) {
          _showError('Не удалось подтвердить второй фактор');
        }
      } catch (error) {
        if (mounted) {
          setState(() => _isLoading = false);
          _showError('Ошибка двухфакторной аутентификации: $error');
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        String message = 'Ошибка входа';
        if (e.code == 'user-not-found') {
          message = 'Пользователь не найден';
        } else if (e.code == 'wrong-password') {
          message = 'Неверный пароль';
        } else if (e.code == 'invalid-email') {
          message = 'Некорректный email';
        } else if (e.code == 'user-disabled') {
          message = 'Аккаунт заблокирован';
        }
        _showError(message);
      }
    }
  }

  Future<String?> _promptForSmsCode({
    required String title,
    required String message,
  }) async {
    final smsCodeController = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(message),
            const SizedBox(height: 16),
            TextField(
              controller: smsCodeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Код из SMS',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, smsCodeController.text.trim()),
            child: const Text('Подтвердить'),
          ),
        ],
      ),
    );
    smsCodeController.dispose();
    return code;
  }

  Future<bool> _resolveMultiFactorSignIn(FirebaseAuthMultiFactorException error) async {
    final resolver = error.resolver;
    final phoneHints = resolver.hints.whereType<PhoneMultiFactorInfo>().toList();
    if (phoneHints.isEmpty) {
      return false;
    }

    final phoneHint = phoneHints.first;
    final completer = Completer<bool>();

    await FirebaseAuth.instance.verifyPhoneNumber(
      multiFactorInfo: phoneHint,
      multiFactorSession: resolver.session,
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          final assertion = PhoneMultiFactorGenerator.getAssertion(credential);
          await resolver.resolveSignIn(assertion);
          if (!completer.isCompleted) {
            completer.complete(true);
          }
        } catch (e) {
          if (!completer.isCompleted) {
            completer.complete(false);
          }
        }
      },
      verificationFailed: (FirebaseAuthException error) {
        if (!completer.isCompleted) {
          completer.complete(false);
        }
        if (mounted) {
          _showError('Ошибка подтверждения второго фактора: ${error.message ?? error.code}');
        }
      },
      codeSent: (String verificationId, int? resendToken) async {
        final smsCode = await _promptForSmsCode(
          title: 'Подтверждение входа',
          message: 'На номер ${phoneHint.phoneNumber} отправлен SMS-код. Введите его, чтобы завершить вход.',
        );

        if (smsCode == null || smsCode.isEmpty) {
          if (!completer.isCompleted) {
            completer.complete(false);
          }
          return;
        }

        try {
          final phoneCredential = PhoneAuthProvider.credential(
            verificationId: verificationId,
            smsCode: smsCode,
          );
          final assertion = PhoneMultiFactorGenerator.getAssertion(phoneCredential);
          await resolver.resolveSignIn(assertion);
          if (!completer.isCompleted) {
            completer.complete(true);
          }
        } catch (e) {
          if (!completer.isCompleted) {
            completer.complete(false);
          }
          if (mounted) {
            _showError('Не удалось подтвердить второй фактор: $e');
          }
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );

    return await completer.future.timeout(const Duration(minutes: 2), onTimeout: () => false);
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    emailTextController.dispose();
    passwordTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6E8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                // logo
                Icon(
                  Icons.lock_rounded,
                  size: 100,
                  color: Colors.pink.shade300,
                ),

                const SizedBox(height: 50),
                // welcome back message
                Text(
                  "Welcome back!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Рады видеть вас снова",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 40),
                // email textfield
                TextField(
                  controller: emailTextController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: Colors.pink.shade300,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // password textfield
                TextField(
                  controller: passwordTextController,
                  obscureText: true,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: Colors.pink.shade300,
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                // sign in button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Войти',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),
                // forgot password
                TextButton(
                  onPressed: widget.onForgotPassword,
                  child: Text(
                    'Забыли пароль?',
                    style: TextStyle(
                      color: Colors.pink.shade400,
                      fontSize: 14,
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                // register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Нет аккаунта?',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: _isLoading ? null : widget.onTap,
                      child: Text(
                        'Регистрация',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFE91E63),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
