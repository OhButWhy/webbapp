import 'dart:convert';

import 'package:flutter/widgets.dart';

ImageProvider? imageProviderFromPath(String? path) {
  if (path == null || path.isEmpty) return null;
  // Inline base64 images (used as a fallback when Firebase Storage is not
  // available) are decoded to bytes so they render reliably.
  if (path.startsWith('data:')) {
    final comma = path.indexOf(',');
    if (comma == -1) return null;
    return MemoryImage(base64Decode(path.substring(comma + 1)));
  }
  // On web there is no filesystem access, so any non-empty path (http(s),
  // blob: or a relative URL) is loaded as a network image.
  return NetworkImage(path);
}

bool canDisplayPathAsImage(String? path) => imageProviderFromPath(path) != null;
