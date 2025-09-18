import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/course.dart';

class SavedCoursesService {
  static const String _savedCoursesKey = 'saved_courses';

  // Save a course to the user's saved courses
  static Future<void> saveCourse(Course course) async {
    final prefs = await SharedPreferences.getInstance();
    final savedCourses = await getSavedCourses();
    
    // Check if course is already saved
    if (!savedCourses.any((savedCourse) => savedCourse.id == course.id)) {
      savedCourses.add(course);
      final coursesJson = savedCourses.map((course) => course.toJson()).toList();
      await prefs.setString(_savedCoursesKey, json.encode(coursesJson));
    }
  }

  // Remove a course from saved courses
  static Future<void> removeSavedCourse(String courseId) async {
    final prefs = await SharedPreferences.getInstance();
    final savedCourses = await getSavedCourses();
    
    savedCourses.removeWhere((course) => course.id == courseId);
    final coursesJson = savedCourses.map((course) => course.toJson()).toList();
    await prefs.setString(_savedCoursesKey, json.encode(coursesJson));
  }

  // Get all saved courses for the current user
  static Future<List<Course>> getSavedCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final coursesString = prefs.getString(_savedCoursesKey);
    
    if (coursesString == null) {
      return [];
    }

    try {
      final List<dynamic> coursesJson = json.decode(coursesString);
      return coursesJson.map((courseJson) => Course.fromJson(courseJson)).toList();
    } catch (e) {
      return [];
    }
  }

  // Check if a course is saved
  static Future<bool> isCoursesSaved(String courseId) async {
    final savedCourses = await getSavedCourses();
    return savedCourses.any((course) => course.id == courseId);
  }

  // Get saved courses count
  static Future<int> getSavedCoursesCount() async {
    final savedCourses = await getSavedCourses();
    return savedCourses.length;
  }

  // Clear all saved courses
  static Future<void> clearAllSavedCourses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_savedCoursesKey);
  }
}
