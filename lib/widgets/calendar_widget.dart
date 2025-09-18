import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CalendarWidget extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const CalendarWidget({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late DateTime currentMonth;
  bool showFullCalendar = false;

  @override
  void initState() {
    super.initState();
    currentMonth = DateTime(widget.selectedDate.year, widget.selectedDate.month);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Month and year header
        _buildMonthHeader(),
        
        const SizedBox(height: 16),
        
        // Week view (always visible)
        _buildWeekView(),
        
        // Full calendar (shown when tapped)
        if (showFullCalendar) ...[
          const SizedBox(height: 16),
          _buildFullCalendar(),
        ],
      ],
    );
  }

  Widget _buildMonthHeader() {
    return GestureDetector(
      onTap: () {
        setState(() {
          showFullCalendar = !showFullCalendar;
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _getMonthYearString(currentMonth),
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            showFullCalendar ? Icons.keyboard_arrow_up : Icons.calendar_month,
            color: const Color(0xFF6B7280),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildWeekView() {
    final startOfWeek = _getStartOfWeek(widget.selectedDate);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        final date = startOfWeek.add(Duration(days: index));
        final isSelected = _isSameDay(date, widget.selectedDate);
        final isToday = _isSameDay(date, DateTime.now());
        
        return GestureDetector(
          onTap: () => widget.onDateSelected(date),
          child: Container(
            width: 40,
            height: 60,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getDayName(date.weekday),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: isSelected 
                        ? Colors.white 
                        : const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? Colors.white.withOpacity(0.2)
                        : (isToday ? const Color(0xFF3B82F6).withOpacity(0.1) : Colors.transparent),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      date.day.toString(),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected 
                            ? Colors.white 
                            : (isToday ? const Color(0xFF3B82F6) : const Color(0xFF1F2937)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFullCalendar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Calendar header with navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
                  });
                },
                child: const Icon(
                  Icons.chevron_left,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              Column(
                children: [
                  Text(
                    currentMonth.year.toString(),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    _getMonthName(currentMonth.month),
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
                  });
                },
                child: const Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Days of week header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
                .map((day) => SizedBox(
                      width: 32,
                      child: Center(
                        child: Text(
                          day,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          
          const SizedBox(height: 12),
          
          // Calendar grid
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDayOfMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0);
    final firstDayWeekday = firstDayOfMonth.weekday % 7; // Sunday = 0
    final daysInMonth = lastDayOfMonth.day;
    
    final weeks = <Widget>[];
    var currentWeek = <Widget>[];
    
    // Add empty cells for days before the first day of the month
    for (int i = 0; i < firstDayWeekday; i++) {
      currentWeek.add(const SizedBox(width: 32, height: 32));
    }
    
    // Add days of the month
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(currentMonth.year, currentMonth.month, day);
      final isSelected = _isSameDay(date, widget.selectedDate);
      
      currentWeek.add(
        GestureDetector(
          onTap: () {
            widget.onDateSelected(date);
            setState(() {
              showFullCalendar = false;
            });
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? const Color(0xFF3B82F6) : Colors.white,
                ),
              ),
            ),
          ),
        ),
      );
      
      if (currentWeek.length == 7) {
        weeks.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: currentWeek,
            ),
          ),
        );
        currentWeek = <Widget>[];
      }
    }
    
    // Add remaining empty cells if needed
    while (currentWeek.length < 7 && currentWeek.isNotEmpty) {
      currentWeek.add(const SizedBox(width: 32, height: 32));
    }
    
    if (currentWeek.isNotEmpty) {
      weeks.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: currentWeek,
        ),
      );
    }
    
    return Column(children: weeks);
  }

  DateTime _getStartOfWeek(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return date.subtract(Duration(days: daysFromMonday));
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    return months[month - 1];
  }

  String _getMonthYearString(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} , ${date.year}';
  }
}
