import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../widgets/course_card.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';
import '../models/course.dart';
import 'course_upload_screen.dart';
import 'course_upload_enhanced_screen.dart';
import 'professor_courses_screen.dart';
import 'professor_schedule_screen.dart';
import 'professor_profile_screen.dart';
import 'professor_course_details_screen.dart';
import 'professor_manage_courses_screen.dart';
import 'user_type_selection_screen.dart';
import 'notifications_screen.dart';
import 'professor_chat_screen.dart';
import '../widgets/professor_bottom_nav.dart';

class ProfessorHomeScreen extends StatefulWidget {
  final String professorName;
  final bool showBottomNav;

  const ProfessorHomeScreen({
    Key? key,
    required this.professorName,
    this.showBottomNav = true,
  }) : super(key: key);

  @override
  State<ProfessorHomeScreen> createState() => _ProfessorHomeScreenState();
}

class _ProfessorHomeScreenState extends State<ProfessorHomeScreen> {
  int _currentIndex = 0;
  final AuthService _authService = AuthService();
  List<Course> _professorCourses = [];
  bool _isLoadingCourses = true;

  @override
  void initState() {
    super.initState();
    _loadProfessorCourses();
  }

  Future<void> _loadProfessorCourses() async {
    try {
      final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        final courses = await SupabaseService.getProfessorCourses();
        setState(() {
          _professorCourses = courses.take(3).toList(); // Show first 3 courses
          _isLoadingCourses = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingCourses = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with search and greeting
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    // Search bar
                    _buildSearchBar(),
                    SizedBox(height: screenHeight * 0.025),
                    
                    // Greeting section
                    _buildHeader(),
                  ],
                ),
              ),
              
              // Upcoming Lectures Card
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: _buildUpcomingLecturesCard(),
              ),
              
              SizedBox(height: screenHeight * 0.03),

              // Active Courses Section
              _buildActiveCoursesSection(),
              
              SizedBox(height: screenHeight * 0.03),

              // Manage Courses Section
              _buildManageCoursesSection(),
              
              SizedBox(height: screenHeight * 0.03),

              // Manage Lectures Section
              _buildManageLecturesSection(),
              
              SizedBox(height: screenHeight * 0.12), // Extra space for bottom nav
            ],
          ),
        ),
      ),
      bottomNavigationBar: widget.showBottomNav ? const ProfessorBottomNav(currentIndex: 0) : null,
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome Back!',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _authService.getCurrentUserName(),
                style: GoogleFonts.inter(
                  fontSize: 20,
                  color: const Color(0xFF1F2937),
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfessorChatScreen(),
                  ),
                );
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    const Center(
                      child: Icon(
                        Icons.chat_bubble_outline,
                        color: Color(0xFF6B7280),
                        size: 16,
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF3B82F6),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(isProfessor: true),
                  ),
                );
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Color(0xFF6B7280),
                  size: 16,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfessorProfileScreen(),
                  ),
                );
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF10B981),
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/professor_avatar.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFE5E7EB),
                        child: const Icon(
                          Icons.person,
                          color: Color(0xFF6B7280),
                          size: 16,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search here...',
          hintStyle: GoogleFonts.inter(
            color: const Color(0xFF9CA3AF),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF9CA3AF),
            size: 18,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingLecturesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A5CFF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your upcoming\nLectures',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '3 Lectures Today',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '8:00 am - 9:00 am',
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(
                Icons.calendar_month_outlined,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveCoursesSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Courses',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'View All',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF3B82F6),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: index < 2 ? 16 : 0),
                child: CourseCard(
                  title: 'Basics of UI/UX Design',
                  subtitle: 'by Ahmed Hassan',
                  progress: 0.6,
                  isOngoing: true,
                  onTap: () {},
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCourseCard(String title, String instructor, String students,
      String duration, String lessons) {
    return Container(
      width: 280,
      height: 130,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and title
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.design_services_outlined,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F2937),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        instructor,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF6B7280),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Progress section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                Text(
                  '60%',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF3B82F6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: 0.6,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
              borderRadius: BorderRadius.circular(2),
              minHeight: 3,
            ),
            const SizedBox(height: 12),
            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(Icons.people_outline, students),
                _buildStatItem(Icons.access_time_outlined, duration),
                _buildStatItem(Icons.play_circle_outline, lessons),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManageCoursesSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Manage Courses',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfessorManageCoursesScreen(),
                    ),
                  );
                },
                child: Text(
                  'View All',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF3B82F6),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: _isLoadingCourses
              ? const Center(child: CircularProgressIndicator())
              : _professorCourses.isEmpty
                  ? _buildEmptyCoursesState(screenWidth)
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                      itemCount: _professorCourses.length,
                      itemBuilder: (context, index) {
                        final course = _professorCourses[index];
                        return Padding(
                          padding: EdgeInsets.only(right: index < _professorCourses.length - 1 ? 16 : 0),
                          child: _buildRealCourseCard(course),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildEmptyCoursesState(double screenWidth) {
    return Container(
      width: screenWidth * 0.8,
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'No Courses Yet',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Upload your first course to get started',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRealCourseCard(Course course) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course thumbnail
          Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              color: Colors.grey.shade100,
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: course.thumbnailUrl != null
                  ? Image.network(
                      course.thumbnailUrl!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF4F63D2), Color(0xFF5B6FEE)],
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.school_outlined,
                              size: 32,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF4F63D2), Color(0xFF5B6FEE)],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.school_outlined,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
          ),

          // Course details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    course.category,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      _buildStatItem(Icons.access_time, course.formattedDuration),
                      const SizedBox(width: 12),
                      _buildStatItem(Icons.star, '${course.rating}'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 10,
          color: const Color(0xFF6B7280),
        ),
        const SizedBox(width: 2),
        Flexible(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 8,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildManageCourseCard(Course course) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ProfessorCourseDetailsScreen(
                  course: course,
                ),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return SlideTransition(
                position: animation.drive(
                  Tween(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ),
                ),
                child: child,
              );
            },
            transitionDuration: const Duration(
              milliseconds: 300,
            ),
          ),
        );
      },
      child: Container(
        width: 160,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image container with gradient background
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      // Category label
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            course.category,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      // Course icon
                      const Center(
                        child: Icon(
                          Icons.school_outlined,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Course details
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'by ${course.instructorName}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6B7280),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  // Stats row
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(Icons.people_outline, '${course.enrolledStudents ?? 0}'),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: _buildStatItem(Icons.access_time_outlined, course.formattedDuration),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: _buildStatItem(Icons.play_circle_outline, '${course.lessons?.length ?? 0}'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildManageLecturesSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Manage Lectures',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'View All',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF3B82F6),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.video_call_outlined,
                      color: Color(0xFF3B82F6),
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Schedule New Lecture',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F2937),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Create and schedule your next lecture',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF6B7280),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Arrow icon
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Color(0xFF9CA3AF),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          // Don't update state for home tab to stay on home screen
          if (index == 0) return;
          
          // Handle navigation based on selected tab
          if (index == 1) { // Messages tab
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const ProfessorChatScreen(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return SlideTransition(
                    position: animation.drive(
                      Tween(
                        begin: const Offset(1.0, 0.0),
                        end: Offset.zero,
                      ),
                    ),
                    child: child,
                  );
                },
                transitionDuration: const Duration(
                  milliseconds: 300,
                ),
              ),
            );
          } else if (index == 2) { // Courses tab
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const ProfessorCoursesScreen(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return SlideTransition(
                    position: animation.drive(
                      Tween(
                        begin: const Offset(1.0, 0.0),
                        end: Offset.zero,
                      ),
                    ),
                    child: child,
                  );
                },
                transitionDuration: const Duration(
                  milliseconds: 300,
                ),
              ),
            );
          } else if (index == 3) { // Schedule tab
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const ProfessorScheduleScreen(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return SlideTransition(
                    position: animation.drive(
                      Tween(
                        begin: const Offset(1.0, 0.0),
                        end: Offset.zero,
                      ),
                    ),
                    child: child,
                  );
                },
                transitionDuration: const Duration(
                  milliseconds: 300,
                ),
              ),
            );
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF3B82F6),
        unselectedItemColor: const Color(0xFF9CA3AF),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        selectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500),
        unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w400),
        backgroundColor: Colors.white,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.home_outlined, size: 22),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.home, size: 22),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.chat_bubble_outline, size: 22),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.chat_bubble, size: 22),
            ),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.book_outlined, size: 22),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.book, size: 22),
            ),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.calendar_today_outlined, size: 22),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.calendar_today, size: 22),
            ),
            label: 'Schedule',
          ),
        ],
      ),
    );
  }
}