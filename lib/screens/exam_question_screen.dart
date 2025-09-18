import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'exam_result_screen.dart';

class Question {
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;

  Question({
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
  });
}

class ExamQuestionScreen extends StatefulWidget {
  final String title;
  final String instructor;

  const ExamQuestionScreen({
    Key? key,
    required this.title,
    required this.instructor,
  }) : super(key: key);

  @override
  State<ExamQuestionScreen> createState() => _ExamQuestionScreenState();
}

class _ExamQuestionScreenState extends State<ExamQuestionScreen> {
  // Sample questions
  final List<Question> questions = [
    Question(
      questionText: 'What is the main purpose of a wireframe in UX design?',
      options: [
        'Choose colors and fonts',
        'Show layout and structure',
        'Test the final product',
      ],
      correctAnswerIndex: 1,
    ),
    Question(
      questionText: 'Which of the following is NOT a principle of visual hierarchy?',
      options: [
        'Size and scale',
        'Random placement',
        'Color and contrast',
      ],
      correctAnswerIndex: 1,
    ),
    Question(
      questionText: 'What does UI stand for?',
      options: [
        'User Interface',
        'User Interaction',
        'Universal Interface',
      ],
      correctAnswerIndex: 0,
    ),
    Question(
      questionText: 'Which of these is a key principle of user-centered design?',
      options: [
        'Focus on aesthetics over usability',
        'Design for the average user only',
        'Involve users throughout the design process',
      ],
      correctAnswerIndex: 2,
    ),
    Question(
      questionText: 'What is the purpose of a mood board in design?',
      options: [
        'To track project deadlines',
        'To collect visual inspiration',
        'To document user feedback',
      ],
      correctAnswerIndex: 1,
    ),
    Question(
      questionText: 'Which color model is used for digital design?',
      options: [
        'CMYK',
        'RGB',
        'HSL',
      ],
      correctAnswerIndex: 1,
    ),
    Question(
      questionText: 'What is the purpose of white space in design?',
      options: [
        'To save on printing costs',
        'To create visual breathing room',
        'To make text smaller',
      ],
      correctAnswerIndex: 1,
    ),
    Question(
      questionText: 'Which file format is best for web graphics with transparency?',
      options: [
        'JPG',
        'PNG',
        'BMP',
      ],
      correctAnswerIndex: 1,
    ),
    Question(
      questionText: 'What does the term "responsive design" refer to?',
      options: [
        'Designs that respond to user feedback',
        'Designs that adapt to different screen sizes',
        'Designs that load quickly',
      ],
      correctAnswerIndex: 1,
    ),
    Question(
      questionText: 'Which of these is NOT a common UX deliverable?',
      options: [
        'User personas',
        'Source code',
        'User journey maps',
      ],
      correctAnswerIndex: 1,
    ),
  ];

  int currentQuestionIndex = 0;
  int? selectedAnswerIndex;
  bool isAnswerCorrect = false;
  bool isAnswerSubmitted = false;
  int correctAnswers = 0;
  int timeRemaining = 16 * 60; // 16 minutes in seconds
  late Timer timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeRemaining > 0) {
        setState(() {
          timeRemaining--;
        });
      } else {
        timer.cancel();
        navigateToResultScreen();
      }
    });
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void selectAnswer(int index) {
    if (!isAnswerSubmitted) {
      setState(() {
        selectedAnswerIndex = index;
        isAnswerCorrect = index == questions[currentQuestionIndex].correctAnswerIndex;
        isAnswerSubmitted = true;
        
        if (isAnswerCorrect) {
          correctAnswers++;
        }
      });
    }
  }

  void goToNextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswerIndex = null;
        isAnswerSubmitted = false;
      });
    } else {
      navigateToResultScreen();
    }
  }

  void navigateToResultScreen() {
    timer.cancel();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ExamResultScreen(
          title: widget.title,
          instructor: widget.instructor,
          score: correctAnswers,
          totalQuestions: questions.length,
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
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = questions[currentQuestionIndex];
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with progress
              Text(
                'Questions',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${currentQuestionIndex + 1}/${questions.length}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1F2937),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (currentQuestionIndex + 1) / questions.length,
                  backgroundColor: const Color(0xFFE5E7EB),
                  color: const Color(0xFF3A4FDE),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 16),
              // Timer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    formatTime(timeRemaining),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Question
              Text(
                currentQuestion.questionText,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Options
              ...List.generate(
                currentQuestion.options.length,
                (index) => GestureDetector(
                  onTap: () => selectAnswer(index),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: _getOptionColor(index),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getOptionBorderColor(index),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getCircleColor(index),
                            border: Border.all(
                              color: _getCircleBorderColor(index),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: _getOptionIcon(index),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            currentQuestion.options[index],
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Answer explanation (only shown after answering)
              if (isAnswerSubmitted)
                Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isAnswerCorrect
                        ? 'Correct! The answer is: ${currentQuestion.options[currentQuestion.correctAnswerIndex]}'
                        : 'Incorrect. The correct answer is: ${currentQuestion.options[currentQuestion.correctAnswerIndex]}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: isAnswerCorrect ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                    ),
                  ),
                ),
              
              const Spacer(),
              
              // Next button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isAnswerSubmitted ? goToNextQuestion : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A4FDE),
                    disabledBackgroundColor: const Color(0xFFE5E7EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Next',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isAnswerSubmitted ? Colors.white : const Color(0xFF9CA3AF),
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

  Color _getOptionColor(int index) {
    if (!isAnswerSubmitted) {
      return selectedAnswerIndex == index ? const Color(0xFFF3F4F6) : Colors.white;
    } else {
      if (index == questions[currentQuestionIndex].correctAnswerIndex) {
        return const Color(0xFFDCFCE7); // Light green for correct answer
      } else if (index == selectedAnswerIndex) {
        return const Color(0xFFFEE2E2); // Light red for wrong selected answer
      } else {
        return Colors.white;
      }
    }
  }

  Color _getOptionBorderColor(int index) {
    if (!isAnswerSubmitted) {
      return selectedAnswerIndex == index ? const Color(0xFF3A4FDE) : const Color(0xFFE5E7EB);
    } else {
      if (index == questions[currentQuestionIndex].correctAnswerIndex) {
        return const Color(0xFF22C55E); // Green for correct answer
      } else if (index == selectedAnswerIndex) {
        return const Color(0xFFEF4444); // Red for wrong selected answer
      } else {
        return const Color(0xFFE5E7EB);
      }
    }
  }

  Color _getCircleColor(int index) {
    if (!isAnswerSubmitted) {
      return selectedAnswerIndex == index ? const Color(0xFF3A4FDE) : Colors.white;
    } else {
      if (index == questions[currentQuestionIndex].correctAnswerIndex) {
        return const Color(0xFF22C55E); // Green for correct answer
      } else if (index == selectedAnswerIndex) {
        return const Color(0xFFEF4444); // Red for wrong selected answer
      } else {
        return Colors.white;
      }
    }
  }

  Color _getCircleBorderColor(int index) {
    if (!isAnswerSubmitted) {
      return selectedAnswerIndex == index ? const Color(0xFF3A4FDE) : const Color(0xFFE5E7EB);
    } else {
      if (index == questions[currentQuestionIndex].correctAnswerIndex) {
        return const Color(0xFF22C55E); // Green for correct answer
      } else if (index == selectedAnswerIndex) {
        return const Color(0xFFEF4444); // Red for wrong selected answer
      } else {
        return const Color(0xFFE5E7EB);
      }
    }
  }

  Widget? _getOptionIcon(int index) {
    if (!isAnswerSubmitted) {
      return selectedAnswerIndex == index 
          ? Text(
              String.fromCharCode(65 + index), // A, B, C, etc.
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            )
          : Text(
              String.fromCharCode(65 + index), // A, B, C, etc.
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
              ),
            );
    } else {
      if (index == questions[currentQuestionIndex].correctAnswerIndex) {
        return const Icon(Icons.check, size: 16, color: Colors.white);
      } else if (index == selectedAnswerIndex) {
        return const Icon(Icons.close, size: 16, color: Colors.white);
      } else {
        return Text(
          String.fromCharCode(65 + index), // A, B, C, etc.
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6B7280),
          ),
        );
      }
    }
  }
}