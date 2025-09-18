import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'user_type_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _startAnimation();
  }

  void _startAnimation() async {
    await _animationController.forward();

    // Wait for 3 seconds total (2s animation + 1s delay)
    await Future.delayed(const Duration(milliseconds: 1000));

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const UserTypeSelectionScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),

                  // Logo and App Name with animation
                  Transform.scale(
                    scale: _scaleAnimation.value,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          // Full Logo with proper sizing
                          Container(
                            constraints: const BoxConstraints(
                              maxWidth: 300,
                              maxHeight: 400,
                            ),
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // App Icon/Logo fallback
                                    Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(24),
                                        gradient: const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFF4285F4),
                                            Color(0xFF8E44AD),
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.08,
                                            ),
                                            blurRadius: 16,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'S',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 56,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    // App Name fallback
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Sign',
                                            style: GoogleFonts.inter(
                                              fontSize: 36,
                                              fontWeight: FontWeight.w900,
                                              color: const Color(0xFF1A1A1A),
                                              letterSpacing: -1.0,
                                            ),
                                          ),
                                          TextSpan(
                                            text: 'O',
                                            style: GoogleFonts.inter(
                                              fontSize: 36,
                                              fontWeight: FontWeight.w900,
                                              color: const Color(0xFF4285F4),
                                              letterSpacing: -1.0,
                                            ),
                                          ),
                                          TextSpan(
                                            text: 'ra',
                                            style: GoogleFonts.inter(
                                              fontSize: 36,
                                              fontWeight: FontWeight.w900,
                                              color: const Color(0xFF8E44AD),
                                              letterSpacing: -1.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Tagline fallback
                                    Text(
                                      'CONNECT MINDS, INSPIRE GROWTH.',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF6B7280),
                                        letterSpacing: 1.2,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 4),

                  // Loading text with fade animation
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        children: [
                          Text(
                            'Preparing your learning experience...',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF6B7280),
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 20),

                          // Loading indicator with custom colors
                          SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF4285F4),
                              ),
                              backgroundColor: Colors.grey.withOpacity(0.2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
