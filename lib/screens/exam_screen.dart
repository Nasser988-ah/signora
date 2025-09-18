import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'exam_question_screen.dart';

class ExamScreen extends StatefulWidget {
  final String title;
  final String instructor;

  const ExamScreen({
    Key? key,
    required this.title,
    required this.instructor,
  }) : super(key: key);

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 16,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Exam',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.bookmark,
                      size: 16,
                      color: Color(0xFF3A4FDE),
                    ),
                  ),
                ],
              ),
            ),
            
            // Course Info
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Course Image and Info
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.grey[200],
                            child: Text(
                              widget.title.isNotEmpty ? widget.title[0] : 'C',
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF3A4FDE),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.title,
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1F2937),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.instructor,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Color(0xFFFFC107),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '4.5',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF1F2937),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    const Icon(
                                      Icons.access_time,
                                      color: Color(0xFF6B7280),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '4h35m',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF1F2937),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    const Icon(
                                      Icons.menu_book,
                                      color: Color(0xFF6B7280),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '12 lessons',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF1F2937),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Brief explanation
                      Text(
                        'Brief explanation about this Exam',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Exam details
                      _buildExamInfoItem(
                        Icons.help_outline,
                        '10 Question',
                        '10 point for a correct answer',
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildExamInfoItem(
                        Icons.access_time,
                        '15 mins',
                        'Total duration of the Exam',
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildExamInfoItem(
                        Icons.star,
                        'Win 10 star',
                        'Answer all questions correctly',
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Instructions
                      Text(
                        'Please read the text below carefully\nso you can understand it',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Bullet points
                      _buildBulletPoint('You will get 10 points for every correct answer; no points for wrong ones.'),
                      const SizedBox(height: 12),
                      _buildBulletPoint('Tap on options to select the correct answer'),
                      const SizedBox(height: 12),
                      _buildBulletPoint('Tap on the bookmark icon to save interesting questions'),
                      
                      const SizedBox(height: 32),
                      
                      // Start Exam button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => ExamQuestionScreen(
                                  title: widget.title,
                                  instructor: widget.instructor,
                                ),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  const begin = Offset(1.0, 0.0);
                                  const end = Offset.zero;
                                  const curve = Curves.easeInOut;
                                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                  var offsetAnimation = animation.drive(tween);
                                  return SlideTransition(position: offsetAnimation, child: child);
                                },
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3A4FDE),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Start Exam',
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
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildExamInfoItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF3A4FDE),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: Color(0xFF1F2937),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF1F2937),
            ),
          ),
        ),
      ],
    );
  }
}