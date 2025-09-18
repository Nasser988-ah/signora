import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 75,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, 'assets/images/home.png', 'Home'),
              _buildNavItem(1, 'assets/images/Schedule.png', 'Schedule'),
              _buildNavItem(2, 'assets/images/Tasks.png', 'Tasks'),
              _buildNavItem(3, 'assets/images/Profile.png', 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String iconPath, String label) {
    final isSelected = currentIndex == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(12),
        splashColor: const Color(0xFF3B82F6).withOpacity(0.1),
        highlightColor: const Color(0xFF3B82F6).withOpacity(0.05),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isSelected 
                ? const Color(0xFF3B82F6).withOpacity(0.08)
                : Colors.transparent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOutCubic,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Image.asset(
                    iconPath,
                    width: 22,
                    height: 22,
                    color: isSelected
                        ? const Color(0xFF3B82F6)
                        : const Color(0xFF9CA3AF),
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback to Material icons if image fails to load
                      IconData fallbackIcon;
                      switch (index) {
                        case 0:
                          fallbackIcon = isSelected ? Icons.home : Icons.home_outlined;
                          break;
                        case 1:
                          fallbackIcon = isSelected ? Icons.schedule : Icons.schedule_outlined;
                          break;
                        case 2:
                          fallbackIcon = isSelected ? Icons.task : Icons.task_outlined;
                          break;
                        case 3:
                          fallbackIcon = isSelected ? Icons.person : Icons.person_outline;
                          break;
                        default:
                          fallbackIcon = Icons.help_outline;
                      }
                      return Icon(
                        fallbackIcon,
                        size: 22,
                        color: isSelected
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFF9CA3AF),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOutCubic,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFF9CA3AF),
                  letterSpacing: -0.2,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
