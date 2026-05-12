import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stylee_app/components/drawer.dart';
import 'package:stylee_app/screens/chat_page.dart';
import 'package:stylee_app/screens/editor_page.dart';
import 'package:stylee_app/screens/edit_profile_page.dart';
import 'package:stylee_app/screens/profile_page.dart';
import 'package:stylee_app/screens/wardrobe_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final currentUser = FirebaseAuth.instance.currentUser!;

  // Кэш для данных пользователей
  final Map<String, Map<String, dynamic>> _usersCache = {};

  void _onBottomNavTap(int index) {
    setState(() => _selectedIndex = index);
  }

  Future<Map<String, dynamic>> _getUserData(String email) async {
    if (_usersCache.containsKey(email)) {
      return _usersCache[email]!;
    }
    try {
      final doc = await FirebaseFirestore.instance.collection('Users').doc(email).get();
      if (doc.exists && doc.data() != null) {
        _usersCache[email] = doc.data()!;
        return doc.data()!;
      }
    } catch (e) {
      print('Error getting user  $e');
    }
    return {'username': email.split('@').first, 'profileImagePath': null};
  }

  // Функция переключения лайка
  Future<void> _toggleLike(String docId) async {
    try {
      final postRef = FirebaseFirestore.instance.collection('posts').doc(docId);
      final postSnap = await postRef.get();
      
      if (!postSnap.exists) return;
      
      final likesList = postSnap.data()?['Likes'] as List<dynamic>? ?? [];
      final isCurrentlyLiked = likesList.contains(currentUser.email);

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
      print('Error toggling like in feed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget currentPage;
    switch (_selectedIndex) {
      case 0: currentPage = _buildFeed(); break;
      case 1: currentPage = const WardrobePage(); break;
      case 2: currentPage = const EditorPage(); break;
      case 3: currentPage = const ChatPage(); break;
      case 4: currentPage = const ProfilePage(); break;
      default: currentPage = _buildFeed();
    }

    final isFeed = _selectedIndex == 0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isFeed ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: isFeed ? Colors.black : const Color(0xFFF5E6E8),
        body: currentPage,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onBottomNavTap,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: Colors.black87,
            unselectedItemColor: Colors.grey.shade600,
            selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
            items: [
              _buildNavItem(Icons.local_fire_department_outlined, 'Feed', 0),
              _buildNavItem(Icons.checkroom_outlined, 'Wardrobe', 1),
              _buildNavItem(Icons.auto_fix_high_outlined, 'Editor', 2),
              _buildNavItem(Icons.auto_awesome_outlined, 'AI Stylist', 3),
              _buildNavItem(Icons.person_outline, 'Profile', 4),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return BottomNavigationBarItem(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? const Color(0xFFE91E63) : const Color(0xFF666666), size: 26),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: isSelected ? const Color(0xFFE91E63) : const Color(0xFF666666))),
        ],
      ),
      label: '',
    );
  }

  // ================= TIKTOK-STYLE FEED =================
  Widget _buildFeed() {
    return Stack(
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('posts')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Ошибка: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_fire_department_outlined, size: 80, color: Colors.pink.shade300),
                    const SizedBox(height: 24),
                    const Text('Лента пуста', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text('Создайте первый пост ✨', style: TextStyle(color: Colors.grey.shade400)),
                  ],
                ),
              );
            }

            final posts = snapshot.data!.docs;
            return PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: posts.length,
              itemBuilder: (context, index) => _buildPostItem(posts[index]),
            );
          },
        ),

        _buildTopMenu(),
      ],
    );
  }

  Widget _buildTopMenu() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black.withOpacity(0.7), Colors.transparent],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTopTab("Подписки", false),
              const SizedBox(width: 20),
              _buildTopTab("Рекомендации", true),
              const SizedBox(width: 20),
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white, size: 26),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Поиск в разработке 🔍"), backgroundColor: Colors.black54),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopTab(String title, bool isActive) {
    return GestureDetector(
      onTap: () {
        if (!isActive) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Вкладка '$title' в разработке 🚧"), backgroundColor: Colors.black54),
          );
        }
      },
      child: Text(
        title,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.white.withOpacity(0.6),
          fontSize: 16,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildPostItem(QueryDocumentSnapshot post) {
    final data = post.data() as Map<String, dynamic>;
    final imageUrl = data['imageUrl'] as String?;
    final caption = data['caption'] ?? '';
    final timestamp = data['createdAt'] as Timestamp?;
    final authorEmail = data['userEmail'] as String? ?? '';
    final docId = post.id;
    
    final likesList = data['Likes'] as List<dynamic>? ?? [];
    final isLiked = likesList.contains(currentUser.email);
    final likesCount = likesList.length;

    return FutureBuilder<Map<String, dynamic>>(
      future: _getUserData(authorEmail),
      builder: (context, snapshot) {
        final userData = snapshot.data ?? {};
        final username = userData['username'] as String? ?? authorEmail.split('@').first;
        final profileImagePath = userData['profileImagePath'] as String?;

        return Stack(
          children: [
            // Фон поста
            (imageUrl != null && File(imageUrl).existsSync())
                ? Image.file(
                    File(imageUrl),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.contain,
                  )
                : Container(color: Colors.grey.shade900),

            // Градиенты
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.3), Colors.transparent, Colors.black.withOpacity(0.8)],
                  ),
                ),
              ),
            ),

            // Правая панель действий (По центру экрана, без кружков)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Аватар (кружок оставляем только для фото)
                    _buildSideAction(
                      profileImagePath: profileImagePath,
                      onTap: () {},
                      size: 24, // Аватар чуть меньше
                    ),
                    const SizedBox(height: 20),
                    
                    // Лайк
                    GestureDetector(
                      onTap: () => _toggleLike(docId),
                      child: _buildSideAction(
                        icon: isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      likesCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Коммент
                    _buildSideAction(
                      icon: Icons.chat_bubble_outline,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "0", // Заглушка для комментов
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                    ),

                    const SizedBox(height: 20),
                    
                    // Сохранить (Save) - выше
                    _buildSideAction(
                      icon: Icons.bookmark_border,
                      color: Colors.white,
                      size: 32,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Поделиться (Share) - ниже
                    _buildSideAction(
                      icon: Icons.ios_share,
                      color: Colors.white,
                      size: 32,
                    ),
                  ],
                ),
              ),
            ),

            // Нижняя информация (слева)
            Positioned(
              left: 12,
              right: 80,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Убрали кнопку Follow
                  Text(
                    "@$username",
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (caption.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(caption, style: const TextStyle(color: Colors.white, fontSize: 14)),
                  ],
                  if (timestamp != null) ...[
                    const SizedBox(height: 8),
                    Text(_formatTime(timestamp), style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // Обновленный виджет для иконок (без черного фона)
  Widget _buildSideAction({
    IconData? icon,
    Color? color,
    double size = 32,
    VoidCallback? onTap,
    String? profileImagePath,
  }) {
    // Если передан путь к фото профиля - рисуем кружок с фото
    if (profileImagePath != null && File(profileImagePath).existsSync()) {
      return CircleAvatar(
        backgroundImage: FileImage(File(profileImagePath)),
        radius: size,
        backgroundColor: Colors.grey.shade300,
      );
    }

    // Иначе рисуем просто иконку без фона
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        icon,
        color: color ?? Colors.white,
        size: size,
      ),
    );
  }

  String _formatTime(Timestamp timestamp) {
    final now = DateTime.now();
    final postDate = timestamp.toDate();
    final diff = now.difference(postDate);

    if (diff.inMinutes < 1) return 'только что';
    if (diff.inHours < 1) return '${diff.inMinutes} мин. назад';
    if (diff.inDays < 1) return '${diff.inHours} ч. назад';
    if (diff.inDays < 7) return '${diff.inDays} дн. назад';
    return '${postDate.day}.${postDate.month}.${postDate.year}';
  }
}