import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CourseCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double? progress;
  final String? price;
  final double? rating;
  final bool isOngoing;
  final String? thumbnailUrl;
  final VoidCallback? onTap;

  const CourseCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.progress,
    this.price,
    this.rating,
    required this.isOngoing,
    this.thumbnailUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isOngoing ? 280 : 160,
        height: isOngoing ? 130 : 220,
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
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: isOngoing ? _buildOngoingCard() : _buildSuggestedCard(),
        ),
      ),
    );
  }

  Widget _buildOngoingCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with icon and title
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.design_services_outlined,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6B7280),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Description text
        Text(
          'Learn how to design user interface from design to prototype',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF6B7280),
            height: 1.3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const Spacer(),
        // Progress section
        if (progress != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '5 videos left',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7280),
                ),
              ),
              Text(
                '${(progress! * 100).toInt()}%',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF3B82F6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
            borderRadius: BorderRadius.circular(2),
            minHeight: 3,
          ),
        ],
      ],
    );
  }

  Widget _buildSuggestedCard() {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image container with thumbnail or gradient background
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: thumbnailUrl == null ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                  ) : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: thumbnailUrl != null
                      ? Image.network(
                          thumbnailUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.school_outlined,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                                ),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                        )
                      : Stack(
                          children: [
                            // Background decorative elements
                            Positioned(
                              right: -20,
                              top: -20,
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                            Positioned(
                              left: -15,
                              bottom: -15,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            // Course topic icon/illustration
                            const Center(
                              child: Icon(
                                Icons.school_outlined,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Content section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Instructor name
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6B7280),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Rating and price row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (rating != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                color: Color(0xFFFBBF24),
                                size: 12,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                rating.toString(),
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(4.7)',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ),
                        if (price != null)
                          Text(
                            price!,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF3B82F6),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        // Bookmark icon in top right
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.bookmark_border,
              color: Color(0xFF6B7280),
              size: 14,
            ),
          ),
        ),
      ],
    );
  }
}
