import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'professor_main_screen.dart';
import '../constants/user_types.dart';

class UserTypeSelectionScreen extends StatefulWidget {
  const UserTypeSelectionScreen({super.key});

  @override
  State<UserTypeSelectionScreen> createState() =>
      _UserTypeSelectionScreenState();
}

class _UserTypeSelectionScreenState extends State<UserTypeSelectionScreen> {
  UserType? _selectedUserType;

  @override
  void initState() {
    super.initState();
    _selectedUserType = UserType.student;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Text
                    const Text(
                      'Welcome',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Select User Type',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 30.0),

                    // Student Card
                    _buildUserTypeCard(
                      userType: UserType.student,
                      title: 'Student',
                      subtitle: 'Access your courses,\nassignments, and more',
                      imagePath: 'assets/images/Student.png',
                    ),
                    const SizedBox(height: 16.0),

                    // Professor Card
                    _buildUserTypeCard(
                      userType: UserType.professor,
                      title: 'Professor',
                      subtitle: 'Manage your classes and\nstudent progress',
                      imagePath: 'assets/images/Proessor.png',
                    ),
                  ],
                ),
              ),
            ),

            // Next Button - Fixed at bottom
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Route to login screen with selected user type
                    Navigator.of(context).pushReplacement(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            LoginScreen(userType: _selectedUserType),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                        transitionDuration: const Duration(milliseconds: 500),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A4FDE),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTypeCard({
    required UserType userType,
    required String title,
    required String subtitle,
    required String imagePath,
  }) {
    final bool isSelected = _selectedUserType == userType;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedUserType = userType;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: isSelected ? const Color(0xFF3A4FDE) : Colors.grey[300]!,
            width: isSelected ? 2.5 : 1.0,
          ),
          color: isSelected
              ? const Color(0xFF3A4FDE).withValues(alpha: 0.08)
              : Colors.white,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF3A4FDE).withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Column(
          children: [
            // Illustration
            SizedBox(
              height: 100,
              width: double.infinity,
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if image doesn't exist
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      userType == UserType.student
                          ? Icons.school
                          : Icons.person,
                      size: 50,
                      color: Colors.grey[400],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF3A4FDE) : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
