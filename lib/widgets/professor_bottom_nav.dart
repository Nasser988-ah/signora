import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/professor_home_screen.dart';
import '../screens/professor_chat_screen.dart';
import '../screens/professor_courses_screen.dart';
import '../screens/professor_schedule_screen.dart';

class ProfessorBottomNav extends StatefulWidget {
  final int currentIndex;

  const ProfessorBottomNav({
    Key? key,
    this.currentIndex = 0,
  }) : super(key: key);

  @override
  State<ProfessorBottomNav> createState() => _ProfessorBottomNavState();
}

class _ProfessorBottomNavState extends State<ProfessorBottomNav> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
  }

  void _onTap(int index) {
    if (_currentIndex == index) return; // Don't navigate to same screen
    
    setState(() {
      _currentIndex = index;
    });

    Widget destination;
    switch (index) {
      case 0:
        destination = const ProfessorHomeScreen(professorName: 'Professor');
        break;
      case 1:
        destination = const ProfessorChatScreen();
        break;
      case 2:
        destination = const ProfessorCoursesScreen();
        break;
      case 3:
        destination = const ProfessorScheduleScreen();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
  }

  @override
  Widget build(BuildContext context) {
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
        onTap: _onTap,
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
