import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'messages_screen.dart';
import 'home_screen.dart';
import 'schedule_screen.dart';
import 'tasks_screen.dart';
import 'user_type_selection_screen.dart';
import 'empty_chat_screen.dart';
import 'notifications_screen.dart';
import 'saved_courses_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 3;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          // Enhanced Header Section
          _buildHeaderSection(screenHeight, screenWidth),

          // Content Section with Animation
          Expanded(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: _buildContentSection(screenWidth),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeaderSection(double screenHeight, double screenWidth) {
    return SizedBox(
      height: screenHeight * 0.45,
      width: double.infinity,
      child: Stack(
        children: [
          // Main blue background with curved bottom and background image
          Container(
            height: screenHeight * 0.35,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/profile_background.png'),
                fit: BoxFit.cover,
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1B52E8), Color(0xFF1B52E8)],
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF1B52E8).withOpacity(0.3),
                    const Color(0xFF1B52E8).withOpacity(0.4),
                  ],
                ),
              ),
              child: CustomPaint(
                painter: ModernWavePatternPainter(),
                size: Size.infinite,
              ),
            ),
          ),

          // White curved section at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.15,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
            ),
          ),

          // App Bar
          _buildAppBar(),

          // Profile Avatar - positioned to overlap both sections
          Positioned(
            bottom: screenHeight * 0.08,
            left: screenWidth / 2 - 50,
            child: _buildProfileAvatar(),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildIconButton(
              icon: Icons.arrow_back_ios_new,
              onPressed: () => Navigator.of(context).pop(),
            ),
            Text(
              'Profile',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
            _buildIconButton(
              icon: Icons.chat_bubble_outline,
              onPressed: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const EmptyChatScreen(isProfessor: false),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onPressed,
          child: Icon(icon, color: const Color(0xFF1B52E8), size: 18),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Hero(
      tag: 'profile_avatar',
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipOval(
          child: _authService.getCurrentUserPhotoUrl() != null
              ? Image.network(
                  _authService.getCurrentUserPhotoUrl()!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFF3F4F6),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF1B52E8),
                          ),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFF3F4F6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 48,
                        color: Color(0xFF9CA3AF),
                      ),
                    );
                  },
                )
              : Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 48,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildContentSection(double screenWidth) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 60), // Space for overlapping avatar
            // User Info Section
            _buildUserInfoSection(),

            const SizedBox(height: 32),

            // Statistics Card
            _buildStatisticsCard(),

            const SizedBox(height: 40),

            // Menu Options
            _buildMenuSection(),

            const SizedBox(height: 100), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Text(
            _authService.getCurrentUserName(),
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _authService.getCurrentUserEmail(),
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B52E8), Color(0xFF1B52E8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B52E8).withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
            spreadRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('0', 'Courses'),
          Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
          _buildStatItem('0', 'Credits'),
          Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
          _buildStatItem('0', 'Achievement'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String number, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            number,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    final menuItems = [
      {'icon': Icons.bookmark_border, 'title': 'Saved Courses'},
      {'icon': Icons.notifications_none, 'title': 'Notification'},
      {'icon': Icons.credit_card_outlined, 'title': 'Payment Method'},
      {'icon': Icons.logout_outlined, 'title': 'Log Out'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: menuItems.asMap().entries.map((entry) {
          return _buildProfileMenuItem(
            icon: entry.value['icon'] as IconData,
            title: entry.value['title'] as String,
            isLast: entry.key == menuItems.length - 1,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    bool isLast = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _handleMenuItemTap(title),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B52E8).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: const Color(0xFF1B52E8), size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: const Color(0xFF111827),
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Color(0xFF9CA3AF),
                ),
              ],
            ),
          ),
        ),
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
            blurRadius: 20,
            offset: const Offset(0, -8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 75,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, 'assets/images/home.png', 'Home'),
              _buildNavItem(1, 'assets/images/Schedule.png', 'Schedule'),
              _buildNavItem(2, 'assets/images/Tasks.png', 'Tasks'),
              _buildNavItem(3, 'assets/images/Profile.png', 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String iconPath, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _handleNavigation(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Image.asset(
                iconPath,
                width: 22,
                height: 22,
                color: isSelected
                    ? const Color(0xFF1B52E8)
                    : const Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? const Color(0xFF1B52E8)
                    : const Color(0xFF9CA3AF),
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNavigation(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });

      if (index == 0) {
        // Navigate to Home
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HomeScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: animation.drive(
                      Tween(begin: const Offset(-1.0, 0.0), end: Offset.zero),
                    ),
                    child: child,
                  );
                },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      } else if (index == 1) {
        // Navigate to Schedule
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const ScheduleScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: animation.drive(
                      Tween(begin: const Offset(-1.0, 0.0), end: Offset.zero),
                    ),
                    child: child,
                  );
                },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      } else if (index == 2) {
        // Navigate to Tasks
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const TasksScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: animation.drive(
                      Tween(begin: const Offset(-1.0, 0.0), end: Offset.zero),
                    ),
                    child: child,
                  );
                },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      }
      // index == 3 is Profile, so we stay on this screen
    }
  }

  void _handleMenuItemTap(String title) {
    switch (title) {
      case 'Saved Courses':
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
        break;
      case 'Notification':
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const NotificationsScreen(),
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
        break;
      case 'Payment Method':
        // Navigate to payment method screen
        _showFeatureDialog(title);
        break;
      case 'Log Out':
        _showLogoutDialog();
        break;
      default:
        _showFeatureDialog(title);
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Log Out',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          content: Text(
            'Are you sure you want to log out?',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF6B7280),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _authService.signOut();
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const UserTypeSelectionScreen(),
                    ),
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B52E8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Log Out',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showFeatureDialog(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$feature feature coming soon!',
          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFF1B52E8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// Enhanced Custom clipper for profile header shape
class ProfileHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 50);

    // Create a more refined curve
    path.quadraticBezierTo(
      size.width * 0.2,
      size.height + 10,
      size.width * 0.5,
      size.height - 20,
    );
    path.quadraticBezierTo(
      size.width * 0.8,
      size.height - 50,
      size.width,
      size.height - 30,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Enhanced wave pattern painter - more subtle like the original design
class ModernWavePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Create subtle flowing shapes that match the original design
    final paint1 = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    // First wave - top area
    final path1 = Path();
    path1.moveTo(0, size.height * 0.3);
    path1.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.1,
      size.width * 0.6,
      size.height * 0.35,
    );
    path1.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.6,
      size.width,
      size.height * 0.3,
    );
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();
    canvas.drawPath(path1, paint1);

    // Second wave - middle area
    final paint2 = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height * 0.6);
    path2.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.4,
      size.width * 0.7,
      size.height * 0.65,
    );
    path2.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.8,
      size.width,
      size.height * 0.6,
    );
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
