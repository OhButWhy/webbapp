import 'package:flutter/material.dart';
import 'package:stylee_app/screens/marketplace_search_screen.dart';

Future<void> openMarketplaceSearch(
  BuildContext context, {
  String? imageUrl,
  String? imagePath,
  String? queryHint,
  bool requireImage = false,
}) async {
  final hasImage = (imageUrl != null && imageUrl.isNotEmpty) ||
      (imagePath != null && imagePath.isNotEmpty);

  if (requireImage && !hasImage) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Для поиска нужен доступный снимок')),
    );
    return;
  }

  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => MarketplaceSearchScreen(
        imageUrl: imageUrl,
        imagePath: imagePath,
        queryHint: queryHint,
      ),
    ),
  );
}