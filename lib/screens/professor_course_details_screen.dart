import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/course.dart';

class ProfessorCourseDetailsScreen extends StatefulWidget {
  final Course course;

  const ProfessorCourseDetailsScreen({
    super.key,
    required this.course,
  });

  @override
  State<ProfessorCourseDetailsScreen> createState() => _ProfessorCourseDetailsScreenState();
}

class _ProfessorCourseDetailsScreenState extends State<ProfessorCourseDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SizedBox(
        width: screenWidth,
        child: Column(
          children: [
            // Header
            SizedBox(
              width: screenWidth,
              child: _buildHeader(),
            ),
            
            // Scrollable Content
            Expanded(
              child: SizedBox(
                width: screenWidth,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Course Title
                      SizedBox(
                        width: screenWidth,
                        child: _buildCourseTitle(),
                      ),

                      // Video Section
                      SizedBox(
                        width: screenWidth,
                        child: _buildVideoSection(),
                      ),

                      // Instructor Section
                      SizedBox(
                        width: screenWidth,
                        child: _buildInstructorSection(),
                      ),

                      // Stats Section
                      SizedBox(
                        width: screenWidth,
                        child: _buildStatsSection(),
                      ),

                      // Description Section
                      SizedBox(
                        width: screenWidth,
                        child: _buildDescriptionSection(),
                      ),

                      // Lessons Section
                      SizedBox(
                        width: screenWidth,
                        child: _buildLessonsSection(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildManageButton(),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
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
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Color(0xFF1A1A1A),
                  size: 16,
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
              child: const Icon(
                Icons.more_horiz,
                color: Color(0xFF1A1A1A),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseTitle() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Text(
        widget.course.title,
        style: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1A1A1A),
          letterSpacing: -0.5,
          height: 1.2,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildVideoSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
        ),
      ),
      child: Stack(
        children: [
          // Background decorative elements
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
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
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
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
                        widget.course.instructorName,
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
                        '09:00 AM - 08:30 PM',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.9),
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
                  // Handle play video
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Color(0xFF3B82F6),
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
                    Colors.white.withOpacity(0.3),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructorSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F4),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFE8EAED), width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.asset(
                    'assets/images/professor_avatar.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.person, color: Color(0xFF9AA0A6), size: 22);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.course.instructorName,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                        letterSpacing: -0.1,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Mentor UI/UX Course',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6B7280),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 80),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.course.formattedPrice,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF3B82F6),
                      letterSpacing: -0.1,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildStatItem(Icons.star, '${widget.course.formattedRating}(50 reviews)', const Color(0xFFFFA726)),
              _buildStatItem(Icons.access_time, widget.course.formattedDuration, const Color(0xFF3B82F6)),
              _buildStatItem(Icons.play_lesson, '${widget.course.lessons?.length ?? 0} Lessons', const Color(0xFF10B981)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text, Color color) {
    return IntrinsicWidth(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 150),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B7280),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
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
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Prepare for a new career in the high-growth field of data analytics, no experience or degree required.',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  'Lessons',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                    letterSpacing: -0.1,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Expanded(
                flex: 3,
                child: GestureDetector(
                  onTap: () {
                    // Handle add new lesson
                  },
                  child: Text(
                    'Add New Lessons',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF3B82F6),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.end,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildLessonItem('Introduction', '3:23 mins', true),
          const SizedBox(height: 8),
          _buildLessonItem('Optimize design with Auto Layout...', '18:23 mins', false),
        ],
      ),
    );
  }

  Widget _buildLessonItem(String title, String duration, bool isCompleted) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.check : Icons.play_arrow,
              color: const Color(0xFF3B82F6),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  duration,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              // Handle edit lesson
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.edit,
                color: Color(0xFF3B82F6),
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reviews',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 16),
          _buildReviewItem('Ahmed Hassan', 'UI/UX Course'),
          const SizedBox(height: 12),
          _buildReviewItem('Ahmed Hassan', 'UI/UX Course'),
          const SizedBox(height: 12),
          _buildReviewItem('Ahmed Hassan', 'UI/UX Course'),
          const SizedBox(height: 12),
          _buildReviewItem('Ahmed Hassan', 'UI/UX Course'),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String name, String course) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3F4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.person, color: Color(0xFF9AA0A6), size: 20),
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
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    Row(
                      children: List.generate(4, (index) => const Icon(
                        Icons.star,
                        color: Color(0xFFFFA726),
                        size: 16,
                      )),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  course,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Prepare for a new career in the high-growth field of data',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManageButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () {
            // Handle manage course
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Text(
            'Manage Course',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }
}
