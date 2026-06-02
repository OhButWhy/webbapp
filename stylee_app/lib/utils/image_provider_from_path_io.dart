import 'dart:io';

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

  final file = File(path);
  if (!file.existsSync()) return null;
  return FileImage(file);
}

bool canDisplayPathAsImage(String? path) => imageProviderFromPath(path) != null;
