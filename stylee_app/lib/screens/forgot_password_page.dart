import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  final Function()? onTap;
  const ForgotPasswordPage({
    super.key,
    required this.onTap,
  });

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailTextController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  Future<void> resetPassword() async {
    final email = emailTextController.text.trim();
    
    if (email.isEmpty) {
      _showError('Пожалуйста, введите email адрес');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _emailSent = true;
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Письмо для восстановления пароля отправлено на ваш email'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        String message = 'Ошибка при отправке письма';
        
        if (e.code == 'user-not-found') {
          message = 'Пользователь с таким email не найден';
        } else if (e.code == 'invalid-email') {
          message = 'Некорректный email адрес';
        } else if (e.code == 'too-many-requests') {
          message = 'Слишком много попыток. Попробуйте позже';
        }
        
        _showError(message);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Неизвестная ошибка: $e');
      }
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ошибка'),
        content: Text(message),
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

                Icon(
                  Icons.mail_outline_rounded,
                  size: 100,
                  color: Colors.pink.shade300,
                ),

                const SizedBox(height: 50),
                Text(
                  "Восстановить пароль",
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 25),
                
                Text(
                  'Введите email адрес вашего аккаунта и мы отправим вам письмо для восстановления пароля',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 35),

                TextField(
                  controller: emailTextController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.pink.shade300,
                      ),
                    ),
                    hintText: 'Email',
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isLoading,
                ),

                const SizedBox(height: 25),

                GestureDetector(
                  onTap: _isLoading ? null : resetPassword,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.pink.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Отправить письмо',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                GestureDetector(
                  onTap: widget.onTap,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Вспомнили пароль? ',
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        'Вернуться на логин',
                        style: TextStyle(
                          color: Colors.pink.shade300,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
