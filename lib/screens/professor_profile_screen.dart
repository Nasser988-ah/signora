import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';
import 'user_type_selection_screen.dart';

class ProfessorProfileScreen extends StatefulWidget {
  final bool showBottomNav;
  
  const ProfessorProfileScreen({super.key, this.showBottomNav = true});

  @override
  State<ProfessorProfileScreen> createState() => _ProfessorProfileScreenState();
}

class _ProfessorProfileScreenState extends State<ProfessorProfileScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 3; // Profile tab is selected
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  final AuthService _authService = AuthService();
  
  // Bio editing state
  bool _isEditingBio = false;
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  String _currentBio = '';
  String _currentSubject = '';
  bool _isLoading = false;

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
    _loadProfessorProfile();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _bioController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final safeAreaTop = MediaQuery.of(context).padding.top;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;

    // Professional layout calculations to prevent pixel issues
    final headerHeight = screenHeight * 0.45;
    final contentHeight = screenHeight - headerHeight - safeAreaBottom - kBottomNavigationBarHeight;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          // Enhanced Header Section
          SizedBox(
            height: headerHeight,
            child: _buildHeaderSection(screenHeight, screenWidth, safeAreaTop),
          ),

          // Content Section with Animation
          SizedBox(
            height: contentHeight,
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
      bottomNavigationBar: widget.showBottomNav ? _buildBottomNavigationBar() : null,
    );
  }

  Widget _buildHeaderSection(double screenHeight, double screenWidth, double safeAreaTop) {
    return Stack(
      children: [
        // Main blue background with curved bottom
        Container(
          height: screenHeight * 0.35,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
            ),
          ),
          child: CustomPaint(
            painter: ModernWavePatternPainter(),
            size: Size.infinite,
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
        _buildAppBar(safeAreaTop),

        // Profile Avatar - positioned to overlap both sections
        Positioned(
          bottom: screenHeight * 0.08,
          left: screenWidth / 2 - 50,
          child: _buildProfileAvatar(),
        ),
      ],
    );
  }

  Widget _buildAppBar(double safeAreaTop) {
    return Positioned(
      top: safeAreaTop,
      left: 0,
      right: 0,
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
                // Handle chat navigation
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({required IconData icon, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
                    color: const Color(0xFFE5E7EB),
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF3B82F6),
                        ),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFE5E7EB),
                    child: const Icon(
                      Icons.person,
                      color: Color(0xFF6B7280),
                      size: 40,
                    ),
                  );
                },
              )
            : Container(
                color: const Color(0xFFE5E7EB),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF6B7280),
                  size: 40,
                ),
              ),
      ),
    );
  }

  Widget _buildContentSection(double screenWidth) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Column(
        children: [
          const SizedBox(height: 16),
          
          // Professor Name and Handle
          _buildProfessorInfo(),
          
          const SizedBox(height: 24),
          
          // Subject and Description
          _buildSubjectSection(),
          
          const SizedBox(height: 32),
          
          // Menu Items
          _buildMenuItems(),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProfessorInfo() {
    return Column(
      children: [
        Text(
          _authService.getCurrentUserName(),
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          _authService.getCurrentUserEmail(),
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF6B7280),
            letterSpacing: -0.2,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSubjectSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _isEditingBio
                    ? TextField(
                        controller: _subjectController,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F2937),
                        ),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: 'Enter your subject',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      )
                    : Text(
                        _currentSubject.isEmpty ? 'Your Subject' : _currentSubject,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F2937),
                          letterSpacing: -0.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
              ),
              if (!_isEditingBio)
                GestureDetector(
                  onTap: _startEditing,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 16,
                      color: Color(0xFF3B82F6),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _isEditingBio
              ? Column(
                  children: [
                    TextField(
                      controller: _bioController,
                      maxLines: 4,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
                        height: 1.5,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Write about yourself, your expertise, and teaching experience...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _cancelEditing,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B7280),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveBio,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B82F6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(
                                    'Save',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Text(
                  _currentBio.isEmpty 
                      ? 'Tap the edit button to add information about yourself, your expertise, and teaching experience.'
                      : _currentBio,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: _currentBio.isEmpty ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                    height: 1.5,
                    letterSpacing: -0.1,
                  ),
                  textAlign: TextAlign.center,
                ),
        ],
      ),
    );
  }

  // Load professor profile data
  Future<void> _loadProfessorProfile() async {
    try {
      final userEmail = _authService.getCurrentUserEmail();
      if (userEmail != null) {
        final profile = await SupabaseService.getProfessorProfile(userEmail);
        if (profile != null && mounted) {
          setState(() {
            _currentBio = profile['bio'] ?? '';
            _currentSubject = profile['subject'] ?? '';
            _bioController.text = _currentBio;
            _subjectController.text = _currentSubject;
          });
        }
      }
    } catch (e) {
      print('Error loading professor profile: $e');
    }
  }

  // Start editing mode
  void _startEditing() {
    setState(() {
      _isEditingBio = true;
      _bioController.text = _currentBio;
      _subjectController.text = _currentSubject;
    });
  }

  // Cancel editing
  void _cancelEditing() {
    setState(() {
      _isEditingBio = false;
      _bioController.text = _currentBio;
      _subjectController.text = _currentSubject;
    });
  }

  // Save bio and subject
  Future<void> _saveBio() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userEmail = _authService.getCurrentUserEmail();
      if (userEmail != null) {
        await SupabaseService.updateProfessorProfile(
          userEmail,
          bio: _bioController.text.trim(),
          subject: _subjectController.text.trim(),
        );

        if (mounted) {
          setState(() {
            _currentBio = _bioController.text.trim();
            _currentSubject = _subjectController.text.trim();
            _isEditingBio = false;
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Profile updated successfully!',
                style: GoogleFonts.inter(color: Colors.white),
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update profile. Please try again.',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  Widget _buildMenuItems() {
    final menuItems = [
      {
        'icon': Icons.person_outline,
        'title': 'Contact Information',
        'color': const Color(0xFF3B82F6),
      },
      {
        'icon': Icons.book_outlined,
        'title': 'My Courses',
        'color': const Color(0xFF3B82F6),
      },
      {
        'icon': Icons.notifications_outlined,
        'title': 'Notification',
        'color': const Color(0xFF3B82F6),
      },
      {
        'icon': Icons.security_outlined,
        'title': 'Privacy & security',
        'color': const Color(0xFF3B82F6),
      },
      {
        'icon': Icons.logout_outlined,
        'title': 'Log Out',
        'color': const Color(0xFF3B82F6),
      },
    ];

    return Column(
      children: menuItems.map((item) => _buildMenuItem(
        icon: item['icon'] as IconData,
        title: item['title'] as String,
        color: item['color'] as Color,
      )).toList(),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _handleMenuItemTap(title);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
                width: 1,
              ),
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
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1F2937),
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: const Color(0xFF9CA3AF),
                  size: 20,
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
            spreadRadius: 0,
            blurRadius: 10,
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

  void _handleMenuItemTap(String title) {
    switch (title) {
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
                backgroundColor: const Color(0xFF3B82F6),
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
        backgroundColor: const Color(0xFF3B82F6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// Enhanced wave pattern painter - matching the design
class ModernWavePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Create subtle wave patterns
    path.moveTo(0, size.height * 0.3);
    path.quadraticBezierTo(
      size.width * 0.25, size.height * 0.2,
      size.width * 0.5, size.height * 0.3,
    );
    path.quadraticBezierTo(
      size.width * 0.75, size.height * 0.4,
      size.width, size.height * 0.3,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Add second wave layer
    final paint2 = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height * 0.6);
    path2.quadraticBezierTo(
      size.width * 0.3, size.height * 0.5,
      size.width * 0.6, size.height * 0.6,
    );
    path2.quadraticBezierTo(
      size.width * 0.8, size.height * 0.7,
      size.width, size.height * 0.6,
    );
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
