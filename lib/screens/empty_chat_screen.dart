import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmptyChatScreen extends StatelessWidget {
  final bool isProfessor;

  const EmptyChatScreen({
    Key? key,
    this.isProfessor = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF1A1A1A),
            size: 20,
          ),
        ),
        title: Text(
          'Messages',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Search messages functionality
            },
            icon: const Icon(
              Icons.search,
              color: Color(0xFF6B7280),
              size: 20,
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Chat Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF5B6FEE).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Icon(
                  Icons.chat_bubble_outline,
                  size: 60,
                  color: Color(0xFF5B6FEE),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Title
              Text(
                'No conversations yet',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                  letterSpacing: -0.5,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Description
              Text(
                isProfessor
                    ? 'Connect with your students and colleagues.\nStart meaningful conversations about courses and learning.'
                    : 'Connect with your instructors and classmates.\nStart conversations about courses and get help when you need it.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Action Button
              Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFF4F63D2), Color(0xFF5B6FEE)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5B6FEE).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      // TODO: Navigate to start new conversation or contact list
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isProfessor 
                                ? 'Contact feature coming soon for professors'
                                : 'Contact feature coming soon for students',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          backgroundColor: const Color(0xFF3B82F6),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Center(
                      child: Text(
                        isProfessor ? 'Contact Students' : 'Find Instructors',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Secondary Action
              TextButton(
                onPressed: () {
                  // TODO: Navigate to help or support
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Help center coming soon',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      backgroundColor: const Color(0xFF6B7280),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                child: Text(
                  'Need Help?',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
