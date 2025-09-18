import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'supabase_service.dart';
import '../models/lesson_upload.dart';

class BackgroundUploadService {
  static const String notificationChannelId = 'course_upload_channel';
  static const String notificationChannelName = 'Course Upload Progress';
  
  static final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  
  // Stream controller for progress updates
  static final StreamController<UploadProgress> _progressController = 
      StreamController<UploadProgress>.broadcast();
  
  // Getter for progress stream
  static Stream<UploadProgress> get progressStream => _progressController.stream;

  static Future<void> initialize() async {
    // Initialize notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    
    await _notifications.initialize(initializationSettings);
    
    // Request notification permissions
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    
    // Create notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      notificationChannelId,
      notificationChannelName,
      description: 'Shows progress of course uploads',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );
    
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> startCourseUpload({
    required String title,
    required String description,
    required double price,
    required String category,
    required String difficultyLevel,
    required String thumbnailPath,
    required List<Map<String, dynamic>> lessonsData,
    required List<String> pdfPaths,
    required List<String> audioPaths,
  }) async {
    // Emit initial progress
    _progressController.add(UploadProgress(
      progress: 0,
      status: 'Starting upload...',
      isComplete: false,
    ));
    
    // Show initial notification
    await _showUploadNotification(
      title: 'Uploading "$title"',
      body: 'Starting upload...',
      progress: 0,
    );
    
    // Start upload asynchronously
    _performCourseUploadAsync(
      title: title,
      description: description,
      price: price,
      category: category,
      difficultyLevel: difficultyLevel,
      thumbnailPath: thumbnailPath,
      lessonsData: lessonsData,
      pdfPaths: pdfPaths,
      audioPaths: audioPaths,
    );
  }

  static Future<void> _performCourseUploadAsync({
    required String title,
    required String description,
    required double price,
    required String category,
    required String difficultyLevel,
    required String thumbnailPath,
    required List<Map<String, dynamic>> lessonsData,
    required List<String> pdfPaths,
    required List<String> audioPaths,
  }) async {
    try {
      // Convert lesson data back to LessonUpload objects
      final List<LessonUpload> lessons = lessonsData.map((lessonData) {
        return LessonUpload(
          title: lessonData['title'],
          description: lessonData['description'],
          youtubeUrl: lessonData['youtubeUrl'] ?? '',
          orderIndex: lessonData['orderIndex'],
          durationMinutes: lessonData['durationMinutes'] ?? 0,
        );
      }).toList();

      // Convert file paths back to File objects
      final List<File> pdfFiles = pdfPaths.map((path) => File(path)).toList();
      final List<File> audioFiles = audioPaths.map((path) => File(path)).toList();

      // Perform actual upload with real progress tracking
      await SupabaseService.uploadCourseWithLessons(
        title: title,
        description: description,
        price: price,
        category: category,
        difficultyLevel: difficultyLevel,
        thumbnailFile: File(thumbnailPath),
        lessons: lessons,
        pdfFiles: pdfFiles.isNotEmpty ? pdfFiles : null,
        audioFiles: audioFiles.isNotEmpty ? audioFiles : null,
        onProgress: (progress, status) {
          // Update UI progress
          _emitProgress(progress, status);
          
          // Update notification
          updateProgress(
            courseName: title,
            progress: progress,
            status: status,
          );
        },
      );

      // Show completion notification
      await showCompletionNotification(
        courseName: title,
        success: true,
      );

    } catch (e) {
      print('Upload error: $e');
      _emitProgress(0, 'Upload failed: ${e.toString()}');
      await updateProgress(
        courseName: title,
        progress: 0,
        status: 'Upload failed: ${e.toString()}',
      );
      await showCompletionNotification(
        courseName: title,
        success: false,
      );
    }
  }
  
  static void _emitProgress(int progress, String status) {
    _progressController.add(UploadProgress(
      progress: progress,
      status: status,
      isComplete: progress >= 100,
    ));
  }

  static Future<void> _showUploadNotification({
    required String title,
    required String body,
    required int progress,
    bool isComplete = false,
  }) async {
    try {
      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        notificationChannelId,
        notificationChannelName,
        channelDescription: 'Shows progress of course uploads',
        importance: Importance.high,
        priority: Priority.high,
        showProgress: !isComplete,
        maxProgress: 100,
        progress: progress,
        indeterminate: false,
        ongoing: !isComplete,
        autoCancel: isComplete,
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        playSound: true,
        category: AndroidNotificationCategory.progress,
      );

      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      await _notifications.show(
        1001, // Unique notification ID for uploads
        title,
        body,
        notificationDetails,
      );
      
      print('Notification shown: $title - $body ($progress%)');
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  static Future<void> updateProgress({
    required String courseName,
    required int progress,
    required String status,
  }) async {
    await _showUploadNotification(
      title: 'Uploading "$courseName"',
      body: status,
      progress: progress,
    );
  }

  static Future<void> showCompletionNotification({
    required String courseName,
    required bool success,
  }) async {
    await _showUploadNotification(
      title: success ? 'Upload Complete' : 'Upload Failed',
      body: success 
          ? '"$courseName" uploaded successfully!'
          : 'Failed to upload "$courseName". Please try again.',
      progress: 100,
      isComplete: true,
    );
  }
  
  static void dispose() {
    _progressController.close();
  }
}

class UploadProgress {
  final int progress;
  final String status;
  final bool isComplete;
  
  UploadProgress({
    required this.progress,
    required this.status,
    required this.isComplete,
  });
}

