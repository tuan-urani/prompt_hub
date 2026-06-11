import 'dart:typed_data';

import 'package:path/path.dart' as path;
import 'package:supabase/supabase.dart';

class UploadedPromptImage {
  const UploadedPromptImage({required this.path, required this.publicUrl});

  final String path;
  final String publicUrl;
}

class StorageRepository {
  StorageRepository(this._client);

  static const String bucketName = 'prompt-images';

  final SupabaseClient _client;

  Future<UploadedPromptImage> uploadPromptImage({
    required String userId,
    required String promptId,
    required Uint8List bytes,
    required String fileName,
  }) async {
    final extension = _extensionFor(fileName);
    final objectPath =
        '$userId/$promptId-${DateTime.now().microsecondsSinceEpoch}$extension';

    await _client.storage
        .from(bucketName)
        .uploadBinary(
          objectPath,
          bytes,
          fileOptions: FileOptions(
            cacheControl: '3600',
            upsert: true,
            contentType: _contentTypeFor(extension),
          ),
        );

    final publicUrl = _client.storage.from(bucketName).getPublicUrl(objectPath);
    return UploadedPromptImage(path: objectPath, publicUrl: publicUrl);
  }

  Future<void> deletePromptImage(String? objectPath) async {
    if (objectPath == null || objectPath.isEmpty) return;
    await _client.storage.from(bucketName).remove(<String>[objectPath]);
  }

  String _extensionFor(String fileName) {
    final extension = path.extension(fileName).toLowerCase();
    if (extension == '.jpg' || extension == '.jpeg') return extension;
    if (extension == '.webp') return extension;
    return '.png';
  }

  String _contentTypeFor(String extension) {
    return switch (extension) {
      '.jpg' || '.jpeg' => 'image/jpeg',
      '.webp' => 'image/webp',
      _ => 'image/png',
    };
  }
}
