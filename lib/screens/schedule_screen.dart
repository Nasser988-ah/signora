import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/lecture.dart';
import '../widgets/lecture_item.dart';
import '../widgets/calendar_widget.dart';
import 'tasks_screen.dart';
import 'profile_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _selectedIndex = 1; // Schedule tab is selected
  DateTime selectedDate = DateTime(
    2025,
    5,
    20,
  ); // May 20, 2025 as shown in design

  // Empty list to show "No Live Courses Available" state
  final List<Lecture> lectures = [];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(screenWidth),

            // Calendar Section
            _buildCalendarSection(screenWidth),

            // Upcoming Lectures Section
            Expanded(child: _buildUpcomingLecturesSection(screenWidth)),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader(double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
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
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
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
          const Spacer(),
          Text(
            'Schedule',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          const Spacer(),
          const SizedBox(width: 40), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildCalendarSection(double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: CalendarWidget(
        selectedDate: selectedDate,
        onDateSelected: (date) {
          setState(() {
            selectedDate = date;
          });
        },
      ),
    );
  }

  Widget _buildUpcomingLecturesSection(double screenWidth) {
    // Check if there are any live courses available
    final hasLiveCourses = lectures.isNotEmpty;
    
    return Container(
      margin: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Text(
              'Live Courses',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: hasLiveCourses 
                ? ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                    itemCount: lectures.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: LectureItem(
                          lecture: lectures[index],
                          onTap: () => _showLectureDetails(lectures[index]),
                        ),
                      );
                    },
                  )
                : _buildNoLiveCoursesState(screenWidth),
          ),
        ],
      ),
    );
  }

  Widget _buildNoLiveCoursesState(double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Live course icon with gradient background
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF3B82F6).withOpacity(0.1),
                    const Color(0xFF1E40AF).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF3B82F6),
                        Color(0xFF1E40AF),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.video_call_outlined,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Main message
            Text(
              'No Live Courses Available',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1F2937),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Subtitle message
            Text(
              'Live courses will appear here when\nthey become available',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF6B7280),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Professional action button
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 280),
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to courses or home
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: const Color(0xFF3B82F6).withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.explore_outlined,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Explore Courses',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Secondary action
            TextButton(
              onPressed: () {
                setState(() {
                  // Refresh or check for updates
                });
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF6B7280),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.refresh,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Check for Updates',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLectureDetails(Lecture lecture) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildLectureDetailsModal(lecture),
    );
  }

  Widget _buildLectureDetailsModal(Lecture lecture) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lecture.title,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),
            if (lecture.subtitle.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                lecture.subtitle,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  color: Color(0xFF6B7280),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  lecture.instructor,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.access_time,
                  color: Color(0xFF6B7280),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '${lecture.duration} minutes',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
            if (lecture.description.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Description',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                lecture.description,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Close',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Add reminder logic here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: Text(
                      'Set Reminder',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          // Navigate based on selected index
          if (index == 0) {
            Navigator.of(context).pop(); // Go back to Home
          } else if (index == 2) {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const TasksScreen(),
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
          } else if (index == 3) {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const ProfileScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                transitionDuration: const Duration(milliseconds: 500),
              ),
            );
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: const Color(0xFF3B82F6),
        unselectedItemColor: const Color(0xFF9CA3AF),
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/home.png',
              width: 22,
              height: 22,
              color: const Color(0xFF9CA3AF),
            ),
            activeIcon: Image.asset(
              'assets/images/home.png',
              width: 22,
              height: 22,
              color: const Color(0xFF3B82F6),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/Schedule.png',
              width: 22,
              height: 22,
              color: const Color(0xFF9CA3AF),
            ),
            activeIcon: Image.asset(
              'assets/images/Schedule.png',
              width: 22,
              height: 22,
              color: const Color(0xFF3B82F6),
            ),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/Tasks.png',
              width: 22,
              height: 22,
              color: const Color(0xFF9CA3AF),
            ),
            activeIcon: Image.asset(
              'assets/images/Tasks.png',
              width: 22,
              height: 22,
              color: const Color(0xFF3B82F6),
            ),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/Profile.png',
              width: 22,
              height: 22,
              color: const Color(0xFF9CA3AF),
            ),
            activeIcon: Image.asset(
              'assets/images/Profile.png',
              width: 22,
              height: 22,
              color: const Color(0xFF3B82F6),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
