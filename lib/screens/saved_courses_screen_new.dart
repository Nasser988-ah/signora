import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/course.dart';
import '../services/saved_courses_service.dart';
import 'course_details_screen.dart';

class SavedCoursesScreen extends StatefulWidget {
  const SavedCoursesScreen({super.key});

  @override
  State<SavedCoursesScreen> createState() => _SavedCoursesScreenState();
}

class _SavedCoursesScreenState extends State<SavedCoursesScreen> {
  List<Course> _savedCourses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedCourses();
  }

  Future<void> _loadSavedCourses() async {
    try {
      final savedCourses = await SavedCoursesService.getSavedCourses();
      setState(() {
        _savedCourses = savedCourses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeCourse(Course course) async {
    try {
      await SavedCoursesService.removeSavedCourse(course.id);
      setState(() {
        _savedCourses.removeWhere((c) => c.id == course.id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Course removed from saved courses',
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to remove course',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Color(0xFF1F2937),
                        size: 18,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Saved Courses',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.bookmark,
                      color: _savedCourses.isNotEmpty ? const Color(0xFF5B6FEE) : const Color(0xFF1F2937),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // Course Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    '${_savedCourses.length} Saved Course${_savedCourses.length != 1 ? 's' : ''}',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Main Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF5B6FEE),
                      ),
                    )
                  : _savedCourses.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: _savedCourses.length,
                          itemBuilder: (context, index) {
                            final course = _savedCourses[index];
                            return _buildCourseCard(course);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF5B6FEE).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bookmark_outline,
                size: 48,
                color: Color(0xFF5B6FEE),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Saved Courses Yet',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start exploring courses and save your favorites to see them here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B6FEE),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Explore Courses',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(Course course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CourseDetailsScreen(
                  courseTitle: course.title,
                  instructor: course.instructor,
                  price: course.formattedPrice,
                  rating: course.rating,
                  course: course,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Course thumbnail/icon
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF5B6FEE), Color(0xFF4F63D2)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.play_circle_outline,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Course info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.title,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1F2937),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            course.instructor,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Remove button
                    IconButton(
                      onPressed: () => _removeCourse(course),
                      icon: const Icon(
                        Icons.bookmark,
                        color: Color(0xFF5B6FEE),
                        size: 24,
                      ),
                      tooltip: 'Remove from saved',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Course stats
                Row(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xFFFBBF24),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          course.formattedRating,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          color: Color(0xFF6B7280),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          course.formattedDuration,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      course.formattedPrice,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF5B6FEE),
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
  }
}
