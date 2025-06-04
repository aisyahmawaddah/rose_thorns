import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:koopon/core/config/supabase_config.dart';

class SupabaseImageService {
  static const String bucketName = 'item-images'; // Your bucket name
  
  // Use getter instead of field to avoid early initialization
  SupabaseClient get _supabase => SupabaseConfig.client;

  /// Upload image to Supabase Storage with detailed debugging
  Future<String?> uploadImage(File imageFile, {String? customPath}) async {
    try {
      print('🔄 Starting image upload to Supabase...');
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
          upsert: false, // Set to true if you want to overwrite existing files
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
      print('❌ Error uploading image: $e');
      print('📚 Stack trace: $stackTrace');
      
      // More specific error handling
      if (e.toString().contains('Bucket not found')) {
        print('💡 Solution: Create a bucket named "$bucketName" in Supabase Storage');
      } else if (e.toString().contains('Unauthorized') || e.toString().contains('Permission denied')) {
        print('💡 Solution: Check bucket policies and ensure public access is enabled');
      } else if (e.toString().contains('Policy violation')) {
        print('💡 Solution: Update bucket policies to allow uploads');
      }
      
      return null;
    }
  }

  /// Test Supabase connection and bucket access
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

  /// Delete image from Supabase Storage
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

  /// Update image (delete old and upload new)
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

  /// Generate unique filename
  String _generateUniqueFileName(String originalPath) {
    final extension = path.extension(originalPath);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomString = DateTime.now().microsecondsSinceEpoch.toString();
    return 'item_${timestamp}_$randomString$extension';
  }

  /// Get content type based on file extension
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

  /// Extract filename from Supabase URL
  String? _extractFileNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      if (pathSegments.length >= 3) {
        // URL format: https://xxx.supabase.co/storage/v1/object/public/bucket-name/filename
        return pathSegments.last;
      }
      return null;
    } catch (e) {
      print('❌ Error extracting filename from URL: $e');
      return null;
    }
  }

  /// Get file info from Supabase Storage
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

  /// List all images in the bucket
  Future<List<FileObject>> listImages() async {
    try {
      return await _supabase.storage.from(bucketName).list();
    } catch (e) {
      print('❌ Error listing images: $e');
      return [];
    }
  }
}