import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/lecture.dart';

class LectureItem extends StatelessWidget {
  final Lecture lecture;
  final VoidCallback onTap;

  const LectureItem({super.key, required this.lecture, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Time column
            _buildTimeColumn(),

            const SizedBox(width: 16),

            // Play button
            _buildPlayButton(),

            const SizedBox(width: 16),

            // Lecture details
            Expanded(child: _buildLectureDetails()),

            // Notification icon
            if (lecture.hasNotification) _buildNotificationIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeColumn() {
    return SizedBox(
      width: 50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            lecture.startTime.split(' ')[0], // Get time without AM/PM
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          Text(
            lecture.startTime.split(' ')[1], // Get AM/PM
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayButton() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(Icons.play_arrow, color: Colors.white, size: 20),
    );
  }

  Widget _buildLectureDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lecture.title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (lecture.subtitle.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            lecture.subtitle,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B7280),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(
              Icons.person_outline,
              color: Color(0xFF9CA3AF),
              size: 14,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                lecture.instructor,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7280),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            const Icon(
              Icons.access_time_outlined,
              color: Color(0xFF9CA3AF),
              size: 14,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                lecture.timeRange,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7280),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotificationIcon() {
    return Container(
      padding: const EdgeInsets.all(4),
      child: const Icon(
        Icons.notifications,
        color: Color(0xFF3B82F6),
        size: 18,
      ),
    );
  }
}
