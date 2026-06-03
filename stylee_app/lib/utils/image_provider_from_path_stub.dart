import 'package:flutter/widgets.dart';

ImageProvider? imageProviderFromPath(String? path) {
  if (path == null || path.isEmpty) return null;
  // On web there is no filesystem access, so any non-empty path (http(s),
  // data:, blob: or a relative URL) is loaded as a network image.
  return NetworkImage(path);
}

bool canDisplayPathAsImage(String? path) => imageProviderFromPath(path) != null;
