import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/lesson.dart';

class YouTubePlayerScreen extends StatefulWidget {
  final Lesson lesson;
  final List<Lesson> allLessons;
  final int currentIndex;

  const YouTubePlayerScreen({
    super.key,
    required this.lesson,
    required this.allLessons,
    required this.currentIndex,
  });

  @override
  State<YouTubePlayerScreen> createState() => _YouTubePlayerScreenState();
}

class _YouTubePlayerScreenState extends State<YouTubePlayerScreen> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    final videoId = widget.lesson.youtubeVideoId;
    if (videoId != null) {
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          enableCaption: true,
          captionLanguage: 'en',
          showLiveFullscreenButton: true,
        ),
      );
      _controller.addListener(_onPlayerStateChange);
    }
  }

  void _onPlayerStateChange() {
    if (_controller.value.isReady && !_isPlayerReady) {
      setState(() {
        _isPlayerReady = true;
      });
    }

    if (_controller.value.isFullScreen != _isFullScreen) {
      setState(() {
        _isFullScreen = _controller.value.isFullScreen;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToLesson(int index) {
    if (index >= 0 && index < widget.allLessons.length) {
      final newLesson = widget.allLessons[index];
      final newVideoId = newLesson.youtubeVideoId;
      
      if (newVideoId != null) {
        _controller.load(newVideoId);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => YouTubePlayerScreen(
              lesson: newLesson,
              allLessons: widget.allLessons,
              currentIndex: index,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final videoId = widget.lesson.youtubeVideoId;
    
    if (videoId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Invalid Video'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text(
            'Invalid YouTube URL',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        backgroundColor: Colors.black,
      );
    }

    return YoutubePlayerBuilder(
      onExitFullScreen: () {
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      },
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: const Color(0xFF3B82F6),
        topActions: <Widget>[
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              widget.lesson.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18.0,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
              size: 25.0,
            ),
            onPressed: () {
              // Settings functionality can be added here
            },
          ),
        ],
        onReady: () {
          _isPlayerReady = true;
        },
        onEnded: (data) {
          // Auto-play next lesson if available
          if (widget.currentIndex < widget.allLessons.length - 1) {
            _navigateToLesson(widget.currentIndex + 1);
          }
        },
      ),
      builder: (context, player) => Scaffold(
        backgroundColor: Colors.black,
        appBar: _isFullScreen
            ? null
            : AppBar(
                title: Text(
                  widget.lesson.title,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
        body: Column(
          children: [
            // YouTube Player
            player,
            
            // Lesson Info and Controls
            if (!_isFullScreen) ...[
              Expanded(
                child: Container(
                  color: Colors.black,
                  child: Column(
                    children: [
                      // Lesson Details
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        color: const Color(0xFF1F1F1F),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.lesson.title,
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.lesson.formattedDuration,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.grey[400],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Icon(
                                  Icons.play_lesson,
                                  size: 16,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Lesson ${widget.currentIndex + 1} of ${widget.allLessons.length}',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                            if (widget.lesson.description?.isNotEmpty == true) ...[
                              const SizedBox(height: 12),
                              Text(
                                widget.lesson.description!,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.grey[300],
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      
                      // Navigation Controls
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Previous Lesson
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: widget.currentIndex > 0
                                    ? () => _navigateToLesson(widget.currentIndex - 1)
                                    : null,
                                icon: const Icon(Icons.skip_previous),
                                label: const Text('Previous'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF374151),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Next Lesson
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: widget.currentIndex < widget.allLessons.length - 1
                                    ? () => _navigateToLesson(widget.currentIndex + 1)
                                    : null,
                                icon: const Icon(Icons.skip_next),
                                label: const Text('Next'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3B82F6),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Lesson List
                      Expanded(
                        child: Container(
                          color: const Color(0xFF111111),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'Course Lessons',
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: widget.allLessons.length,
                                  itemBuilder: (context, index) {
                                    final lesson = widget.allLessons[index];
                                    final isCurrentLesson = index == widget.currentIndex;
                                    
                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isCurrentLesson
                                            ? const Color(0xFF3B82F6).withOpacity(0.2)
                                            : const Color(0xFF1F1F1F),
                                        borderRadius: BorderRadius.circular(8),
                                        border: isCurrentLesson
                                            ? Border.all(
                                                color: const Color(0xFF3B82F6),
                                                width: 1,
                                              )
                                            : null,
                                      ),
                                      child: ListTile(
                                        leading: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: isCurrentLesson
                                                ? const Color(0xFF3B82F6)
                                                : const Color(0xFF374151),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: isCurrentLesson
                                                ? const Icon(
                                                    Icons.play_arrow,
                                                    color: Colors.white,
                                                    size: 20,
                                                  )
                                                : Text(
                                                    '${index + 1}',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        title: Text(
                                          lesson.title,
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        subtitle: Text(
                                          lesson.formattedDuration,
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                        onTap: isCurrentLesson
                                            ? null
                                            : () => _navigateToLesson(index),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
