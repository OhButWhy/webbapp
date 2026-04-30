import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stylee_app/services/backend_api_service.dart';

class FavoriteImagesScreen extends StatefulWidget {
  const FavoriteImagesScreen({super.key});

  @override
  State<FavoriteImagesScreen> createState() => _FavoriteImagesScreenState();
}

class _FavoriteImagesScreenState extends State<FavoriteImagesScreen> {
  final _backend = BackendApiService.instance;
  List<String> favoriteImages = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        loading = false;
      });
      return;
    }

    setState(() {
      // optimistic reset while loading new data
      loading = false;
    });

    final favorites = await _backend.getFavorites(user.email!);
    setState(() {
      favoriteImages = favorites;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Избранное')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : favoriteImages.isEmpty
              ? const Center(child: Text('Нет сохраненных картинок'))
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: favoriteImages.length,
                  itemBuilder: (context, idx) {
                    final imageUrl = favoriteImages[idx];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(imageUrl, fit: BoxFit.cover),
                    );
                  },
                ),
    );
  }
}