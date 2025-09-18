import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsScreen extends StatefulWidget {
  final bool isProfessor;

  const NotificationsScreen({
    Key? key,
    this.isProfessor = false,
  }) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
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
          'Notifications',
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
              // TODO: Mark all as read functionality
            },
            icon: const Icon(
              Icons.done_all,
              color: Color(0xFF6B7280),
              size: 20,
            ),
          ),
        ],
      ),
      body: _buildEmptyState(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Notification Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF5B6FEE).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.notifications_outlined,
                size: 60,
                color: Color(0xFF5B6FEE),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Title
            Text(
              'No notifications yet',
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
              widget.isProfessor
                  ? 'You\'ll receive updates about your courses,\nstudent enrollments, and system announcements here.'
                  : 'You\'ll receive updates about your courses,\nnew lessons, and important announcements here.',
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
                    // TODO: Navigate to notification settings or enable notifications
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Notification preferences updated',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        backgroundColor: const Color(0xFF10B981),
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
                      'Enable Notifications',
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
          ],
        ),
      ),
    );
  }
}
