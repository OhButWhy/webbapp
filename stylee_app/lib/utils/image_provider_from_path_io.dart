import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';

bool _isUrl(String value) {
  return value.startsWith('http://') ||
      value.startsWith('https://') ||
      value.startsWith('blob:');
}

ImageProvider? imageProviderFromPath(String? path) {
  if (path == null || path.isEmpty) return null;
  // Inline base64 images (used as a fallback when Firebase Storage is not
  // available) are decoded to bytes so they render reliably.
  if (path.startsWith('data:')) {
    final comma = path.indexOf(',');
    if (comma == -1) return null;
    return MemoryImage(base64Decode(path.substring(comma + 1)));
  }
  if (_isUrl(path)) return NetworkImage(path);

  final file = File(path);
  if (!file.existsSync()) return null;
  return FileImage(file);
}

bool canDisplayPathAsImage(String? path) => imageProviderFromPath(path) != null;
