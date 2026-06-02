import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stylee_app/utils/image_provider_from_path.dart';
import 'package:stylee_app/screens/edit_profile_page.dart';
import 'package:stylee_app/screens/quiz/quiz_wizard.dart';
import 'package:stylee_app/screens/post_detail_page.dart';
import 'package:stylee_app/models/test_result.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final usersCollection = FirebaseFirestore.instance.collection("Users");
  final ImagePicker _picker = ImagePicker();
  
  String? _localProfileImagePath;
  bool _isUploading = false;
  int _selectedTab = 0; // 0 = posts, 1 = reposts, 2 = wardrobe

  @override
  void initState() {
    super.initState();
  }

  Future<void> _createPost() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      if (image == null) return;

      // Web-safe: store the picked path/URL as-is.
      final imageUrl = image.path;

      await FirebaseFirestore.instance.collection('posts').add({
        'userEmail': currentUser.email,
        'imageUrl': imageUrl,
        'caption': '',
        'createdAt': FieldValue.serverTimestamp(),
        'Likes': [],
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Пост создан (демо)')));
        setState(() {});
      }
    } catch (e) {
      print('Error creating demo post: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    }
  }
  
  Widget _buildTabIcon(IconData icon, int tabIndex) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = tabIndex),
        child: Container(
          height: 50,
          color: Colors.transparent,
          child: Icon(icon, color: _selectedTab == tabIndex ? const Color(0xFFE91E63) : Colors.grey.shade400, size: 24),
        ),
      ),
    );
  }

  Future<void> _loadLocalImagePath() async {
    // Keep local path handling simple and web-safe: prefer Firestore-stored path.
    return;
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 75,
      ).timeout(const Duration(seconds: 30));

      if (image != null && mounted) {
        setState(() => _isUploading = true);
        await _saveImageLocally(image.path);
        if (mounted) setState(() => _isUploading = false);
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при выборе фото')),
        );
      }
    }
  }

  Future<void> _saveImageLocally(String imagePath) async {
    try {
      // Web-safe: write the picked path (or blob URL) into Firestore so UI updates.
      final savedPath = imagePath;
      await usersCollection.doc(currentUser.email).update({
        'profileImagePath': savedPath,
      }).timeout(const Duration(seconds: 5));

      if (mounted) {
        setState(() => _localProfileImagePath = savedPath);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Фото обновлено!')),
        );
      }
    } catch (e) {
      print('Error saving image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка сохранения: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _showImagePicker() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Выбрать фото'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.pink),
                title: const Text('Галерея'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Вы вышли из аккаунта')),
      );
      Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
    }
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
        body: StreamBuilder<DocumentSnapshot>(
          stream: usersCollection.doc(currentUser.email).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Ошибка: ${snapshot.error}'));
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docSnapshot = snapshot.data;
            if (docSnapshot == null || !docSnapshot.exists || docSnapshot.data() == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Профиль не найден'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        await usersCollection.doc(currentUser.email).set({
                          'email': currentUser.email,
                          'username': currentUser.email!.split('@')[0],
                          'bio': '',
                          'hasCompletedTest': false,
                        });
                      },
                      child: const Text('Создать профиль'),
                    ),
                  ],
                ),
              );
            }

            final userData = docSnapshot.data() as Map<String, dynamic>;
            
            String? displayImagePath = _localProfileImagePath;
            if (displayImagePath == null && userData['profileImagePath'] != null) {
               displayImagePath = userData['profileImagePath'];
            }

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 80, left: 20, right: 20),
                    child: Column(
                      children: [
                        // Avatar
                        GestureDetector(
                          onTap: _isUploading ? null : _showImagePicker,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: const Color(0xFFF8E8EA),
                                backgroundImage: imageProviderFromPath(displayImagePath),
                                child: (displayImagePath == null || !canDisplayPathAsImage(displayImagePath)) && !_isUploading
                                    ? Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Colors.pink.shade200,
                                      )
                                    : null,
                              ),
                              if (_isUploading)
                                const Positioned.fill(
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Colors.black26,
                                    child: CircularProgressIndicator(color: Colors.white),
                                  ),
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
                                  child: CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      _isUploading ? Icons.hourglass_empty : Icons.add,
                                      size: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (!_isUploading)
                          Text(
                            'Нажмите для выбора фото',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        const SizedBox(height: 16),
                        
                        // Username
                        Text(
                          '@${userData['username'] ?? currentUser.email!.split('@')[0]}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        
                        // Bio with Edit Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                userData['bio'] ?? 'Fashion dreamer | OOTD everyday ✨',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 14, color: Colors.black87),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const EditProfilePage()),
                                );
                                if (result == true && mounted) {
                                  setState(() {}); 
                                }
                              },
                              child: Icon(
                                Icons.edit_rounded,
                                size: 16,
                                color: Colors.pink.shade400,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Stories Highlights
                        const Text(
                          'Stories Highlights',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              children: [
                                _buildHighlight('Summer'),
                                const SizedBox(width: 16),
                                _buildHighlight('OOTD'),
                                const SizedBox(width: 16),
                                _buildHighlight('Date Night'),
                                const SizedBox(width: 16),
                                _buildHighlight('Workwear'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // Tabs (Posts, Reposts, Wardrobe) - simplified
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _buildTabIcon(Icons.grid_view_rounded, 0),
                            Container(width: 0.5, color: Colors.grey.shade300),
                            _buildTabIcon(Icons.repeat_rounded, 1),
                            Container(width: 0.5, color: Colors.grey.shade300),
                            _buildTabIcon(Icons.checkroom_rounded, 2),
                          ],
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 2,
                          child: Container(
                            width: MediaQuery.of(context).size.width / 3,
                            decoration: const BoxDecoration(color: Color(0xFFE91E63)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Content for tabs
                if (_selectedTab == 0)
                  SliverPadding(
                    padding: EdgeInsets.zero,
                    sliver: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('posts')
                          .where('userEmail', isEqualTo: currentUser.email)
                          .orderBy('createdAt', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
                        final posts = snapshot.data!.docs;
                        if (posts.isEmpty) {
                          return SliverToBoxAdapter(
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: Center(child: Text('Пока ничего нет', style: TextStyle(color: Colors.grey.shade500))),
                            ),
                          );
                        }

                        return SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 0, crossAxisSpacing: 0, childAspectRatio: 1),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final post = posts[index];
                              final data = post.data() as Map<String, dynamic>;
                              final imageUrl = data['imageUrl'] as String?;

                              return GestureDetector(
                                onTap: () {
                                  final allPosts = posts.map((p) {
                                    final d = p.data() as Map<String, dynamic>;
                                    return {
                                      'docId': p.id,
                                      'imageUrl': d['imageUrl'] as String?,
                                      'caption': d['caption'] as String?,
                                      'createdAt': d['createdAt'],
                                      'Likes': d['Likes'] as List<dynamic>? ?? [],
                                    };
                                  }).toList();

                                  Navigator.push(context, MaterialPageRoute(builder: (ctx) => PostDetailPage(posts: allPosts, initialIndex: index, username: userData['username'] ?? currentUser.email!.split('@')[0])));
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    image: (() {
                                      final p = imageProviderFromPath(imageUrl);
                                      return p != null ? DecorationImage(image: p, fit: BoxFit.cover) : null;
                                    })(),
                                    color: Colors.grey.shade200,
                                  ),
                                  child: imageUrl == null || !canDisplayPathAsImage(imageUrl) ? const Icon(Icons.image_not_supported, color: Colors.grey, size: 30) : null,
                                ),
                              );
                            },
                            childCount: posts.length,
                          ),
                        );
                      },
                    ),
                  )
                else if (_selectedTab == 1)
                  SliverToBoxAdapter(child: SizedBox(height: MediaQuery.of(context).size.height * 0.5, child: Center(child: Text('Репосты пока отсутствуют'))))
                else
                  SliverToBoxAdapter(child: SizedBox(height: MediaQuery.of(context).size.height * 0.5, child: Center(child: Text('Гардероб пуст')))),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHighlight(String label) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFE91E63), Color(0xFFF48FB1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withOpacity(0.18),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.favorite_border, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 84,
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}