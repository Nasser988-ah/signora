import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/hero_card.dart';
import '../widgets/course_card.dart';
import '../widgets/saved_course_item.dart';
import '../widgets/category_tabs.dart';
import '../widgets/custom_bottom_nav.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';
import '../models/course.dart';
import 'profile_screen.dart';
import 'messages_screen.dart';
import 'schedule_screen.dart';
import 'tasks_screen.dart';
import 'live_lectures_screen.dart';
import 'course_details_screen.dart';
import 'saved_courses_screen.dart';
import 'user_type_selection_screen.dart';
import 'notifications_screen.dart';
import 'empty_chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();
  List<Course> _suggestedCourses = [];
  bool _isLoadingCourses = true;

  @override
  void initState() {
    super.initState();
    _loadSuggestedCourses();
  }

  Future<void> _loadSuggestedCourses() async {
    try {
      final courses = await SupabaseService.getAllCourses();
      setState(() {
        _suggestedCourses = courses.take(6).toList(); // Show first 6 courses
        _isLoadingCourses = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCourses = false;
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
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
                    Container(
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
                    ),
                    SizedBox(height: screenHeight * 0.025),

                    // Greeting section with profile
                    Row(
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
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                        ) => const EmptyChatScreen(isProfessor: false),
                                    transitionsBuilder:
                                        (
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
                                    builder: (context) => const NotificationsScreen(isProfessor: false),
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
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                        ) => const ProfileScreen(),
                                    transitionsBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                          child,
                                        ) {
                                          return FadeTransition(
                                            opacity: animation,
                                            child: child,
                                          );
                                        },
                                    transitionDuration: const Duration(
                                      milliseconds: 500,
                                    ),
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
                                  child: Container(
                                    color: const Color(0xFFE5E7EB),
                                    child: const Icon(
                                      Icons.person,
                                      color: Color(0xFF6B7280),
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Hero Card
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: const HeroCard(),
              ),

              SizedBox(height: screenHeight * 0.03),

              // Category Tabs
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: const CategoryTabs(),
              ),

              SizedBox(height: screenHeight * 0.03),

              // Ongoing Courses Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ongoing Courses',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const LiveLecturesScreen(),
                            transitionsBuilder:
                                (
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

              // Ongoing Courses List
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(right: index < 3 ? 16 : 0),
                      child: CourseCard(
                        title: 'Basics of UI/UX Design',
                        subtitle: 'by Ahmed hassan',
                        progress: 0.6,
                        isOngoing: true,
                        onTap: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const LiveLecturesScreen(),
                              transitionsBuilder:
                                  (
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
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: screenHeight * 0.03),

              // Suggested Courses Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Suggested Courses',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      'View All',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF3B82F6),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Suggested Courses Grid
              SizedBox(
                height: 240,
                child: _isLoadingCourses
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF3B82F6),
                        ),
                      )
                    : _suggestedCourses.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.school_outlined,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No courses available yet',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Check back later for new courses!',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                            itemCount: _suggestedCourses.length,
                            itemBuilder: (context, index) {
                              final course = _suggestedCourses[index];
                              return Padding(
                                padding: EdgeInsets.only(right: index < _suggestedCourses.length - 1 ? 16 : 0),
                                child: CourseCard(
                                  title: course.title,
                                  subtitle: course.instructorName,
                                  price: course.formattedPrice,
                                  rating: course.rating,
                                  isOngoing: false,
                                  thumbnailUrl: course.thumbnailUrl,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CourseDetailsScreen(
                                          courseTitle: course.title,
                                          instructor: course.instructorName,
                                          price: course.formattedPrice,
                                          rating: course.rating,
                                          course: course, // Pass the full course object
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
              ),

              SizedBox(height: screenHeight * 0.03),

              // Saved Courses Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                const SavedCoursesScreen(),
                            transitionsBuilder:
                                (context, animation, secondaryAnimation, child) {
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
                            transitionDuration: const Duration(milliseconds: 300),
                          ),
                        );
                      },
                      child: Text(
                        'Saved Courses',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                const SavedCoursesScreen(),
                            transitionsBuilder:
                                (context, animation, secondaryAnimation, child) {
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
                            transitionDuration: const Duration(milliseconds: 300),
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

              // Saved Courses List
              ...List.generate(4, (index) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: 6,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              const SavedCoursesScreen(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
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
                          transitionDuration: const Duration(milliseconds: 300),
                        ),
                      );
                    },
                    child: const SavedCourseItem(
                      title: 'Introduction UI/UX Design',
                      instructor: 'by Ahmed hassan',
                      date: 'last Friday, 9:00 PM',
                    ),
                  ),
                );
              }),

              SizedBox(height: screenHeight * 0.12),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == _selectedIndex) return; // Prevent unnecessary navigation
          
          setState(() {
            _selectedIndex = index;
          });

          // Navigate to Schedule screen when schedule tab is tapped
          if (index == 1) {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const ScheduleScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position: animation.drive(
                          Tween(
                            begin: const Offset(0.3, 0.0),
                            end: Offset.zero,
                          ).chain(CurveTween(curve: Curves.easeOutCubic)),
                        ),
                        child: FadeTransition(
                          opacity: animation.drive(
                            Tween(begin: 0.0, end: 1.0)
                                .chain(CurveTween(curve: Curves.easeOut)),
                          ),
                          child: child,
                        ),
                      );
                    },
                transitionDuration: const Duration(milliseconds: 200),
                reverseTransitionDuration: const Duration(milliseconds: 150),
              ),
            );
          }
          // Navigate to Tasks screen when tasks tab is tapped
          else if (index == 2) {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const TasksScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position: animation.drive(
                          Tween(
                            begin: const Offset(0.3, 0.0),
                            end: Offset.zero,
                          ).chain(CurveTween(curve: Curves.easeOutCubic)),
                        ),
                        child: FadeTransition(
                          opacity: animation.drive(
                            Tween(begin: 0.0, end: 1.0)
                                .chain(CurveTween(curve: Curves.easeOut)),
                          ),
                          child: child,
                        ),
                      );
                    },
                transitionDuration: const Duration(milliseconds: 200),
                reverseTransitionDuration: const Duration(milliseconds: 150),
              ),
            );
          }
          // Navigate to Profile screen when profile tab is tapped
          else if (index == 3) {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const ProfileScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation.drive(
                          Tween(begin: 0.0, end: 1.0)
                              .chain(CurveTween(curve: Curves.easeOut)),
                        ),
                        child: ScaleTransition(
                          scale: animation.drive(
                            Tween(begin: 0.95, end: 1.0)
                                .chain(CurveTween(curve: Curves.easeOutCubic)),
                          ),
                          child: child,
                        ),
                      );
                    },
                transitionDuration: const Duration(milliseconds: 200),
                reverseTransitionDuration: const Duration(milliseconds: 150),
              ),
            );
          }
        },
      ),
    );
  }
}
