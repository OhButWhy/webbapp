import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stylee_app/screens/quiz/quiz_wizard.dart';
import 'package:stylee_app/models/test_result.dart';
import 'package:stylee_app/screens/home_page.dart';
import 'package:stylee_app/services/backend_api_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SetupProfilePage extends StatefulWidget {
  final String email;
  final String password;

  const SetupProfilePage({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<SetupProfilePage> createState() => _SetupProfilePageState();
}

class _SetupProfilePageState extends State<SetupProfilePage> {
  final _backend = BackendApiService.instance;
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final _twoFactorPhoneController = TextEditingController();
  final _picker = ImagePicker();
  
  String? _profileImagePath;
  bool _isLoading = false;
  bool _checkingUsername = false;
  String? _usernameError;
  bool _enableTwoFactor = false;

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 75,
      );

      if (image != null) {
        setState(() => _profileImagePath = image.path);
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error picking image: $e');
    }
  }

  Future<bool> _checkUsername(String username) async {
    if (username.isEmpty) return false;

    return _awaitUsernameAvailability(username);
  }

  Future<bool> _awaitUsernameAvailability(String username) {
    return _backend.isUsernameAvailable(widget.email, username);
  }

  Future<void> _validateUsername() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      setState(() => _usernameError = null);
      return;
    }

    setState(() => _checkingUsername = true);
    
    final isAvailable = await _checkUsername(username);
    
    setState(() {
      _checkingUsername = false;
      _usernameError = isAvailable ? null : 'Этот ник уже занят';
    });
  }

  Future<void> _completeRegistration() async {
    if (_checkingUsername) return;

    setState(() => _isLoading = true);

    try {
      final username = _usernameController.text.trim();
      
      if (username.isEmpty) {
        setState(() {
          _isLoading = false;
          _usernameError = 'Введите ник';
        });
        return;
      }

      final isAvailable = await _checkUsername(username);
      if (!isAvailable) {
        setState(() {
          _isLoading = false;
          _usernameError = 'Этот ник уже занят';
        });
        return;
      }

      String? savedImagePath;
      if (_profileImagePath != null) {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'profile_${widget.email.replaceAll('@', '_').replaceAll('.', '_')}.jpg';
        savedImagePath = '${directory.path}/$fileName';
        
        final file = File(_profileImagePath!);
        if (file.existsSync()) {
          await file.copy(savedImagePath);
        }
      }

      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: widget.email,
        password: widget.password,
      );

      // Инициализировать юзера в бэкенде
      await _backend.bootstrapUser(widget.email);
      await _backend.saveProfile(
        email: widget.email,
        username: username,
        bio: _bioController.text.trim(),
        profileImagePath: savedImagePath,
      );

      // Начать прохождение теста
      final testResult = await Navigator.push<TestResult?>(
        context,
        MaterialPageRoute(
          builder: (context) => QuizWizard(
            existingResult: null,
            onComplete: (result) {
              Navigator.of(context).pop(result);
            },
          ),
        ),
      );

      // Сохранить результат теста если есть
      if (testResult != null) {
        await _saveTestResult(testResult);
      }

      if (_enableTwoFactor) {
        await _setupTwoFactorAuthentication();
      }

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _saveTestResult(TestResult result) async {
    try {
      await _backend.saveTestResult(widget.email, result.toMap());
    } catch (e) {
      print('Error saving test result: $e');
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

  Future<bool> _setupTwoFactorAuthentication() async {
    final phoneNumber = _twoFactorPhoneController.text.trim();
    if (phoneNumber.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Введите номер телефона для 2FA или отключите эту опцию')),
        );
      }
      return false;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return false;
    }

    try {
      final session = await user.multiFactor.getSession();
      final completer = Completer<bool>();

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        multiFactorSession: session,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            final assertion = PhoneMultiFactorGenerator.getAssertion(credential);
            await user.multiFactor.enroll(assertion, displayName: 'Phone');
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Не удалось включить 2FA: ${error.message ?? error.code}')),
            );
          }
        },
        codeSent: (String verificationId, int? resendToken) async {
          final smsCode = await _promptForSmsCode(
            title: 'Подтвердите 2FA',
            message: 'Мы отправили SMS на $phoneNumber. Введите код для включения двухфакторной аутентификации.',
          );

          if (smsCode == null || smsCode.isEmpty) {
            if (!completer.isCompleted) {
              completer.complete(false);
            }
            return;
          }

          try {
            final credential = PhoneAuthProvider.credential(
              verificationId: verificationId,
              smsCode: smsCode,
            );
            final assertion = PhoneMultiFactorGenerator.getAssertion(credential);
            await user.multiFactor.enroll(assertion, displayName: 'Phone');
            if (!completer.isCompleted) {
              completer.complete(true);
            }
          } catch (e) {
            if (!completer.isCompleted) {
              completer.complete(false);
            }
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Ошибка подтверждения 2FA: $e')),
              );
            }
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );

      return await completer.future.timeout(const Duration(minutes: 2), onTimeout: () => false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось включить 2FA: $e')),
        );
      }
      return false;
    }
  }

  Future<void> _skipSetup() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final randomUsername = 'user_${DateTime.now().millisecondsSinceEpoch}';
      
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: widget.email,
        password: widget.password,
      );

      // Инициализировать юзера в бэкенде с рандомным ником
      await _backend.bootstrapUser(widget.email);
      await _backend.saveProfile(
        email: widget.email,
        username: randomUsername,
        bio: '',
        profileImagePath: null,
      );

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    _twoFactorPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5E6E8),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: _isLoading ? null : () => Navigator.pop(context),
          ),
          actions: [
            TextButton(
              onPressed: _isLoading ? null : _skipSetup,
              child: const Text(
                'Пропустить',
                style: TextStyle(
                  color: Colors.pink,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Заголовок
              const Text(
                'Настройка профиля',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Расскажите о себе',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),
              // Аватарка
              Center(
                child: GestureDetector(
                  onTap: _isLoading ? null : _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: const Color(0xFFF8E8EA),
                        backgroundImage: _profileImagePath != null
                            ? FileImage(File(_profileImagePath!))
                            : null,
                        child: _profileImagePath == null
                            ? const Icon(
                                Icons.person_add,
                                size: 50,
                                color: Colors.pink,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.add,
                              size: 20,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Нажмите для выбора фото',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Username
              const Text(
                'Никнейм',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _usernameController,
                onChanged: (value) {
                  _validateUsername();
                },
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: 'Введите ваш ник',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: _checkingUsername
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : _usernameError != null
                          ? const Icon(Icons.error, color: Colors.red)
                          : _usernameController.text.isNotEmpty
                              ? const Icon(Icons.check, color: Colors.green)
                              : null,
                  errorText: _usernameError,
                ),
              ),
              const SizedBox(height: 24),
              // Bio
              const Text(
                'О себе (необязательно)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _bioController,
                enabled: !_isLoading,
                maxLines: 3,
                maxLength: 150,
                decoration: InputDecoration(
                  hintText: 'Fashion dreamer | OOTD everyday ✨',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _enableTwoFactor,
                onChanged: _isLoading
                    ? null
                    : (value) {
                        setState(() {
                          _enableTwoFactor = value;
                        });
                      },
                title: const Text(
                  'Двухфакторная аутентификация',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                subtitle: const Text('Необязательно: подтверждение входа через SMS'),
                activeColor: const Color(0xFFE91E63),
              ),
              if (_enableTwoFactor) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _twoFactorPhoneController,
                  enabled: !_isLoading,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Телефон в формате +79991234567',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(
                      Icons.phone_android_rounded,
                      color: Colors.pink.shade300,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'После включения вход будет подтверждаться кодом из SMS.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
              const SizedBox(height: 40),
              // Кнопка продолжить
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _completeRegistration,
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
                          'Продолжить',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
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
