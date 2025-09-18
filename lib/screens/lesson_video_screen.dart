import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/lesson.dart';
import 'youtube_player_screen.dart';

class LessonVideoScreen extends StatefulWidget {
  final Lesson lesson;
  final List<Lesson> allLessons;
  final int currentIndex;

  const LessonVideoScreen({
    Key? key,
    required this.lesson,
    required this.allLessons,
    required this.currentIndex,
  }) : super(key: key);

  @override
  State<LessonVideoScreen> createState() => _LessonVideoScreenState();
}

class _LessonVideoScreenState extends State<LessonVideoScreen> {
  late Lesson _currentLesson;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentLesson = widget.lesson;
    _currentIndex = widget.currentIndex;
    _initializeVideo();
    
    // Set to landscape mode for better video experience
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    // Reset to portrait mode when leaving
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    
    super.dispose();
  }

  void _initializeVideo() {
    // Navigate to YouTube player screen instead of using video controller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => YouTubePlayerScreen(
            lesson: _currentLesson,
            allLessons: widget.allLessons,
            currentIndex: _currentIndex,
          ),
        ),
      );
    });
  }

  void _playNextLesson() {
    // This method is no longer needed as navigation is handled by YouTubePlayerScreen
  }

  void _playPreviousLesson() {
    // This method is no longer needed as navigation is handled by YouTubePlayerScreen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF3B82F6),
        ),
      ),
    );
  }
}
