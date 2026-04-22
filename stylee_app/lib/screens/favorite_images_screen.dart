import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteImagesScreen extends StatefulWidget {
  const FavoriteImagesScreen({super.key});

  @override
  State<FavoriteImagesScreen> createState() => _FavoriteImagesScreenState();
}

class _FavoriteImagesScreenState extends State<FavoriteImagesScreen> {
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

    final doc = await FirebaseFirestore.instance.collection('Users').doc(user.email).get();
    final data = doc.data();
    setState(() {
      favoriteImages = List<String>.from(data?['favoriteImages'] ?? []);
      loading = false;
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