import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'create_account_screen.dart';
import 'professor_home_screen.dart';
import '../constants/user_types.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  final UserType? userType;
  
  const LoginScreen({super.key, this.userType});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _saveMe = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                    'Log In',
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),

                const SizedBox(height: 60),

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
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
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

                const SizedBox(height: 16),

                // Save me and Forgot password row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: _saveMe,
                            onChanged: (value) {
                              setState(() {
                                _saveMe = value;
                              });
                            },
                            activeColor: const Color(0xFF3A4FDE),
                            inactiveThumbColor: Colors.grey[400],
                            inactiveTrackColor: Colors.grey[300],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Save me',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: _handleForgotPassword,
                      child: Text(
                        'Forgot your password?',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF3A4FDE),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
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

                // Log In Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleEmailLogin,
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
                            'Log In',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // Don't have an account? Register
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account? ',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      CreateAccountScreen(userType: widget.userType),
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
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Register',
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
                  onPressed: _isLoading ? null : _handleGoogleLogin,
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Handle email login
  Future<void> _handleEmailLogin() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all fields';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      UserCredential? result = await _authService.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (result != null) {
        // Update last sign in
        await _authService.updateLastSignIn(result.user!.uid);
        
        // Get user type from Firestore
        UserType? userType = await _authService.getUserType(result.user!.uid);
        
        // Route based on user type
        Widget destinationScreen;
        if (userType == UserType.professor) {
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

  // Handle Google login
  Future<void> _handleGoogleLogin() async {
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

  // Handle forgot password
  Future<void> _handleForgotPassword() async {
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email address first';
      });
      return;
    }

    try {
      await _authService.resetPassword(_emailController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Password reset email sent to ${_emailController.text.trim()}',
              style: GoogleFonts.inter(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
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
            Icon(icon, color: Colors.black87, size: 20),
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
