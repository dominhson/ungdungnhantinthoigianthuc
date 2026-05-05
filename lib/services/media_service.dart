import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MediaService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _imagePicker = ImagePicker();

  // Pick image from gallery
  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  // Pick image from camera
  Future<XFile?> pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      debugPrint('Error taking photo: $e');
      return null;
    }
  }

  // Pick file
  Future<PlatformFile?> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'zip'],
      );
      
      if (result != null && result.files.isNotEmpty) {
        return result.files.first;
      }
      return null;
    } catch (e) {
      debugPrint('Error picking file: $e');
      return null;
    }
  }

  // Upload image to Supabase Storage
  Future<String?> uploadImage({
    required String filePath,
    required String conversationId,
  }) async {
    try {
      // Read file as bytes (works on all platforms)
      final bytes = kIsWeb 
          ? await XFile(filePath).readAsBytes()
          : await File(filePath).readAsBytes();
      
      final fileExt = filePath.split('.').last.toLowerCase();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final storagePath = '$conversationId/$fileName';

      // Upload to Supabase Storage
      await _supabase.storage
          .from('message-media')
          .uploadBinary(storagePath, bytes);

      // Get public URL
      final publicUrl = _supabase.storage
          .from('message-media')
          .getPublicUrl(storagePath);

      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  // Upload file to Supabase Storage
  Future<String?> uploadFile({
    required String filePath,
    required String conversationId,
    required String fileName,
  }) async {
    try {
      // Read file as bytes (works on all platforms)
      final bytes = kIsWeb 
          ? await XFile(filePath).readAsBytes()
          : await File(filePath).readAsBytes();
      
      final uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      final storagePath = '$conversationId/$uniqueFileName';

      // Upload to Supabase Storage
      await _supabase.storage
          .from('message-media')
          .uploadBinary(storagePath, bytes);

      // Get public URL
      final publicUrl = _supabase.storage
          .from('message-media')
          .getPublicUrl(storagePath);

      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading file: $e');
      return null;
    }
  }

  // Delete media from storage
  Future<bool> deleteMedia(String url) async {
    try {
      // Extract path from URL
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      
      // Find the bucket and path
      final bucketIndex = pathSegments.indexOf('storage');
      if (bucketIndex == -1 || bucketIndex + 2 >= pathSegments.length) {
        return false;
      }
      
      final bucket = pathSegments[bucketIndex + 2];
      final path = pathSegments.sublist(bucketIndex + 3).join('/');

      await _supabase.storage.from(bucket).remove([path]);
      return true;
    } catch (e) {
      debugPrint('Error deleting media: $e');
      return false;
    }
  }

  // Get file size in MB (works on all platforms)
  Future<double> getFileSize(String filePath) async {
    try {
      if (kIsWeb) {
        // On web, read bytes to get size
        final bytes = await XFile(filePath).readAsBytes();
        return bytes.length / (1024 * 1024);
      } else {
        // On mobile/desktop, use File
        final file = File(filePath);
        final bytes = await file.length();
        return bytes / (1024 * 1024);
      }
    } catch (e) {
      debugPrint('Error getting file size: $e');
      return 0;
    }
  }

  // Check if file size is within limit (10MB)
  Future<bool> isFileSizeValid(String filePath, {double maxSizeMB = 10}) async {
    final size = await getFileSize(filePath);
    return size <= maxSizeMB;
  }
}
