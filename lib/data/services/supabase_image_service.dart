import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:koopon/core/config/supabase_config.dart';

class SupabaseImageService {
  static const String bucketName = 'item-images'; // Same bucket, different folders
  
  // Use getter instead of field to avoid early initialization
  SupabaseClient get _supabase => SupabaseConfig.client;

  /// Upload item image to Supabase Storage (existing functionality)
  Future<String?> uploadImage(File imageFile, {String? customPath}) async {
    try {
      print('🔄 Starting item image upload to Supabase...');
      print('📁 Bucket name: $bucketName');
      print('📷 Image file path: ${imageFile.path}');
      print('📊 File size: ${await imageFile.length()} bytes');
      
      // Check if file exists
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist at path: ${imageFile.path}');
      }

      // Generate unique filename
      final fileName = customPath ?? _generateUniqueFileName(imageFile.path);
      print('📝 Generated filename: $fileName');
      
      // Read file as bytes
      print('📖 Reading file as bytes...');
      final Uint8List imageBytes = await imageFile.readAsBytes();
      print('✅ Successfully read ${imageBytes.length} bytes');
      
      // Get content type
      final contentType = _getContentType(imageFile.path);
      print('🏷️ Content type: $contentType');
      
      // Upload to Supabase Storage
      print('⬆️ Uploading to Supabase Storage...');
      final response = await _supabase.storage.from(bucketName).uploadBinary(
        fileName,
        imageBytes,
        fileOptions: FileOptions(
          contentType: contentType,
          upsert: false,
        ),
      );
      
      print('✅ Upload response received');
      print('📄 Upload response: $response');
      
      // Get public URL
      print('🔗 Getting public URL...');
      final String publicUrl = _supabase.storage
          .from(bucketName)
          .getPublicUrl(fileName);
      
      print('🎉 Success! Public URL: $publicUrl');
      return publicUrl;
      
    } catch (e, stackTrace) {
      print('❌ Error uploading item image: $e');
      print('📚 Stack trace: $stackTrace');
      return null;
    }
  }

  /// Upload profile image to Supabase Storage (NEW)
  Future<String?> uploadProfileImage(File imageFile, String userId) async {
    try {
      print('🔄 Starting profile image upload to Supabase...');
      print('👤 User ID: $userId');
      print('📁 Bucket name: $bucketName');
      print('📷 Image file path: ${imageFile.path}');
      print('📊 File size: ${await imageFile.length()} bytes');
      
      // Check if file exists
      if (!await imageFile.exists()) {
        throw Exception('Profile image file does not exist at path: ${imageFile.path}');
      }

      // Create profile-specific path
      final fileName = 'profiles/$userId/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      print('📝 Profile image filename: $fileName');
      
      // Read file as bytes
      print('📖 Reading profile image file as bytes...');
      final Uint8List imageBytes = await imageFile.readAsBytes();
      print('✅ Successfully read ${imageBytes.length} bytes');
      
      // Get content type
      final contentType = _getContentType(imageFile.path);
      print('🏷️ Content type: $contentType');
      
      // Delete old profile image if exists
      await _deleteOldProfileImage(userId);
      
      // Upload to Supabase Storage
      print('⬆️ Uploading profile image to Supabase Storage...');
      final response = await _supabase.storage.from(bucketName).uploadBinary(
        fileName,
        imageBytes,
        fileOptions: FileOptions(
          contentType: contentType,
          upsert: false,
        ),
      );
      
      print('✅ Profile image upload response received');
      print('📄 Upload response: $response');
      
      // Get public URL
      print('🔗 Getting profile image public URL...');
      final String publicUrl = _supabase.storage
          .from(bucketName)
          .getPublicUrl(fileName);
      
      print('🎉 Profile image upload success! Public URL: $publicUrl');
      return publicUrl;
      
    } catch (e, stackTrace) {
      print('❌ Error uploading profile image: $e');
      print('📚 Stack trace: $stackTrace');
      return null;
    }
  }

  /// Delete old profile image for a user (NEW)
  Future<void> _deleteOldProfileImage(String userId) async {
    try {
      print('🗑️ Checking for old profile images for user: $userId');
      
      // List files in the user's profile folder
      final files = await _supabase.storage
          .from(bucketName)
          .list(path: 'profiles/$userId');
      
      if (files.isNotEmpty) {
        print('🗑️ Found ${files.length} old profile image(s), deleting...');
        final filePaths = files.map((file) => 'profiles/$userId/${file.name}').toList();
        await _supabase.storage.from(bucketName).remove(filePaths);
        print('✅ Old profile images deleted');
      } else {
        print('ℹ️ No old profile images found');
      }
    } catch (e) {
      print('⚠️ Error deleting old profile image (continuing anyway): $e');
      // Don't throw error here as upload should still proceed
    }
  }

  /// Delete profile image (NEW)
  Future<bool> deleteProfileImage(String imageUrl) async {
    try {
      print('🗑️ Deleting profile image: $imageUrl');
      
      // Extract filename from URL
      final fileName = _extractFileNameFromUrl(imageUrl);
      if (fileName == null) {
        print('❌ Could not extract filename from profile image URL');
        return false;
      }
      
      print('📝 Profile image filename to delete: $fileName');
      
      await _supabase.storage.from(bucketName).remove([fileName]);
      print('✅ Profile image deleted successfully');
      return true;
      
    } catch (e) {
      print('❌ Error deleting profile image: $e');
      return false;
    }
  }

  /// Delete image from Supabase Storage (existing functionality)
  Future<bool> deleteImage(String imageUrl) async {
    try {
      print('🗑️ Deleting image: $imageUrl');
      
      // Extract filename from URL
      final fileName = _extractFileNameFromUrl(imageUrl);
      if (fileName == null) {
        print('❌ Could not extract filename from URL');
        return false;
      }
      
      print('📝 Filename to delete: $fileName');
      
      await _supabase.storage.from(bucketName).remove([fileName]);
      print('✅ Image deleted successfully');
      return true;
      
    } catch (e) {
      print('❌ Error deleting image: $e');
      return false;
    }
  }

  /// Update image (delete old and upload new) (existing functionality)
  Future<String?> updateImage(String oldImageUrl, File newImageFile) async {
    try {
      print('🔄 Updating image...');
      
      // Delete old image
      await deleteImage(oldImageUrl);
      
      // Upload new image
      return await uploadImage(newImageFile);
      
    } catch (e) {
      print('❌ Error updating image: $e');
      return null;
    }
  }

  /// Test Supabase connection and bucket access (existing functionality)
  Future<bool> testConnection() async {
    try {
      print('🧪 Testing Supabase connection...');
      
      // Test if we can list files in the bucket
      final files = await _supabase.storage.from(bucketName).list();
      print('✅ Successfully connected to bucket: $bucketName');
      print('📁 Found ${files.length} files in bucket');
      return true;
      
    } catch (e) {
      print('❌ Connection test failed: $e');
      
      if (e.toString().contains('Bucket not found')) {
        print('💡 Bucket "$bucketName" does not exist');
        print('💡 Please create it in Supabase Dashboard > Storage');
      }
      
      return false;
    }
  }

  /// Generate unique filename (existing functionality)
  String _generateUniqueFileName(String originalPath) {
    final extension = path.extension(originalPath);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomString = DateTime.now().microsecondsSinceEpoch.toString();
    return 'item_${timestamp}_$randomString$extension';
  }

  /// Get content type based on file extension (existing functionality)
  String _getContentType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  /// Extract filename from Supabase URL (existing functionality)
  String? _extractFileNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      if (pathSegments.length >= 3) {
        // URL format: https://xxx.supabase.co/storage/v1/object/public/bucket-name/filename
        // For profiles: profiles/user_id/profile_image.jpg
        final bucketIndex = pathSegments.indexWhere((segment) => segment == bucketName);
        if (bucketIndex != -1 && bucketIndex < pathSegments.length - 1) {
          final pathAfterBucket = pathSegments.sublist(bucketIndex + 1).join('/');
          return pathAfterBucket;
        }
        return pathSegments.last;
      }
      return null;
    } catch (e) {
      print('❌ Error extracting filename from URL: $e');
      return null;
    }
  }

  /// Get file info from Supabase Storage (existing functionality)
  Future<FileObject?> getFileInfo(String fileName) async {
    try {
      final List<FileObject> files = await _supabase.storage
          .from(bucketName)
          .list(path: path.dirname(fileName));
      
      return files.firstWhere(
        (file) => file.name == path.basename(fileName),
        orElse: () => throw Exception('File not found'),
      );
    } catch (e) {
      print('❌ Error getting file info: $e');
      return null;
    }
  }

  /// List all images in the bucket (existing functionality)
  Future<List<FileObject>> listImages() async {
    try {
      return await _supabase.storage.from(bucketName).list();
    } catch (e) {
      print('❌ Error listing images: $e');
      return [];
    }
  }
}