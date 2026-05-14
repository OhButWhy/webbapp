import 'dart:io';
import 'dart:typed_data';

Future<Uint8List> readFileBytes(String path) async {
  final file = File(path);
  if (!file.existsSync()) {
    throw Exception('Image file not found');
  }
  return file.readAsBytes();
}
