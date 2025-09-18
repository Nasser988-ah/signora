import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'professor_home_screen.dart';
import '../constants/user_types.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  final UserType? userType;
  
  const RegisterScreen({super.key, this.userType});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
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
                    'Register',
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                
                const SizedBox(height: 60),
                
                // Full Name field
                Text(
                  'Full Name',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _fullNameController,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter your full name',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 16,
                        color: const Color(0xFFBBBBBB),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Color(0xFFBBBBBB),
                        size: 20,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Email or Phone's number field
                Text(
                  'Email or Phone\'s number',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _emailController,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Inputyouremail@hmail.com',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 16,
                        color: const Color(0xFFBBBBBB),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      suffixIcon: const Icon(
                        Icons.refresh,
                        color: Color(0xFFBBBBBB),
                        size: 20,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Password field
                Text(
                  'Your password',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Input your password',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 16,
                        color: const Color(0xFFBBBBBB),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: const Color(0xFFBBBBBB),
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Re-Enter Password field
                Text(
                  'Re-Enter Password',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Input your password',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 16,
                        color: const Color(0xFFBBBBBB),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                          color: const Color(0xFFBBBBBB),
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Error message
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.red.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Register Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleEmailRegistration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3A4FDE),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Register',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Already have an account? Log In
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) =>
                                  LoginScreen(userType: widget.userType),
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
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Log In',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF3A4FDE),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Social Login Buttons
                _buildSocialButton(
                  icon: Icons.apple,
                  text: 'Continue With Apple ID',
                  onPressed: () {
                    // Handle Apple login
                  },
                ),
                
                const SizedBox(height: 16),
                
                _buildSocialButton(
                  icon: Icons.facebook,
                  text: 'Continue With Facebook',
                  onPressed: () {
                    // Handle Facebook login
                  },
                ),
                
                const SizedBox(height: 16),
                
                _buildSocialButton(
                  icon: Icons.g_mobiledata,
                  text: 'Continue With Google',
                  onPressed: _isLoading ? null : _handleGoogleRegistration,
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Handle email registration
  Future<void> _handleEmailRegistration() async {
    // Validation
    if (_fullNameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _confirmPasswordController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all fields';
      });
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    if (_passwordController.text.length < 6) {
      setState(() {
        _errorMessage = 'Password must be at least 6 characters long';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      UserCredential? result = await _authService.registerWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        fullName: _fullNameController.text.trim(),
        userType: widget.userType ?? UserType.student,
      );

      if (result != null) {
        // Route based on user type
        Widget destinationScreen;
        if (widget.userType == UserType.professor) {
          destinationScreen = ProfessorHomeScreen(
            professorName: _fullNameController.text.trim(),
          );
        } else {
          destinationScreen = const HomeScreen();
        }
        
        if (mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => destinationScreen,
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 500),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Handle Google registration
  Future<void> _handleGoogleRegistration() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      UserCredential? result = await _authService.signInWithGoogle(
        userType: widget.userType ?? UserType.student,
      );

      if (result != null && result.user != null) {
        // Update last sign in
        await _authService.updateLastSignIn(result.user!.uid);
        
        // Route based on the original widget user type for Google sign-in
        Widget destinationScreen;
        if (widget.userType == UserType.professor) {
          destinationScreen = ProfessorHomeScreen(
            professorName: result.user!.displayName ?? "Professor",
          );
        } else {
          destinationScreen = const HomeScreen();
        }
        
        if (mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => destinationScreen,
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 500),
            ),
          );
        }
      } else {
        // User cancelled sign-in
        setState(() {
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String text,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey[300]!, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          backgroundColor: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.black87,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
