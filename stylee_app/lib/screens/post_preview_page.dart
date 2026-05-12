import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class PostPreviewPage extends StatefulWidget {
  final String imagePath;
  final VoidCallback? onFinish;

  const PostPreviewPage({super.key, required this.imagePath, this.onFinish});

  @override
  State<PostPreviewPage> createState() => _PostPreviewPageState();
}

class _PostPreviewPageState extends State<PostPreviewPage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final _captionController = TextEditingController();
  bool _isUploading = false;

  Future<void> _publishPost() async {
    setState(() => _isUploading = true);

    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'post_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = '${directory.path}/$fileName';
      
      final file = File(widget.imagePath);
      if (file.existsSync()) await file.copy(savedPath);

      await FirebaseFirestore.instance.collection('posts').add({
        'userId': currentUser.uid,
        'userEmail': currentUser.email,
        'imageUrl': savedPath,
        'caption': _captionController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'Likes': [],
      });

      if (mounted) {
        // 🔥 1. Сначала закрываем ВСЕ экраны редактора
        Navigator.of(context).popUntil((route) => route.isFirst);
        
        // 🔥 2. ПОСЛЕ закрытия переключаем на профиль
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onFinish?.call();
          
          // 🔥 3. Показываем сообщение уже на главной
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Пост опубликован! ✨'), backgroundColor: Colors.green),
          );
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6E8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Предпросмотр', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(16),
                width: 300,
                height: 400,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(File(widget.imagePath), fit: BoxFit.cover),
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Описание (необязательно)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: _captionController,
                  maxLines: 3,
                  maxLength: 150,
                  decoration: InputDecoration(
                    hintText: 'Добавьте описание...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _publishPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E63),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isUploading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Выложить', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}