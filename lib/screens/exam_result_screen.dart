import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExamResultScreen extends StatelessWidget {
  final String title;
  final String instructor;
  final int score;
  final int totalQuestions;

  const ExamResultScreen({
    Key? key,
    required this.title,
    required this.instructor,
    required this.score,
    required this.totalQuestions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Congratulation image
              Image.asset(
                'assets/images/Congratulation.png',
                height: 180,
                width: 180,
              ),
              const SizedBox(height: 32),
              
              // Congratulation text
              Text(
                'Congratulation!',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Score
              Text(
                'Your result is: $score/$totalQuestions',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF3A4FDE),
                ),
                textAlign: TextAlign.center,
              ),
              
              const Spacer(),
              
              // Complete button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Pop back to the exam screen, which will then pop back to the saved courses screen
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A4FDE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Complete',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
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