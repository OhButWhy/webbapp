import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class EditorPage extends StatefulWidget {
  const EditorPage({super.key});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final ImagePicker _picker = ImagePicker();
  String? _selectedImagePath;
  final _captionController = TextEditingController();
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null && mounted) {
      setState(() => _selectedImagePath = image.path);
    }
  }

  Future<void> _publishPost() async {
    if (_selectedImagePath == null || _selectedImagePath!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите фото для публикации')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      // Копируем фото в директорию приложения
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'post_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = '${directory.path}/$fileName';
      
      final file = File(_selectedImagePath!);
      if (file.existsSync()) {
        await file.copy(savedPath);
      }

      // Сохраняем пост в Firestore
      await FirebaseFirestore.instance.collection('posts').add({
        'userEmail': currentUser.email,
        'imageUrl': savedPath,
        'caption': _captionController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'Likes': [],
      });

      if (mounted) {
        setState(() {
          _selectedImagePath = null;
          _captionController.clear();
          _isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Пост опубликован! ✨'),
            backgroundColor: Colors.green,
          ),
        );

        // Возвращаемся на главную страницу (ленту)
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка публикации: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
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
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Editor',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          actions: [
            if (_selectedImagePath != null)
              TextButton(
                onPressed: _isUploading ? null : _publishPost,
                child: _isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Опубликовать',
                        style: TextStyle(
                          color: Color(0xFFE91E63),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
          ],
        ),
        body: _selectedImagePath == null ? _buildEmptyState() : _buildEditor(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.edit_outlined,
              size: 80,
              color: Colors.pink.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              'Редактор образов',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Выберите фото для редактирования\nи публикации',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo_library),
              label: const Text('Выбрать фото'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditor() {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              // Фоновые искры
              Positioned.fill(
                child: CustomPaint(painter: _SparklesPainter()),
              ),
              // Изображение по центру
              Center(
                child: Container(
                  width: 300,
                  height: 400,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      File(_selectedImagePath!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Поле для описания
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Описание (необязательно)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _captionController,
                maxLines: 3,
                maxLength: 150,
                decoration: InputDecoration(
                  hintText: 'Добавьте описание к вашему образу...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SparklesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final random = [
      Offset(size.width * 0.8, size.height * 0.1),
      Offset(size.width * 0.15, size.height * 0.3),
      Offset(size.width * 0.9, size.height * 0.5),
      Offset(size.width * 0.1, size.height * 0.7),
      Offset(size.width * 0.85, size.height * 0.8),
    ];

    for (final offset in random) {
      canvas.save();
      canvas.translate(offset.dx, offset.dy);
      canvas.drawPath(_createStar(8), paint);
      canvas.restore();
    }
  }

  Path _createStar(double size) {
    final path = Path();
    path.moveTo(0, -size);
    path.lineTo(size * 0.2, -size * 0.2);
    path.lineTo(size, 0);
    path.lineTo(size * 0.2, size * 0.2);
    path.lineTo(0, size);
    path.lineTo(-size * 0.2, size * 0.2);
    path.lineTo(-size, 0);
    path.lineTo(-size * 0.2, -size * 0.2);
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}