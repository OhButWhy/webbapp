import 'package:flutter/widgets.dart';

import 'image_provider_from_path_stub.dart'
    if (dart.library.io) 'image_provider_from_path_io.dart' as impl;

ImageProvider? imageProviderFromPath(String? path) => impl.imageProviderFromPath(path);

bool canDisplayPathAsImage(String? path) => impl.canDisplayPathAsImage(path);
