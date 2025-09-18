import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

class FileUploadService {
  static final _supabase = Supabase.instance.client;

  // Upload PDF files to Supabase storage
  static Future<List<String>> uploadPdfFiles(List<File> pdfFiles, String courseId) async {
    final List<String> uploadedUrls = [];
    
    try {
      for (int i = 0; i < pdfFiles.length; i++) {
        final file = pdfFiles[i];
        final fileName = '${courseId}_pdf_${i + 1}_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final filePath = 'courses/$courseId/pdfs/$fileName';
        
        // Upload to Supabase storage
        await _supabase.storage
            .from('course-materials')
            .upload(filePath, file);
        
        // Get public URL
        final publicUrl = _supabase.storage
            .from('course-materials')
            .getPublicUrl(filePath);
        
        uploadedUrls.add(publicUrl);
      }
      
      return uploadedUrls;
    } catch (e) {
      throw Exception('Failed to upload PDF files: $e');
    }
  }

  // Upload audio files to Supabase storage
  static Future<List<String>> uploadAudioFiles(List<File> audioFiles, String courseId) async {
    final List<String> uploadedUrls = [];
    
    try {
      for (int i = 0; i < audioFiles.length; i++) {
        final file = audioFiles[i];
        final extension = path.extension(file.path);
        final fileName = '${courseId}_audio_${i + 1}_${DateTime.now().millisecondsSinceEpoch}$extension';
        final filePath = 'courses/$courseId/audio/$fileName';
        
        // Upload to Supabase storage
        await _supabase.storage
            .from('course-materials')
            .upload(filePath, file);
        
        // Get public URL
        final publicUrl = _supabase.storage
            .from('course-materials')
            .getPublicUrl(filePath);
        
        uploadedUrls.add(publicUrl);
      }
      
      return uploadedUrls;
    } catch (e) {
      throw Exception('Failed to upload audio files: $e');
    }
  }

  // Pick PDF files using file picker
  static Future<List<File>?> pickPdfFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );
      
      if (result != null && result.files.isNotEmpty) {
        return result.files
            .where((file) => file.path != null)
            .map((file) => File(file.path!))
            .toList();
      }
      
      return null;
    } catch (e) {
      throw Exception('Failed to pick PDF files: $e');
    }
  }

  // Pick audio files using file picker
  static Future<List<File>?> pickAudioFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a', 'aac', 'ogg'],
        allowMultiple: true,
      );
      
      if (result != null && result.files.isNotEmpty) {
        return result.files
            .where((file) => file.path != null)
            .map((file) => File(file.path!))
            .toList();
      }
      
      return null;
    } catch (e) {
      throw Exception('Failed to pick audio files: $e');
    }
  }

  // Delete files from Supabase storage
  static Future<void> deleteFiles(List<String> fileUrls) async {
    try {
      for (final url in fileUrls) {
        // Extract file path from URL
        final uri = Uri.parse(url);
        final pathSegments = uri.pathSegments;
        final bucketIndex = pathSegments.indexOf('course-materials');
        
        if (bucketIndex != -1 && bucketIndex < pathSegments.length - 1) {
          final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
          
          await _supabase.storage
              .from('course-materials')
              .remove([filePath]);
        }
      }
    } catch (e) {
      throw Exception('Failed to delete files: $e');
    }
  }

  // Get file size in MB
  static String getFileSizeString(File file) {
    final bytes = file.lengthSync();
    final mb = bytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  // Get file name from path
  static String getFileName(String filePath) {
    return path.basename(filePath);
  }
}
