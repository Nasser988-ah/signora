import 'dart:io';
import 'dart:typed_data';
import 'dart:isolate';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import '../models/course.dart';
import '../models/lesson.dart';
import '../models/lesson_upload.dart';
import '../models/user_profile.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;
  
  // Upload optimization settings
  static const int _maxConcurrentUploads = 3;
  static const int _chunkSize = 1024 * 1024; // 1MB chunks
  static const int _maxImageSize = 1920; // Max image dimension
  static const int _imageQuality = 85; // Image compression quality
  
  // Initialize Supabase (call this in main.dart)
  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }

  // Authentication
  static User? get currentUser => _client.auth.currentUser;
  static bool get isLoggedIn => currentUser != null;

  // Sign up with email and password
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String userType,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'user_type': userType,
      },
    );

    // Create profile record
    if (response.user != null) {
      await _client.from('profiles').insert({
        'id': response.user!.id,
        'email': email,
        'full_name': fullName,
        'user_type': userType,
      });
    }

    return response;
  }

  // Sign in with email and password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign out
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Get current user profile
  static Future<UserProfile?> getCurrentUserProfile() async {
    if (!isLoggedIn) return null;

    final response = await _client
        .from('profiles')
        .select()
        .eq('id', currentUser!.id)
        .single();

    return UserProfile.fromJson(response);
  }

  // Course Management
  
  // Upload course (for professors) - using Firebase auth
  static Future<Course> uploadCourse({
    required String title,
    required String description,
    required double price,
    required int durationMinutes,
    required String category,
    required String difficultyLevel,
    File? thumbnailFile,
    File? videoFile,
  }) async {
    // Get current Firebase user
    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      throw Exception('User not logged in');
    }
    
    final userId = firebaseUser.uid;
    final userName = firebaseUser.displayName ?? firebaseUser.email ?? 'Professor User';

    String? thumbnailUrl;
    String? videoUrl;

    // Upload thumbnail if provided
    if (thumbnailFile != null) {
      final thumbnailPath = 'course-thumbnails/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await _client.storage.from('courses').upload(thumbnailPath, thumbnailFile);
      thumbnailUrl = _client.storage.from('courses').getPublicUrl(thumbnailPath);
    }

    // Upload video if provided
    if (videoFile != null) {
      final videoPath = 'course-videos/$userId/${DateTime.now().millisecondsSinceEpoch}.mp4';
      await _client.storage.from('courses').upload(videoPath, videoFile);
      videoUrl = _client.storage.from('courses').getPublicUrl(videoPath);
    }

    // Create course record
    final courseData = {
      'title': title,
      'description': description,
      'instructor_id': userId,
      'instructor_name': userName,
      'price': price,
      'duration_minutes': durationMinutes,
      'category': category,
      'difficulty_level': difficultyLevel,
      'thumbnail_url': thumbnailUrl,
      'video_url': videoUrl,
      'created_at': DateTime.now().toIso8601String(),
    };

    final response = await _client
        .from('courses')
        .insert(courseData)
        .select()
        .single();

    return Course.fromJson(response);
  }

  // Get all courses
  static Future<List<Course>> getAllCourses() async {
    try {
      final response = await _client
          .from('courses')
          .select()
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((courseData) => Course.fromJson(courseData))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch courses: $e');
    }
  }

  // Get courses created by the current professor
  static Future<List<Course>> getProfessorCourses() async {
    try {
      // Use Firebase Auth to get current user ID
      final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        throw Exception('User not authenticated');
      }

      final response = await _client
          .from('courses')
          .select('*, lessons(*)')
          .eq('instructor_id', firebaseUser.uid)
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((courseData) => Course.fromJson(courseData))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch professor courses: $e');
    }
  }

  // Get courses by professor ID
  static Future<List<Course>> getCoursesByProfessor(String professorId) async {
    final response = await _client
        .from('courses')
        .select('*, lessons(*)')
        .eq('instructor_id', professorId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((courseJson) => Course.fromJson(courseJson))
        .toList();
  }

  // Get course by ID
  static Future<Course?> getCourseById(String courseId) async {
    final response = await _client
        .from('courses')
        .select()
        .eq('id', courseId)
        .single();

    return Course.fromJson(response);
  }

  // Search courses
  static Future<List<Course>> searchCourses(String query) async {
    final response = await _client
        .from('courses')
        .select()
        .or('title.ilike.%$query%,description.ilike.%$query%,category.ilike.%$query%')
        .order('created_at', ascending: false);

    return (response as List)
        .map((courseJson) => Course.fromJson(courseJson))
        .toList();
  }

  // Enroll in course (for students)
  static Future<void> enrollInCourse(String courseId) async {
    if (!isLoggedIn) throw Exception('User not logged in');

    await _client.from('enrollments').insert({
      'student_id': currentUser!.id,
      'course_id': courseId,
    });
  }

  // Get enrolled courses (for students)
  static Future<List<Course>> getEnrolledCourses() async {
    if (!isLoggedIn) throw Exception('User not logged in');

    final response = await _client
        .from('enrollments')
        .select('courses(*)')
        .eq('student_id', currentUser!.id);

    return (response as List)
        .map((enrollment) => Course.fromJson(enrollment['courses']))
        .toList();
  }

  // Check if student is enrolled in course
  static Future<bool> isEnrolledInCourse(String courseId) async {
    if (!isLoggedIn) return false;

    final response = await _client
        .from('enrollments')
        .select()
        .eq('student_id', currentUser!.id)
        .eq('course_id', courseId);

    return response.isNotEmpty;
  }

  // Update course (for professors)
  static Future<Course> updateCourse({
    required String courseId,
    required String title,
    required String description,
    required double price,
    required int durationMinutes,
    required String category,
    required String difficultyLevel,
    File? thumbnailFile,
    File? videoFile,
    List<String>? pdfUrls,
    List<String>? audioUrls,
    List<LessonUpload>? lessons,
  }) async {
    // Get current Firebase user
    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      throw Exception('User not logged in');
    }
    
    final userId = firebaseUser.uid;

    String? thumbnailUrl;
    String? videoUrl;

    // Upload new thumbnail if provided
    if (thumbnailFile != null) {
      final thumbnailPath = 'course-thumbnails/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await _client.storage.from('courses').upload(thumbnailPath, thumbnailFile);
      thumbnailUrl = _client.storage.from('courses').getPublicUrl(thumbnailPath);
    }

    // Upload new video if provided
    if (videoFile != null) {
      final videoPath = 'course-videos/$userId/${DateTime.now().millisecondsSinceEpoch}.mp4';
      await _client.storage.from('courses').upload(videoPath, videoFile);
      videoUrl = _client.storage.from('courses').getPublicUrl(videoPath);
    }

    // Prepare update data
    final updateData = <String, dynamic>{
      'title': title,
      'description': description,
      'price': price,
      'duration_minutes': durationMinutes,
      'category': category,
      'difficulty_level': difficultyLevel,
      'updated_at': DateTime.now().toIso8601String(),
    };

    // Only update URLs if new files were uploaded
    if (thumbnailUrl != null) updateData['thumbnail_url'] = thumbnailUrl;
    if (videoUrl != null) updateData['video_url'] = videoUrl;
    if (pdfUrls != null) updateData['pdf_urls'] = pdfUrls;
    if (audioUrls != null) updateData['audio_urls'] = audioUrls;

    final response = await _client
        .from('courses')
        .update(updateData)
        .eq('id', courseId)
        .eq('instructor_id', userId) // Ensure professor can only update their own courses
        .select()
        .single();

    // Handle lessons update
    if (lessons != null) {
      print('Processing ${lessons.length} lessons for course $courseId');
      
      // First, delete existing lessons for this course
      await _client
          .from('lessons')
          .delete()
          .eq('course_id', courseId);
      
      print('Deleted existing lessons for course $courseId');

      // Then, insert new lessons
      for (int i = 0; i < lessons.length; i++) {
        final lesson = lessons[i];
        String? videoUrl;

        print('Processing lesson $i: ${lesson.title}');

        // Use YouTube URL directly - no file upload needed
        final youtubeUrl = lesson.youtubeUrl.trim();
        if (youtubeUrl.isEmpty || !lesson.isValidYouTubeUrl) {
          print('Warning: Lesson $i has invalid YouTube URL');
          continue; // Skip lessons without valid YouTube URL
        }

        // Use the duration provided in the lesson
        final duration = lesson.durationMinutes > 0 ? lesson.durationMinutes : 5; // Default 5 minutes

        // Insert lesson record with YouTube URL
        final lessonData = {
          'course_id': courseId,
          'title': lesson.title,
          'description': lesson.description ?? '',
          'youtube_url': youtubeUrl,
          'duration_minutes': duration,
          'order_index': lesson.orderIndex,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };
        
        print('Inserting lesson data: $lessonData');
        
        await _client.from('lessons').insert(lessonData);
        
        print('Successfully inserted lesson $i');
      }
      
      print('Completed processing all lessons');
    }

    return Course.fromJson(response);
  }

  // Delete course (for professors)
  static Future<void> deleteCourse(String courseId) async {
    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      throw Exception('User not logged in');
    }

    await _client
        .from('courses')
        .delete()
        .eq('id', courseId)
        .eq('instructor_id', firebaseUser.uid); // Ensure professor can only delete their own courses
  }

  // Upload course with multiple lessons
  static Future<Course> uploadCourseWithLessons({
    required String title,
    required String description,
    required double price,
    required String category,
    required String difficultyLevel,
    required File thumbnailFile,
    required List<LessonUpload> lessons,
    List<File>? pdfFiles,
    List<File>? audioFiles,
    Function(int progress, String status)? onProgress,
  }) async {
    // Check network connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('No internet connection. Please check your network and try again.');
    }
    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      throw Exception('User not logged in');
    }
    
    final userId = firebaseUser.uid;

    // Optimize and upload thumbnail
    onProgress?.call(5, 'Optimizing and uploading thumbnail...');
    final thumbnailPath = 'course-thumbnails/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
    
    // Compress thumbnail for faster upload
    final optimizedThumbnail = await _compressImage(thumbnailFile);
    
    String? thumbnailUrl;
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        await _client.storage.from('courses').uploadBinary(
          thumbnailPath, 
          optimizedThumbnail,
          fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: false,
          ),
        );
        thumbnailUrl = _client.storage.from('courses').getPublicUrl(thumbnailPath);
        break;
      } catch (e) {
        if (attempt == 3) {
          throw Exception('Failed to upload thumbnail after 3 attempts: ${e.toString()}');
        }
        onProgress?.call(5 + (attempt * 2), 'Retrying thumbnail upload (attempt $attempt)...');
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }
    onProgress?.call(15, 'Thumbnail uploaded successfully');

    // Calculate total duration from all lessons
    int totalDuration = 0;
    for (final lesson in lessons) {
      // Use the duration provided in the lesson
      totalDuration += lesson.durationMinutes;
    }

    // Create course
    onProgress?.call(20, 'Creating course record...');
    final courseResponse = await _client.from('courses').insert({
      'title': title,
      'description': description,
      'instructor_id': userId,
      'instructor_name': firebaseUser.displayName ?? 'Unknown',
      'price': price,
      'duration_minutes': totalDuration,
      'category': category,
      'difficulty_level': difficultyLevel,
      'thumbnail_url': thumbnailUrl,
      'rating': 0.0,
      'total_ratings': 0,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }).select().single();
    onProgress?.call(25, 'Course record created');

    final courseId = courseResponse['id'] as String;

    // Create lessons with YouTube URLs
    final totalLessons = lessons.length;
    onProgress?.call(25, 'Creating lesson records...');
    print('DEBUG: Creating $totalLessons lessons for course $courseId');
    
    for (int i = 0; i < lessons.length; i++) {
      final lesson = lessons[i];
      final lessonProgress = 25 + ((i / totalLessons) * 50).round();
      
      print('DEBUG: Creating lesson ${i + 1}: ${lesson.title}');
      onProgress?.call(lessonProgress, 'Creating lesson ${i + 1} of $totalLessons: ${lesson.title}');
      
      // Validate YouTube URL
      if (lesson.youtubeUrl.trim().isEmpty || !lesson.isValidYouTubeUrl) {
        throw Exception('Lesson ${i + 1} has invalid YouTube URL');
      }
      
      // Use YouTube URL directly - no file upload needed
      final youtubeUrl = lesson.youtubeUrl.trim();
      print('DEBUG: Using YouTube URL: $youtubeUrl');

      // Create lesson record with YouTube URL
      final lessonData = {
        'course_id': courseId,
        'title': lesson.title,
        'description': lesson.description,
        'youtube_url': youtubeUrl,
        'duration_minutes': lesson.durationMinutes,
        'order_index': lesson.orderIndex,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      print('DEBUG: Inserting lesson record: $lessonData');
      try {
        final insertResult = await _client.from('lessons').insert(lessonData).select();
        print('DEBUG: Lesson record created successfully: $insertResult');
        
        // Verify the lesson was actually created
        final verifyResult = await _client
            .from('lessons')
            .select()
            .eq('course_id', courseId)
            .eq('order_index', lesson.orderIndex)
            .single();
        
        if (verifyResult == null) {
          throw Exception('Lesson ${i + 1} was not properly saved to database');
        }
        
        print('DEBUG: Lesson ${i + 1} verified in database');
        onProgress?.call(lessonProgress + 2, 'Lesson ${i + 1} uploaded and verified');
      } catch (e) {
        print('DEBUG: Database insert failed: $e');
        throw Exception('Failed to save lesson ${i + 1} to database: ${e.toString()}');
      }
    }
    
    // Final verification - count total lessons in database
    try {
      final lessons = await _client
          .from('lessons')
          .select('id')
          .eq('course_id', courseId);
      
      final lessonCount = lessons.length;
      
      print('DEBUG: Total lessons in database: $lessonCount, Expected: $totalLessons');
      
      if (lessonCount != totalLessons) {
        throw Exception('Lesson count mismatch: Expected $totalLessons, Found $lessonCount');
      }
    } catch (e) {
      print('DEBUG: Lesson verification failed: $e');
      throw Exception('Failed to verify all lessons were saved: ${e.toString()}');
    }
    
    onProgress?.call(75, 'All $totalLessons lessons created and verified successfully');

    // Upload additional files in parallel
    final additionalUploads = <Future<void>>[];
    
    // Upload PDF files (optional)
    if (pdfFiles != null && pdfFiles.isNotEmpty) {
      onProgress?.call(80, 'Uploading PDF materials...');
      for (int i = 0; i < pdfFiles.length; i++) {
        final pdfFile = pdfFiles[i];
        final pdfPath = 'course-materials/$userId/$courseId/pdfs/${DateTime.now().millisecondsSinceEpoch}_$i.pdf';
        additionalUploads.add(
          _uploadLargeFile(
            'courses',
            pdfPath,
            pdfFile,
            null,
          ),
        );
      }
    }

    // Upload Audio files (optional)
    if (audioFiles != null && audioFiles.isNotEmpty) {
      onProgress?.call(85, 'Uploading audio materials...');
      for (int i = 0; i < audioFiles.length; i++) {
        final audioFile = audioFiles[i];
        final audioPath = 'course-materials/$userId/$courseId/audio/${DateTime.now().millisecondsSinceEpoch}_$i.mp3';
        additionalUploads.add(
          _uploadLargeFile(
            'courses',
            audioPath,
            audioFile,
            null,
          ),
        );
      }
    }
    
    // Wait for all additional uploads to complete
    if (additionalUploads.isNotEmpty) {
      await Future.wait(additionalUploads);
      onProgress?.call(95, 'All materials uploaded');
    }

    // Finalize upload
    onProgress?.call(100, 'Course upload completed successfully!');
    
    // Return the created course
    return Course.fromJson(courseResponse);
  }

  // Get lessons for a course
  static Future<List<Lesson>> getLessonsForCourse(String courseId) async {
    final response = await _client
        .from('lessons')
        .select()
        .eq('course_id', courseId)
        .order('order_index', ascending: true);

    return (response as List)
        .map((lessonJson) => Lesson.fromJson(lessonJson))
        .toList();
  }

  // UPLOAD OPTIMIZATION HELPERS
  
  /// Helper method for image compression and resizing
  static Future<Uint8List> _compressImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);
    
    if (image == null) throw Exception('Failed to decode image');
    
    // Resize to max 800x600 while maintaining aspect ratio
    final resized = img.copyResize(
      image,
      width: image.width > image.height ? 800 : null,
      height: image.height > image.width ? 600 : null,
    );
    
    // Compress as JPEG with 85% quality
    return Uint8List.fromList(img.encodeJpg(resized, quality: 85));
  }

  // Helper method for simplified large file upload with progress simulation
  static Future<void> _uploadLargeFile(
    String bucketName,
    String filePath,
    File file,
    Function(int)? onProgress,
  ) async {
    // For large files, we'll use the standard upload but simulate progress
    // In a production app, you might want to implement chunked uploads
    
    if (onProgress != null) {
      // Simulate upload progress
      for (int i = 0; i <= 100; i += 10) {
        onProgress(i);
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
    
    await _client.storage.from(bucketName).upload(filePath, file);
  }

  // Get professor profile by email
  static Future<Map<String, dynamic>?> getProfessorProfile(String email) async {
    try {
      final response = await _client
          .from('profiles')
          .select('bio, subject')
          .eq('email', email)
          .eq('user_type', 'professor')
          .maybeSingle();
      
      return response;
    } catch (e) {
      print('Error getting professor profile: $e');
      return null;
    }
  }

  // Update professor profile (bio and subject)
  static Future<void> updateProfessorProfile(
    String email, {
    String? bio,
    String? subject,
  }) async {
    try {
      // First check if profile exists
      final existingProfile = await _client
          .from('profiles')
          .select('id')
          .eq('email', email)
          .eq('user_type', 'professor')
          .maybeSingle();

      final updateData = <String, dynamic>{};
      if (bio != null) updateData['bio'] = bio;
      if (subject != null) updateData['subject'] = subject;
      updateData['updated_at'] = DateTime.now().toIso8601String();

      if (existingProfile != null) {
        // Update existing profile
        await _client
            .from('profiles')
            .update(updateData)
            .eq('email', email)
            .eq('user_type', 'professor');
      } else {
        // Create new profile
        updateData['email'] = email;
        updateData['user_type'] = 'professor';
        updateData['created_at'] = DateTime.now().toIso8601String();
        
        await _client
            .from('profiles')
            .insert(updateData);
      }
    } catch (e) {
      print('Error updating professor profile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }
  
  /// Compresses video files before upload (placeholder for future implementation)
  static Future<File> _optimizeVideo(File videoFile) async {
    // TODO: Implement video compression using ffmpeg_kit_flutter
    // For now, return original file
    return videoFile;
  }
  
  /// Validates file before upload to prevent errors
  static Future<bool> _validateFile(File file) async {
    try {
      final exists = await file.exists();
      if (!exists) return false;
      
      final size = await file.length();
      if (size == 0) return false;
      
      // Check file size limits (500MB max for videos, 10MB for images)
      final extension = path.extension(file.path).toLowerCase();
      if (['.mp4', '.mov', '.avi'].contains(extension)) {
        return size <= 500 * 1024 * 1024; // 500MB
      } else if (['.jpg', '.jpeg', '.png'].contains(extension)) {
        return size <= 10 * 1024 * 1024; // 10MB
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }
}
