import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FavoritePostButton extends StatefulWidget {
  final String imageUrl;
  const FavoritePostButton({super.key, required this.imageUrl});

  @override
  State<FavoritePostButton> createState() => _FavoritePostButtonState();
}

class _FavoritePostButtonState extends State<FavoritePostButton> {
  bool isFavorite = false;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorite();
  }

  Future<void> _loadFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        loading = false;
      });
      return;
    }
    final doc = await FirebaseFirestore.instance.collection('Users').doc(user.email).get();
    final data = doc.data();
    final favs = List<String>.from(data?['favoriteImages'] ?? []);
    setState(() {
      isFavorite = favs.contains(widget.imageUrl);
      loading = false;
    });
  }

  Future<void> _toggleFavorite() async {
    if (widget.imageUrl.isEmpty) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final docRef = FirebaseFirestore.instance.collection('Users').doc(user.email);
    setState(() {
      isFavorite = !isFavorite;
    });
    if (isFavorite) {
      await docRef.set({
        'favoriteImages': FieldValue.arrayUnion([widget.imageUrl])
      }, SetOptions(merge: true));
    } else {
      await docRef.set({
        'favoriteImages': FieldValue.arrayRemove([widget.imageUrl])
      }, SetOptions(merge: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const SizedBox(height: 24, width: 24);
    return IconButton(
      icon: Icon(isFavorite ? Icons.bookmark : Icons.bookmark_border, color: isFavorite ? Colors.pink : null),
      tooltip: isFavorite ? 'Убрать из избранного' : 'В избранное',
      onPressed: widget.imageUrl.isEmpty ? null : _toggleFavorite,
    );
  }
}