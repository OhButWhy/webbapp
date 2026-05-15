import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stylee_app/components/marketplace_search_button.dart';
import 'package:stylee_app/components/drawer.dart';
import 'package:stylee_app/screens/chat_page.dart';
import 'package:stylee_app/screens/editor_page.dart';
import 'package:stylee_app/screens/edit_profile_page.dart';
import 'package:stylee_app/screens/marketplace_search_screen.dart';
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

  String? _feedEventFilter;
  String? _feedWeatherFilter;
  String? _feedColorFilter;

  final List<String> _eventOptions = ['работа', 'вечеринка', 'прогулка'];
  final List<String> _weatherOptions = ['жарко', 'прохладно', 'дождь'];
  final List<String> _colorOptions = ['чёрный', 'белый', 'красный', 'синий', 'серый', 'голубой'];

  final Map<String, Map<String, dynamic>> _usersCache = {};
  bool _debugMode = false;
  bool _forceDemoFeed = false;

  void _onBottomNavTap(int index) {
    setState(() => _selectedIndex = index);
  }

  Future<Map<String, dynamic>> _getUserData(String email) async {
    if (_usersCache.containsKey(email)) return _usersCache[email]!;
    try {
      final doc = await FirebaseFirestore.instance.collection('Users').doc(email).get();
      if (doc.exists && doc.data() != null) {
        _usersCache[email] = doc.data()!;
        return doc.data()!;
      }
    } catch (e) {
      print('Error getting user $e');
    }
    return {'username': email.split('@').first, 'profileImagePath': null};
  }

  Future<void> _toggleLike(String docId) async {
    try {
      final postRef = FirebaseFirestore.instance.collection('posts').doc(docId);
      final postSnap = await postRef.get();
      if (!postSnap.exists) return;
      
      final likesList = postSnap.data()?['Likes'] as List<dynamic>? ?? [];
      final isCurrentlyLiked = likesList.contains(currentUser.email);

      if (isCurrentlyLiked) {
        await postRef.update({'Likes': FieldValue.arrayRemove([currentUser.email])});
      } else {
        await postRef.update({'Likes': FieldValue.arrayUnion([currentUser.email])});
      }
    } catch (e) {
      print('Error toggling like in feed: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _debugMode = Uri.base.queryParameters['debug'] == '1';
    _forceDemoFeed = Uri.base.queryParameters['demoFeed'] == '1';
  }

  Widget _placeholderImageWidget() {
    return Container(
      color: Colors.grey.shade900,
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 72, color: Colors.white24),
      ),
    );
  }

  // Demo posts for the public demo build when Firestore has no posts or writes are disabled
  final List<Map<String, String>> _demoPosts = [
    {'imageUrl': '', 'caption': 'Демо: лёгкий образ для прогулки'},
    {'imageUrl': '', 'caption': 'Демо: повседневный базовый look'},
    {'imageUrl': '', 'caption': 'Демо: вечерний образ'},
  ];

  Widget _buildDemoPostItem(int index) {
    final data = _demoPosts[index];
    final caption = data['caption'] ?? '';
    final likesCount = 0;

    return Stack(
      children: [
        Container(color: Colors.grey.shade900),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.3), Colors.transparent, Colors.black.withOpacity(0.8)]),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSideAction(icon: Icons.favorite_border, color: Colors.white, size: 32, onTap: () { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Лайк (демо)'))); }),
                const SizedBox(height: 4),
                Text(likesCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(height: 20),
                _buildSideAction(icon: Icons.chat_bubble_outline, color: Colors.white, size: 32),
                const SizedBox(height: 4),
                const Text("0", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
        Positioned(
          left: 12, right: 80, bottom: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('@demo_user', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              if (caption.isNotEmpty) ...[const SizedBox(height: 8), Text(caption, style: const TextStyle(color: Colors.white, fontSize: 14))],
            ],
          ),
        ),
      ],
    );
  }

  bool get _hasActiveFeedFilters =>
      _feedEventFilter != null || _feedWeatherFilter != null || _feedColorFilter != null;

  bool _postMatchesFeedFilters(QueryDocumentSnapshot post) {
    if (!_hasActiveFeedFilters) return true;
    final data = post.data() as Map<String, dynamic>;

    final events = (data['events'] is List) ? (data['events'] as List).whereType<String>().toList() : const <String>[];
    final weathers = (data['weathers'] is List) ? (data['weathers'] as List).whereType<String>().toList() : const <String>[];
    final colors = (data['colors'] is List) ? (data['colors'] as List).whereType<String>().toList() : const <String>[];

    final matchesEvent = _feedEventFilter == null || events.contains(_feedEventFilter);
    final matchesWeather = _feedWeatherFilter == null || weathers.contains(_feedWeatherFilter);
    final matchesColor = _feedColorFilter == null || colors.contains(_feedColorFilter);

    return matchesEvent && matchesWeather && matchesColor;
  }

  Future<void> _openFeedFilters() async {
    String? selectedEvent = _feedEventFilter;
    String? selectedWeather = _feedWeatherFilter;
    String? selectedColor = _feedColorFilter;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => SafeArea(
        child: StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: EdgeInsets.only(
              left: 16, right: 16, top: 16, bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Фильтры ленты', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                DropdownButtonFormField<String?>(
                  value: selectedEvent,
                  decoration: _dropdownDecoration('Мероприятие'),
                  items: [null, ..._eventOptions].map((e) => DropdownMenuItem<String?>(value: e, child: Text(e ?? 'Не выбрано'))).toList(),
                  onChanged: (v) => setModalState(() => selectedEvent = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  value: selectedWeather,
                  decoration: _dropdownDecoration('Погода'),
                  items: [null, ..._weatherOptions].map((e) => DropdownMenuItem<String?>(value: e, child: Text(e ?? 'Не выбрано'))).toList(),
                  onChanged: (v) => setModalState(() => selectedWeather = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  value: selectedColor,
                  decoration: _dropdownDecoration('Цвет'),
                  items: [null, ..._colorOptions].map((e) => DropdownMenuItem<String?>(value: e, child: Text(e ?? 'Не выбрано'))).toList(),
                  onChanged: (v) => setModalState(() => selectedColor = v),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _feedEventFilter = null;
                            _feedWeatherFilter = null;
                            _feedColorFilter = null;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Сбросить'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _feedEventFilter = selectedEvent;
                            _feedWeatherFilter = selectedWeather;
                            _feedColorFilter = selectedColor;
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE91E63), foregroundColor: Colors.white),
                        child: const Text('Применить'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget currentPage;
    switch (_selectedIndex) {
      case 0: currentPage = _buildFeed(); break;
      case 1: currentPage = const WardrobePage(); break;
      case 2:
        // 🔥 Наше исправление: колбэк для возврата в профиль
        currentPage = EditorPage(onFinish: () => _onBottomNavTap(4));
        break;
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
        
        // 🔥 Скрываем меню только на вкладке Editor
        bottomNavigationBar: _selectedIndex == 2 
            ? null 
            : Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -2))],
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
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
          stream: FirebaseFirestore.instance.collection('posts').orderBy('createdAt', descending: true).snapshots(),
          builder: (context, snapshot) {
            if (_forceDemoFeed) {
              return PageView.builder(
                scrollDirection: Axis.vertical,
                itemCount: _demoPosts.length,
                itemBuilder: (context, index) => _buildDemoPostItem(index),
              );
            }
            if (snapshot.hasError) return Center(child: Text('Ошибка: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              // Show a small demo feed so reviewers can scroll and interact without Firestore posts
              return PageView.builder(
                scrollDirection: Axis.vertical,
                itemCount: _demoPosts.length,
                itemBuilder: (context, index) => _buildDemoPostItem(index),
              );
            }

            final allPosts = snapshot.data!.docs;
            final posts = allPosts.where(_postMatchesFeedFilters).toList();

            if (posts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.tune, size: 80, color: Colors.pink.shade300),
                    const SizedBox(height: 24),
                    const Text('Ничего не найдено', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text(_hasActiveFeedFilters ? 'Смените или сбросьте фильтры' : 'Создайте первый пост ✨', style: TextStyle(color: Colors.grey.shade400)),
                  ],
                ),
              );
            }

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
      top: 0, left: 0, right: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.7), Colors.transparent]),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTopTab("Подписки", false),
              const SizedBox(width: 20),
              _buildTopTab("Рекомендации", true),
              const SizedBox(width: 20),
              IconButton(icon: const Icon(Icons.tune, color: Colors.white, size: 26), onPressed: _openFeedFilters),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _wrapWithDebug(Widget child, AsyncSnapshot<QuerySnapshot> snapshot) {
    if (!_debugMode) return child;
    final docsCount = snapshot.data?.docs.length ?? 0;
    final sample = docsCount > 0 ? snapshot.data!.docs.first.data().toString() : '';
    return Stack(
      children: [
        child,
        Positioned(
          top: 80,
          right: 12,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('debug: posts=$docsCount', style: const TextStyle(color: Colors.white, fontSize: 12)),
                if (sample.isNotEmpty) SizedBox(width: 200, child: Text(sample, style: const TextStyle(color: Colors.white70, fontSize: 11), maxLines: 4, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopTab(String title, bool isActive) {
    return GestureDetector(
      onTap: () {
        if (!isActive) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Вкладка '$title' в разработке 🚧"), backgroundColor: Colors.black54));
        }
      },
      child: Text(title, style: TextStyle(color: isActive ? Colors.white : Colors.white.withOpacity(0.6), fontSize: 16, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
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
        Widget imageWidget;
        if (imageUrl != null && imageUrl.isNotEmpty) {
          if (imageUrl.startsWith('http') || imageUrl.startsWith('data:')) {
            imageWidget = Image.network(
              imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stack) {
                return _placeholderImageWidget();
              },
            );
          } else if (!kIsWeb && File(imageUrl).existsSync()) {
            imageWidget = Image.file(File(imageUrl), width: double.infinity, height: double.infinity, fit: BoxFit.contain);
          } else {
            imageWidget = Container(color: Colors.grey.shade900);
          }
        } else {
          imageWidget = Container(color: Colors.grey.shade900);
        }

        return Stack(
          children: [
            imageWidget,

            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.3), Colors.transparent, Colors.black.withOpacity(0.8)]),
                ),
              ),
            ),

            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSideAction(profileImagePath: profileImagePath, onTap: () {}, size: 24),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => _toggleLike(docId),
                      child: _buildSideAction(icon: isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : Colors.white, size: 32),
                    ),
                    const SizedBox(height: 4),
                    Text(likesCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 20),
                    _buildSideAction(icon: Icons.chat_bubble_outline, color: Colors.white, size: 32),
                    const SizedBox(height: 4),
                    const Text("0", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 20),
                    _buildSideAction(icon: Icons.bookmark_border, color: Colors.white, size: 32),
                    const SizedBox(height: 20),
                    
                    // 🔥 Marketplace кнопка
                    MarketplaceSearchButton(
                      size: 44,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => MarketplaceSearchScreen(imageUrl: imageUrl, imagePath: imageUrl, queryHint: caption.toString())),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    _buildSideAction(icon: Icons.ios_share, color: Colors.white, size: 32),
                  ],
                ),
              ),
            ),

            Positioned(
              left: 12, right: 80, bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("@$username", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  if (caption.isNotEmpty) ...[const SizedBox(height: 8), Text(caption, style: const TextStyle(color: Colors.white, fontSize: 14))],
                  if (timestamp != null) ...[const SizedBox(height: 8), Text(_formatTime(timestamp), style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12))],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSideAction({IconData? icon, Color? color, double size = 32, VoidCallback? onTap, String? profileImagePath}) {
    if (profileImagePath != null && File(profileImagePath).existsSync()) {
      return CircleAvatar(backgroundImage: FileImage(File(profileImagePath)), radius: size, backgroundColor: Colors.grey.shade300);
    }
    return GestureDetector(onTap: onTap, child: Icon(icon, color: color ?? Colors.white, size: size));
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