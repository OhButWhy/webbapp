import 'dart:convert';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

/// Max raw bytes allowed for the Firestore base64 fallback. Firestore documents
/// are capped at ~1 MB and base64 inflates size by ~4/3, so keep the raw image
/// well under that to leave room for the other post fields.
const int _maxInlineImageBytes = 650 * 1024;

/// Uploads [image] and returns a durable reference suitable for storing in
/// Firestore.
///
/// Prefers Firebase Storage (returns an https download URL). If Storage is not
/// available for the project (e.g. it hasn't been enabled, which surfaces as a
/// 404/"object-not-found"), it falls back to an inline base64 `data:` URI that
/// is persisted directly in Firestore, so publishing still works without any
/// extra console setup. Once Storage is enabled, new uploads automatically use
/// the cleaner download-URL path.
Future<String> uploadImage(XFile image, String folder, String email) async {
  final bytes = await image.readAsBytes();
  final contentType = image.mimeType ?? 'image/jpeg';
  final sanitizedEmail = email.replaceAll(RegExp(r'[@.]'), '_');
  final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

  try {
    final ref = FirebaseStorage.instance.ref('$folder/$sanitizedEmail/$fileName');
    // Bound the attempt: if Storage isn't enabled the upload can hang instead
    // of failing fast, so time out and fall back to the inline path.
    return await Future(() async {
      await ref.putData(bytes, SettableMetadata(contentType: contentType));
      return ref.getDownloadURL();
    }).timeout(const Duration(seconds: 10));
  } catch (_) {
    // Storage unavailable — fall back to an inline data URI in Firestore.
    if (bytes.length > _maxInlineImageBytes) {
      throw Exception(
        'Изображение слишком большое. Выберите фото поменьше '
        '(или включите Firebase Storage для полноразмерных загрузок).',
      );
    }
    return 'data:$contentType;base64,${base64Encode(bytes)}';
  }
}
