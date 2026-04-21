import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  static const String avatarsBucket = 'avatars';
  static const String messageMediaBucket = 'message-media';

  // Upload avatar
  Future<String> uploadAvatar(String userId, File file) async {
    final fileExt = file.path.split('.').last;
    final fileName = '$userId-${DateTime.now().millisecondsSinceEpoch}.$fileExt';
    final filePath = '$userId/$fileName';

    await _supabase.storage.from(avatarsBucket).upload(
      filePath,
      file,
      fileOptions: const FileOptions(upsert: true),
    );

    return _supabase.storage.from(avatarsBucket).getPublicUrl(filePath);
  }

  // Upload message media (image, video, audio)
  Future<String> uploadMessageMedia(
    String conversationId,
    File file,
    String mediaType,
  ) async {
    final fileExt = file.path.split('.').last;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
    final filePath = '$conversationId/$mediaType/$fileName';

    await _supabase.storage.from(messageMediaBucket).upload(
      filePath,
      file,
      fileOptions: const FileOptions(upsert: false),
    );

    return _supabase.storage.from(messageMediaBucket).getPublicUrl(filePath);
  }

  // Delete file
  Future<void> deleteFile(String bucket, String path) async {
    await _supabase.storage.from(bucket).remove([path]);
  }

  // Get public URL
  String getPublicUrl(String bucket, String path) {
    return _supabase.storage.from(bucket).getPublicUrl(path);
  }
}
