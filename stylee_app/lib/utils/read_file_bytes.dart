import 'dart:typed_data';

import 'read_file_bytes_stub.dart'
    if (dart.library.io) 'read_file_bytes_io.dart' as impl;

Future<Uint8List> readFileBytes(String path) => impl.readFileBytes(path);
