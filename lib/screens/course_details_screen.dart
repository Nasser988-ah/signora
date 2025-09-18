import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/course.dart';
import '../models/lesson.dart';
import '../services/supabase_service.dart';
import '../services/saved_courses_service.dart';
import 'lesson_video_screen.dart';
import 'enrollment_form_screen.dart';
import 'pdf_viewer_screen.dart';
import 'audio_player_screen.dart';

class CourseDetailsScreen extends StatefulWidget {
  final String courseTitle;
  final String instructor;
  final String price;
  final double rating;
  final Course? course; // Optional Supabase course object

  const CourseDetailsScreen({
    super.key,
    required this.courseTitle,
    required this.instructor,
    required this.price,
    required this.rating,
    this.course,
  });

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isVideoInitialized = false;
  List<Lesson> _lessons = [];
  bool _isLoadingLessons = true;
  Lesson? _currentLesson;

  @override
  void initState() {
    super.initState();
    _loadLessons();
    _initializeVideo();
  }

  Future<void> _loadLessons() async {
    if (widget.course?.id != null) {
      try {
        final lessons = await SupabaseService.getLessonsForCourse(widget.course!.id);
        setState(() {
          _lessons = lessons;
          _isLoadingLessons = false;
          if (_lessons.isNotEmpty) {
            _currentLesson = _lessons.first;
          }
        });
        // Initialize video with first lesson if available, otherwise use course video
        if (_lessons.isNotEmpty && mounted) {
          _initializeVideoForLesson(_lessons.first);
        } else if (mounted) {
          _initializeVideo(); // Fallback to course video
        }
      } catch (e) {
        setState(() {
          _isLoadingLessons = false;
        });
      }
    } else {
      setState(() {
        _isLoadingLessons = false;
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  void _initializeVideo() {
    // Initialize course video if no lessons available
    if (widget.course?.videoUrl != null && _lessons.isEmpty) {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.course!.videoUrl!),
      );
      
      _videoController!.initialize().then((_) {
        setState(() {
          _isVideoInitialized = true;
          _chewieController = ChewieController(
            videoPlayerController: _videoController!,
            autoPlay: false,
            looping: false,
            showControls: true,
            materialProgressColors: ChewieProgressColors(
              playedColor: const Color(0xFF5B6FEE),
              handleColor: const Color(0xFF5B6FEE),
              backgroundColor: Colors.grey.shade300,
              bufferedColor: Colors.grey.shade200,
            ),
          );
        });
      }).catchError((error) {
        print('Video initialization error: $error');
      });
    }
  }

  void _initializeVideoForLesson(Lesson lesson) {
    // Dispose previous controllers
    _videoController?.dispose();
    _chewieController?.dispose();

    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(lesson.youtubeUrl),
    );
      
    _videoController!.initialize().then((_) {
      setState(() {
        _isVideoInitialized = true;
        _chewieController = ChewieController(
          videoPlayerController: _videoController!,
          autoPlay: false,
          looping: false,
          showControls: true,
          materialProgressColors: ChewieProgressColors(
            playedColor: const Color(0xFF5B6FEE),
            handleColor: const Color(0xFF5B6FEE),
            backgroundColor: Colors.grey.shade300,
            bufferedColor: Colors.grey.shade200,
          ),
        );
      });
    }).catchError((error) {
      print('Video initialization error: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(child: _buildHeader()),

            // Course Title
            SliverToBoxAdapter(child: _buildCourseTitle()),

            // Video Section
            SliverToBoxAdapter(child: _buildVideoSection()),

            // Instructor Section
            SliverToBoxAdapter(child: _buildInstructorSection()),

            // Stats Section
            SliverToBoxAdapter(child: _buildStatsSection()),

            // Description Section
            SliverToBoxAdapter(child: _buildDescriptionSection()),

            if (widget.course?.pdfUrls != null && widget.course!.pdfUrls!.isNotEmpty)
              SliverToBoxAdapter(child: _buildPdfMaterialsSection()),

            if (widget.course?.audioUrls != null && widget.course!.audioUrls!.isNotEmpty)
              SliverToBoxAdapter(child: _buildAudioMaterialsSection()),

            // Lessons Section
            SliverToBoxAdapter(child: _buildLessonsSection()),

            // Reviews Section
            SliverToBoxAdapter(child: _buildReviewsSection()),

            // Bottom spacing
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      bottomNavigationBar: _buildEnrollButton(),
    );
  }

  Widget _buildLessonsSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.play_circle_outline,
                  size: 20,
                  color: Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Course Lessons',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const Spacer(),
              if (_lessons.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_lessons.length} lessons',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF3B82F6),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          if (_isLoadingLessons)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_lessons.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.play_circle_outline,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No lessons available',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Lessons will appear here once added',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: List.generate(_lessons.length, (index) {
                final lesson = _lessons[index];
                final isCurrentLesson = _currentLesson?.id == lesson.id;
                
                return Container(
                  margin: EdgeInsets.only(bottom: index < _lessons.length - 1 ? 12 : 0),
                  decoration: BoxDecoration(
                    color: isCurrentLesson ? const Color(0xFF3B82F6).withValues(alpha: 0.05) : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCurrentLesson ? const Color(0xFF3B82F6).withValues(alpha: 0.2) : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _playLesson(lesson),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isCurrentLesson 
                                    ? const Color(0xFF3B82F6) 
                                    : const Color(0xFF3B82F6).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.play_arrow,
                                size: 20,
                                color: isCurrentLesson ? Colors.white : const Color(0xFF3B82F6),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lesson.title,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1F2937),
                                    ),
                                  ),
                                  if (lesson.description != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      lesson.description!,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: const Color(0xFF6B7280),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  lesson.formattedDuration,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Lesson ${index + 1}',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: const Color(0xFF9CA3AF),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }

  void _playLesson(Lesson lesson) {
    final lessonIndex = _lessons.indexWhere((l) => l.id == lesson.id);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonVideoScreen(
          lesson: lesson,
          allLessons: _lessons,
          currentIndex: lessonIndex,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          Text(
            'Course Details',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
              letterSpacing: -0.2,
            ),
          ),
          FutureBuilder<bool>(
            future: widget.course != null 
                ? SavedCoursesService.isCoursesSaved(widget.course!.id)
                : Future.value(false),
            builder: (context, snapshot) {
              final isSaved = snapshot.data ?? false;
              return GestureDetector(
                onTap: () async {
                  if (widget.course != null) {
                    if (isSaved) {
                      await SavedCoursesService.removeSavedCourse(widget.course!.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Course removed from saved courses',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                          ),
                          backgroundColor: Colors.orange,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    } else {
                      await SavedCoursesService.saveCourse(widget.course!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Course saved successfully!',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                          ),
                          backgroundColor: const Color(0xFF10B981),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    }
                    setState(() {}); // Refresh the UI
                  }
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                    size: 20,
                    color: isSaved ? const Color(0xFF5B6FEE) : const Color(0xFF1A1A1A),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCourseTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Text(
        widget.course?.title ?? widget.courseTitle,
        style: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1A1A1A),
          letterSpacing: -0.5,
          height: 1.2,
        ),
      ),
    );
  }

  Widget _buildVideoSection() {
    // Show video player if initialized (either from lessons or course video)
    if (_isVideoInitialized && _chewieController != null) {
      return Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5B6FEE).withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Chewie(controller: _chewieController!),
        ),
      );
    }

    // Show loading state or thumbnail with play button
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B6FEE).withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background - show thumbnail if available, otherwise gradient
            Positioned.fill(
              child: widget.course?.thumbnailUrl != null
                  ? Image.network(
                      widget.course!.thumbnailUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF4F63D2), Color(0xFF5B6FEE)],
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF4F63D2), Color(0xFF5B6FEE)],
                        ),
                      ),
                    ),
            ),

            // Dark overlay for better text visibility
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.6),
                    ],
                  ),
                ),
              ),
            ),

            // Instructor info card in top right
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.course?.instructorName ?? widget.instructor,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.course?.formattedDuration ?? 'Duration: N/A',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Play button in center
            Positioned.fill(
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    if (widget.course?.videoUrl != null && !_isVideoInitialized) {
                      _initializeVideo();
                    }
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Color(0xFF5B6FEE),
                      size: 36,
                    ),
                  ),
                ),
              ),
            ),

            // Bottom divider line
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.3),
                      Colors.white.withValues(alpha: 0.1),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructorSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3F4),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: const Color(0xFFE8EAED), width: 1),
            ),
            child: const Icon(Icons.person, color: Color(0xFF9AA0A6), size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.course?.instructorName ?? widget.instructor,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                    letterSpacing: -0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Course Instructor',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF5B6FEE).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.course?.formattedPrice ?? widget.price,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF5B6FEE),
                  letterSpacing: -0.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Row(
        children: [
          // Rating
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Color(0xFFFFC107), size: 18),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '${widget.course?.rating ?? widget.rating}(${widget.course?.rating != null ? '10+' : '50'} reviews)',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1A1A1A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Duration
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.access_time,
                  color: Color(0xFF6B7280),
                  size: 18,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    widget.course?.formattedDuration ?? '4h35p',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1A1A1A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Lessons
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.play_circle_outline,
                  color: Color(0xFF6B7280),
                  size: 18,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '12 Lessons',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1A1A1A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.course?.description ?? 'Prepare for a new career in the high-growth field of data analytics, no experience or degree required. Get professional-ready with Google Career Certificates.',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfMaterialsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PDF Materials',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 16),
          ...widget.course!.pdfUrls!.asMap().entries.map((entry) {
            final index = entry.key;
            final pdfUrl = entry.value;
            final fileName = pdfUrl.split('/').last.split('_').skip(2).join('_').replaceAll('.pdf', '');
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf,
                    color: Colors.red,
                    size: 24,
                  ),
                ),
                title: Text(
                  fileName.isNotEmpty ? fileName : 'PDF Document ${index + 1}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                subtitle: Text(
                  'Tap to review',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                trailing: const Icon(
                  Icons.visibility,
                  color: Color(0xFF5B6FEE),
                  size: 20,
                ),
                onTap: () => _downloadPdf(pdfUrl),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAudioMaterialsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Audio Materials',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 16),
          ...widget.course!.audioUrls!.asMap().entries.map((entry) {
            final index = entry.key;
            final audioUrl = entry.value;
            final fileName = audioUrl.split('/').last.split('_').skip(2).join('_').split('.').first;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B6FEE).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.audiotrack,
                    color: Color(0xFF5B6FEE),
                    size: 24,
                  ),
                ),
                title: Text(
                  fileName.isNotEmpty ? fileName : 'Audio Recording ${index + 1}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                subtitle: Text(
                  'Tap to play',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                trailing: const Icon(
                  Icons.play_arrow,
                  color: Color(0xFF5B6FEE),
                  size: 20,
                ),
                onTap: () => _playAudio(audioUrl),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Future<void> _downloadPdf(String pdfUrl) async {
    try {
      final fileName = pdfUrl.split('/').last.split('_').skip(2).join('_').replaceAll('.pdf', '');
      final displayName = fileName.isNotEmpty ? fileName : 'PDF Document';
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerScreen(
            pdfUrl: pdfUrl,
            fileName: displayName,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error opening PDF: $e',
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _playAudio(String audioUrl) async {
    try {
      final fileName = audioUrl.split('/').last.split('_').skip(2).join('_').split('.').first;
      final displayName = fileName.isNotEmpty ? fileName : 'Audio Recording';
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AudioPlayerScreen(
            audioUrl: audioUrl,
            fileName: displayName,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error playing audio: $e',
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Widget _buildReviewsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reviews',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),

          // Generate 4 review items
          ...List.generate(4, (index) => _buildReviewItem()),
        ],
      ),
    );
  }

  Widget _buildReviewItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.person, color: Color(0xFF9CA3AF), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ahmed Hassan',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    Row(
                      children: List.generate(
                        4,
                        (index) => const Icon(
                          Icons.star,
                          color: Color(0xFF5B6FEE),
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'UI/UX Course',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Prepare for a new career in the high-growth field of data.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnrollButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            if (widget.course != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EnrollmentFormScreen(course: widget.course!),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5B6FEE),
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: const Color(0xFF5B6FEE).withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            'Enroll Now',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }
}
