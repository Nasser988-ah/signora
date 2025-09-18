import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/course.dart';

class EnrollmentFormScreen extends StatefulWidget {
  final Course course;

  const EnrollmentFormScreen({
    Key? key,
    required this.course,
  }) : super(key: key);

  @override
  State<EnrollmentFormScreen> createState() => _EnrollmentFormScreenState();
}

class _EnrollmentFormScreenState extends State<EnrollmentFormScreen> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse('https://docs.google.com/forms/d/e/1FAIpQLSdEAHA5cCnggRz_03Gf8epJ-4Dy3ZSQDQzczp8u6S-16bBZPw/viewform'));
  }

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
            Icons.close,
            color: Color(0xFF1A1A1A),
            size: 24,
          ),
        ),
        title: Text(
          'Course Enrollment',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF5B6FEE),
              ),
            ),
        ],
      ),
    );
  }
}
