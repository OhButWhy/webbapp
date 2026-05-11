import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PostDetailPage extends StatefulWidget {
  final List<Map<String, dynamic>> posts;
  final int initialIndex;
  final String username;

  const PostDetailPage({
    super.key,
    required this.posts,
    this.initialIndex = 0,
    required this.username,
  });

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  String? _profileImagePath;
  
  // Храним состояние лайков для каждого поста
  Map<String, bool> _likesState = {};
  Map<String, int> _likesCount = {};

  @override
  void initState() {
    super.initState();
    _loadProfileImagePath();
    _initializeLikes();
  }

  Future<void> _loadProfileImagePath() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.email)
          .get();
      
      if (doc.exists && doc.data() != null) {
        if (mounted) {
          setState(() {
            _profileImagePath = doc.data()!['profileImagePath'] as String?;
          });
        }
      }
    } catch (e) {
      print('Error loading profile image: $e');
    }
  }

  void _initializeLikes() {
    for (var i = 0; i < widget.posts.length; i++) {
      final post = widget.posts[i];
      final docId = post['docId'] as String?;
      if (docId == null) continue;
      
      final likesList = post['Likes'] as List<dynamic>? ?? [];
      final isLiked = likesList.contains(currentUser.email);
      
      _likesState[docId] = isLiked;
      _likesCount[docId] = likesList.length;
    }
  }

  Future<void> _toggleLike(int index) async {
    final post = widget.posts[index];
    final docId = post['docId'] as String?;
    if (docId == null) return;
    
    final isCurrentlyLiked = _likesState[docId] ?? false;
    final currentCount = _likesCount[docId] ?? 0;
    
    // Сразу обновляем UI
    setState(() {
      _likesState[docId] = !isCurrentlyLiked;
      _likesCount[docId] = isCurrentlyLiked ? currentCount - 1 : currentCount + 1;
    });

    try {
      // Обновляем в Firestore
      final postRef = FirebaseFirestore.instance.collection('posts').doc(docId);
      
      if (isCurrentlyLiked) {
        await postRef.update({
          'Likes': FieldValue.arrayRemove([currentUser.email]),
        });
      } else {
        await postRef.update({
          'Likes': FieldValue.arrayUnion([currentUser.email]),
        });
      }
    } catch (e) {
      print('Error toggling like: $e');
      // Откат изменений при ошибке
      if (mounted) {
        setState(() {
          _likesState[docId] = isCurrentlyLiked;
          _likesCount[docId] = currentCount;
        });
      }
    }
  }

  Future<void> _deletePost(int index) async {
    final post = widget.posts[index];
    final docId = post['docId'] as String?;
    if (docId == null) return;

    // Подтверждение удаления
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить пост?'),
        content: const Text('Этот пост будет удалён навсегда.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // Удаляем из Firestore
      await FirebaseFirestore.instance.collection('posts').doc(docId).delete();

      // Удаляем локальный файл изображения (если есть)
      final imageUrl = post['imageUrl'] as String?;
      if (imageUrl != null && File(imageUrl).existsSync()) {
        await File(imageUrl).delete();
      }

      // Удаляем пост из списка и возвращаемся назад, если это был последний пост
      if (mounted) {
        setState(() {
          widget.posts.removeAt(index);
        });

        // Если удалили последний пост — закрываем экран
        if (widget.posts.isEmpty) {
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Пост удалён'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      print('Error deleting post: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при удалении: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPostOptions(int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: Colors.black87),
              title: const Text('Редактировать'),
              onTap: () {
                Navigator.pop(context);
                // Заглушка — можно добавить позже
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Редактирование пока недоступно')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Удалить', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deletePost(index);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'
    ];
    
    final day = date.day;
    final month = months[date.month - 1];
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    
    return '$day $month $year, $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder(
        future: Future.value(_profileImagePath),
        builder: (context, snapshot) {
          final profileImagePath = snapshot.data;
          
          return ListView.builder(
            itemCount: widget.posts.length,
            itemBuilder: (context, index) {
              final post = widget.posts[index];
              final docId = post['docId'] as String?;
              if (docId == null) return const SizedBox.shrink();
              
              final imageUrl = post['imageUrl'] as String?;
              final caption = post['caption'] as String?;
              final timestamp = post['createdAt'];
              final likesCount = _likesCount[docId] ?? 0;
              final isLiked = _likesState[docId] ?? false;
              
              final createdAt = timestamp != null 
                  ? (timestamp is Timestamp ? timestamp.toDate() : null)
                  : null;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Шапка поста: Аватар + Ник + Меню
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 17,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: (profileImagePath != null && 
                                          File(profileImagePath).existsSync())
                              ? FileImage(File(profileImagePath))
                              : null,
                          child: (profileImagePath == null || 
                                  !File(profileImagePath).existsSync())
                              ? Icon(Icons.person, size: 18, color: Colors.grey.shade400)
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          widget.username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        // Три точки → открывают меню
                        IconButton(
                          icon: const Icon(Icons.more_vert, size: 20, color: Colors.black87),
                          onPressed: () => _showPostOptions(index),
                        ),
                      ],
                    ),
                  ),

                  // 2. Изображение (Квадратное)
                  AspectRatio(
                    aspectRatio: 1,
                    child: imageUrl != null && imageUrl.isNotEmpty && File(imageUrl).existsSync()
                        ? Image.file(
                            File(imageUrl),
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )
                        : Container(
                            color: Colors.grey.shade200,
                            child: const Center(child: Icon(Icons.image_not_supported, size: 50)),
                          ),
                  ),

                  // 3. Кнопки действий (Лайк + Коммент) + Счётчик лайков
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      children: [
                        // Кнопка лайка
                        IconButton(
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 28,
                          ),
                          onPressed: () => _toggleLike(index),
                          color: isLiked ? Colors.red : Colors.black87,
                        ),
                        IconButton(
                          icon: const Icon(Icons.chat_bubble_outline, size: 28),
                          onPressed: () {},
                          color: Colors.black87,
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),

                  // Количество лайков
                  if (likesCount > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'Нравится: $likesCount',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                  // 4. Описание (если есть)
                  if (caption != null && caption.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          children: [
                            TextSpan(
                              text: widget.username,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(text: ' '),
                            TextSpan(text: caption),
                          ],
                        ),
                      ),
                    ),

                  // 5. Дата (мелким серым шрифтом)
                  if (createdAt != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: Text(
                        _formatDate(createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ),

                  const SizedBox(height: 8),

                  // Тонкая и более темная разделительная линия
                  Divider(color: Colors.grey.shade400, height: 1, thickness: 0.5),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

// Класс Timestamp для совместимости с Firestore
class Timestamp {
  final DateTime _dateTime;

  Timestamp(this._dateTime);

  DateTime toDate() => _dateTime;

  factory Timestamp.fromDate(DateTime date) => Timestamp(date);
}