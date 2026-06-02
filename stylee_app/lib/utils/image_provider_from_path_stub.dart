import 'package:flutter/widgets.dart';

bool _isUrl(String value) {
  return value.startsWith('http://') ||
      value.startsWith('https://') ||
      value.startsWith('data:') ||
      value.startsWith('blob:');
}

ImageProvider? imageProviderFromPath(String? path) {
  if (path == null || path.isEmpty) return null;
  if (_isUrl(path)) return NetworkImage(path);
  return null;
}

bool canDisplayPathAsImage(String? path) => imageProviderFromPath(path) != null;
