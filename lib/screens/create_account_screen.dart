import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'register_screen.dart';
import '../constants/user_types.dart';

class CreateAccountScreen extends StatefulWidget {
  final UserType? userType;
  
  const CreateAccountScreen({super.key, this.userType});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _universityController = TextEditingController();
  final TextEditingController _collegeController = TextEditingController();
  final TextEditingController _majorController = TextEditingController();
  final TextEditingController _academicYearController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _universityController.dispose();
    _collegeController.dispose();
    _majorController.dispose();
    _academicYearController.dispose();
    super.dispose();
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // Title
                Center(
                  child: Text(
                    'Create New Account',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // First Name and Last Name Row
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        controller: _firstNameController,
                        label: 'First Name',
                        hint: 'Enter your Name',
                        icon: Icons.person,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInputField(
                        controller: _lastNameController,
                        label: 'Last Name',
                        hint: 'Last Name',
                        icon: Icons.person,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Phone Number
                _buildInputField(
                  controller: _phoneController,
                  label: 'Phone No.',
                  hint: '000',
                  icon: Icons.phone,
                ),
                
                const SizedBox(height: 20),
                
                // University
                _buildInputField(
                  controller: _universityController,
                  label: 'University',
                  hint: 'Enter Your University',
                  icon: Icons.school,
                ),
                
                const SizedBox(height: 20),
                
                // College
                _buildInputField(
                  controller: _collegeController,
                  label: 'College',
                  hint: 'Enter Your College Name',
                  icon: Icons.account_balance,
                ),
                
                const SizedBox(height: 20),
                
                // Major
                _buildInputField(
                  controller: _majorController,
                  label: 'Major',
                  hint: 'Enter Your University',
                  icon: Icons.menu_book,
                ),
                
                const SizedBox(height: 20),
                
                // Academic Year
                _buildInputField(
                  controller: _academicYearController,
                  label: 'Academic Year',
                  hint: 'Enter Your University',
                  icon: Icons.calendar_today,
                ),
                
                const SizedBox(height: 40),
                
                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              RegisterScreen(userType: widget.userType),
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
                    child: Text(
                      'Sign Up',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF3A4FDE),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF3A4FDE),
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: controller,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFFBBBBBB),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              prefixIcon: Icon(
                icon,
                color: const Color(0xFF3A4FDE),
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
