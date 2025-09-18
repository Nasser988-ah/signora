import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/course.dart';
import '../services/supabase_service.dart';
import 'course_edit_screen.dart';
import '../models/lesson_upload.dart';
import 'course_upload_screen.dart';
import 'professor_course_details_screen.dart';
import '../widgets/professor_bottom_nav.dart';

class ProfessorCoursesScreen extends StatefulWidget {
  final bool showBottomNav;
  
  const ProfessorCoursesScreen({Key? key, this.showBottomNav = true}) : super(key: key);

  @override
  State<ProfessorCoursesScreen> createState() => _ProfessorCoursesScreenState();
}

class _ProfessorCoursesScreenState extends State<ProfessorCoursesScreen> {
  int _currentIndex = 2; // Courses tab is selected
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  final _categoryController = TextEditingController();
  final _difficultyController = TextEditingController();
  
  File? _thumbnailFile;
  List<LessonUpload> _lessons = [];
  bool _isUploading = false;
  
  List<Course> _professorCourses = [];
  bool _isLoading = true;
  
  final List<String> _categories = [
    'Programming',
    'Data Science',
    'Design',
    'Business',
    'Marketing',
    'Photography',
    'Music',
    'Language',
    'Other'
  ];
  
  final List<String> _difficulties = [
    'Beginner',
    'Intermediate',
    'Advanced'
  ];
  
  @override
  void initState() {
    super.initState();
    _loadProfessorCourses();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _categoryController.dispose();
    _difficultyController.dispose();
    super.dispose();
  }

  Future<void> _loadProfessorCourses() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final courses = await SupabaseService.getProfessorCourses();
      
      setState(() {
        _professorCourses = courses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading courses: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final safeAreaHeight = MediaQuery.of(context).size.height - 
        MediaQuery.of(context).padding.top - 
        MediaQuery.of(context).padding.bottom;
    final availableHeight = safeAreaHeight - kBottomNavigationBarHeight - 56; // FAB height

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: availableHeight,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(screenWidth),
                
                SizedBox(height: screenHeight * 0.02),
                
                // Search Bar
                _buildSearchBar(screenWidth),
                
                SizedBox(height: screenHeight * 0.02),
                
                // Stats Section
                _buildStatsSection(screenWidth),
                
                SizedBox(height: screenHeight * 0.02),
                
                // My Courses Grid
                _buildCoursesGrid(screenWidth),
                
                SizedBox(height: screenHeight * 0.02),
                
                // Manage Exam Section
                _buildManageExamSection(screenWidth),
                
                SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CourseUploadScreen(),
            ),
          );
          
          // Refresh the courses list if a course was uploaded successfully
          if (result == true) {
            _loadProfessorCourses();
          }
        },
        backgroundColor: const Color(0xFF3B82F6),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
      bottomNavigationBar: widget.showBottomNav ? const ProfessorBottomNav(currentIndex: 2) : null,
    );
  }

  Widget _buildHeader(double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'My Courses',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
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
              color: Color(0xFF6B7280),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
            hintText: 'Search here..',
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF9CA3AF),
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: Color(0xFF9CA3AF),
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard('${_professorCourses.length}', 'Courses'),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard('${_calculateTotalStudents()}', 'Students'),
          ),
        ],
      ),
    );
  }

  int _calculateTotalStudents() {
    // Calculate total enrolled students across all courses
    int totalStudents = 0;
    for (var course in _professorCourses) {
      totalStudents += course.enrolledStudents ?? 0;
    }
    return totalStudents;
  }

  Widget _buildStatCard(String number, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
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
      child: Column(
        children: [
          Text(
            number,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesGrid(double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: _isLoading
          ? _buildLoadingGrid()
          : _professorCourses.isEmpty
              ? _buildEmptyCoursesState()
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.9,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _professorCourses.length,
                  itemBuilder: (context, index) {
                    final course = _professorCourses[index];
                    return GestureDetector(
                      onTap: () async {
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => CourseEditScreen(
                              course: course,
                            ),
                          ),
                        );
                        
                        // Refresh the courses list if course was updated
                        if (result == true) {
                          _loadProfessorCourses();
                        }
                      },
                      child: _buildCourseCard(
                        course.title,
                        '${course.enrolledStudents ?? 0} Students',
                        '${(course.duration ?? (course.durationMinutes / 60).round())}h',
                        '${course.lessons?.length ?? 0} lessons',
                        course.category,
                        course.description,
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.9,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
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
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF3B82F6),
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 10,
                        width: double.infinity * 0.7,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyCoursesState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF3B82F6).withOpacity(0.1),
                  const Color(0xFF1E40AF).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Center(
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF3B82F6),
                      Color(0xFF1E40AF),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  Icons.school_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Courses Yet',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start creating your first course\nto share knowledge with students',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B7280),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(String title, String students, String duration, String lessons, String category, String description) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Blue header section
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Stack(
                children: [
                  // Category label
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        category,
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
                      size: 40,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Course details section
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
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
                  const SizedBox(height: 3),
                  Flexible(
                    child: Text(
                      description.isNotEmpty ? description : 'No description available',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6B7280),
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Stats row
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(Icons.people_outline, students),
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: _buildStatItem(Icons.access_time_outlined, duration),
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: _buildStatItem(Icons.play_circle_outline, lessons),
                      ),
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
          size: 8,
          color: const Color(0xFF6B7280),
        ),
        const SizedBox(width: 1),
        Flexible(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 7,
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

  Widget _buildManageExamSection(double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Manage Exam',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'Add New Exam',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF3B82F6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildExamItem(
            'Statistics Math Exam',
            'Math • 8 Question',
            Icons.bar_chart_outlined,
            const Color(0xFF3B82F6),
          ),
          const SizedBox(height: 12),
          _buildExamItem(
            'AI Exam',
            'AI • 8 Question',
            Icons.psychology_outlined,
            const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }

  Widget _buildExamItem(String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
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
                    color: const Color(0xFF1F2937),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
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
          const Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: Color(0xFF9CA3AF),
          ),
        ],
      ),
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
          setState(() {
            _currentIndex = index;
          });
          
          // Handle navigation based on selected tab
          if (index == 0) { // Home tab
            Navigator.of(context).pop(); // Go back to home
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
              child: Icon(Icons.calendar_today_outlined, size: 22),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.calendar_today, size: 22),
            ),
            label: 'Schedule',
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
              child: Icon(Icons.person_outline, size: 22),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.person, size: 22),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
