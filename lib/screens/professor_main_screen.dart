import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'professor_home_screen.dart';
import 'professor_schedule_screen.dart';
import 'professor_courses_screen.dart';
import 'professor_profile_screen.dart';

class ProfessorMainScreen extends StatefulWidget {
  final String professorName;
  
  const ProfessorMainScreen({
    Key? key,
    required this.professorName,
  }) : super(key: key);

  @override
  State<ProfessorMainScreen> createState() => _ProfessorMainScreenState();
}

class _ProfessorMainScreenState extends State<ProfessorMainScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    
    // Initialize animation controllers for smooth transitions
    _animationControllers = List.generate(
      4,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );
    
    _fadeAnimations = _animationControllers
        .map((controller) => Tween<double>(begin: 0.0, end: 1.0)
            .animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut)))
        .toList();
    
    // Start with home screen animation
    _animationControllers[0].forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    
    setState(() {
      _currentIndex = index;
    });
    
    // Animate to the selected page
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    
    // Animate the selected screen
    _animationControllers[index].forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          // Home Screen
          FadeTransition(
            opacity: _fadeAnimations[0],
            child: ProfessorHomeContent(professorName: widget.professorName),
          ),
          
          // Schedule Screen
          FadeTransition(
            opacity: _fadeAnimations[1],
            child: const ProfessorScheduleContent(),
          ),
          
          // Courses Screen
          FadeTransition(
            opacity: _fadeAnimations[2],
            child: const ProfessorCoursesContent(),
          ),
          
          // Profile Screen
          FadeTransition(
            opacity: _fadeAnimations[3],
            child: const ProfessorProfileContent(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
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
        onTap: _onTabTapped,
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

// Content widgets for each screen (without navigation bars)
class ProfessorHomeContent extends StatelessWidget {
  final String professorName;
  
  const ProfessorHomeContent({Key? key, required this.professorName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Return the home screen content without bottom navigation
    return ProfessorHomeScreen(professorName: professorName, showBottomNav: false);
  }
}

class ProfessorScheduleContent extends StatelessWidget {
  const ProfessorScheduleContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Return the schedule screen content without bottom navigation
    return const ProfessorScheduleScreen(showBottomNav: false);
  }
}

class ProfessorCoursesContent extends StatelessWidget {
  const ProfessorCoursesContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Return the courses screen content without bottom navigation
    return const ProfessorCoursesScreen(showBottomNav: false);
  }
}

class ProfessorProfileContent extends StatelessWidget {
  const ProfessorProfileContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Return the profile screen content without bottom navigation
    return const ProfessorProfileScreen(showBottomNav: false);
  }
}
