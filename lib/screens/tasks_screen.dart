import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_bottom_nav.dart';
import 'home_screen.dart';
import 'schedule_screen.dart';
import 'profile_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  int _selectedIndex = 2; // Tasks tab is selected

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(screenWidth),

            // Coming Soon Content
            Expanded(child: _buildComingSoonContent()),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          // Navigate based on selected index
          if (index == 0) {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const HomeScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position: animation.drive(
                          Tween(
                            begin: const Offset(-1.0, 0.0),
                            end: Offset.zero,
                          ),
                        ),
                        child: child,
                      );
                    },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );
          } else if (index == 1) {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const ScheduleScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position: animation.drive(
                          Tween(
                            begin: const Offset(-1.0, 0.0),
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
      ),
    );
  }

  Widget _buildHeader(double screenWidth) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: 20,
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
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Tasks',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1F2937),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoonContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF3A4FDE).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.assignment_outlined,
              size: 60,
              color: Color(0xFF3A4FDE),
            ),
          ),

          const SizedBox(height: 32),

          // Coming Soon Text
          Text(
            'Coming Soon',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),

          const SizedBox(height: 16),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'We\'re working hard to bring you an amazing task management experience. Stay tuned!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
