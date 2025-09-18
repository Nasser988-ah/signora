import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryTabs extends StatefulWidget {
  const CategoryTabs({super.key});

  @override
  State<CategoryTabs> createState() => _CategoryTabsState();
}

class _CategoryTabsState extends State<CategoryTabs> {
  int selectedIndex = 2; // UI UX is selected by default
  final List<String> categories = [
    'Graphic Design',
    'App Interface',
    'UI UX',
    'User Interface',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return Padding(
            padding: EdgeInsets.only(
              right: index < categories.length - 1 ? 10 : 0,
            ),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = index;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF3B82F6) : Colors.white,
                  borderRadius: BorderRadius.circular(19),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF3B82F6)
                        : const Color(0xFFE5E7EB),
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF3B82F6).withOpacity(0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                ),
                child: Center(
                  child: Text(
                    categories[index],
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
