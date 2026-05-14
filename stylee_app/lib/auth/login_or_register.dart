import 'package:flutter/material.dart';
import 'package:stylee_app/screens/login_page.dart';
import 'package:stylee_app/screens/register_page.dart';
import 'package:stylee_app/screens/forgot_password_page.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  // Страницы: 0 = Login, 1 = Register, 2 = Forgot Password
  int _currentPage = 0;

  // Переключение на страницу регистрации/логина
  void togglePages() {
    setState(() {
      _currentPage = _currentPage == 0 ? 1 : 0;
    });
  }

  // Переключение на страницу восстановления пароля
  void goToForgotPassword() {
    setState(() {
      _currentPage = 2;
    });
  }

  // Возврат на логин со страницы восстановления пароля
  void backToLogin() {
    setState(() {
      _currentPage = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentPage) {
      case 0:
        return LoginPage(
          onTap: togglePages,
          onForgotPassword: goToForgotPassword,
        );
      case 1:
        return RegisterPage(onTap: togglePages);
      case 2:
        return ForgotPasswordPage(onTap: backToLogin);
      default:
        return LoginPage(
          onTap: togglePages,
          onForgotPassword: goToForgotPassword,
        );
    }
  }
}