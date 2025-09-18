import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/professor_bottom_nav.dart';

class ProfessorScheduleScreen extends StatefulWidget {
  final bool showBottomNav;
  
  const ProfessorScheduleScreen({Key? key, this.showBottomNav = true}) : super(key: key);

  @override
  State<ProfessorScheduleScreen> createState() => _ProfessorScheduleScreenState();
}

class _ProfessorScheduleScreenState extends State<ProfessorScheduleScreen> {
  int _currentIndex = 1; // Schedule tab is selected
  DateTime selectedDate = DateTime(2025, 5, 20);
  DateTime currentMonth = DateTime(2025, 5);
  bool showCalendarPicker = false;

  // Empty list to show "No Live Courses Scheduled" state
  final List<LectureItem> lectures = [];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final safeAreaTop = MediaQuery.of(context).padding.top;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    
    // Professional layout calculations to prevent pixel issues
    final availableHeight = screenHeight - safeAreaTop - safeAreaBottom - kBottomNavigationBarHeight;
    final headerHeight = 60.0;
    final calendarSectionHeight = 120.0;
    final lecturesListHeight = availableHeight - headerHeight - calendarSectionHeight;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header - Fixed height to prevent overflow
                SizedBox(
                  height: headerHeight,
                  child: _buildHeader(screenWidth),
                ),
                
                // Calendar Section - Fixed height to prevent overflow
                SizedBox(
                  height: calendarSectionHeight,
                  child: _buildCalendarSection(screenWidth),
                ),
                
                // Upcoming Lectures - Calculated height to prevent overflow
                SizedBox(
                  height: lecturesListHeight,
                  child: _buildLecturesList(screenWidth),
                ),
              ],
            ),
            
            // Calendar Picker Modal
            if (showCalendarPicker)
              _buildCalendarPickerModal(context),
          ],
        ),
      ),
      bottomNavigationBar: widget.showBottomNav ? const ProfessorBottomNav(currentIndex: 3) : null,
    );
  }

  Widget _buildHeader(double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: 12,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(
              Icons.arrow_back,
              color: Color(0xFF1F2937),
              size: 24,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Schedule',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ),
          ),
          const SizedBox(width: 24), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildCalendarSection(double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Column(
        children: [
          const SizedBox(height: 8),
          // Month/Year Header
          Center(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  showCalendarPicker = true;
                });
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'May , 2025',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: Color(0xFF6B7280),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Week Calendar
          _buildWeekCalendar(),
        ],
      ),
    );
  }

  Widget _buildWeekCalendar() {
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final weekDates = [17, 18, 19, 20, 21, 22, 23];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        final isSelected = weekDates[index] == 20; // Thursday is selected
        
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedDate = DateTime(2025, 5, weekDates[index]);
            });
          },
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
                  weekDays[index],
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: isSelected ? Colors.white : const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${weekDates[index]}',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLecturesList(double screenWidth) {
    // Check if there are any live courses available
    final hasLiveCourses = lectures.isNotEmpty;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Text(
            'Live Courses',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: hasLiveCourses 
              ? ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  itemCount: lectures.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildLectureCard(lectures[index]),
                    );
                  },
                )
              : _buildNoLiveCoursesState(screenWidth),
        ),
      ],
    );
  }

  Widget _buildNoLiveCoursesState(double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Live course icon with gradient background
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF3B82F6).withOpacity(0.1),
                    const Color(0xFF1E40AF).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF3B82F6),
                        Color(0xFF1E40AF),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.video_call_outlined,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Main message
            Text(
              'No Live Courses Scheduled',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1F2937),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Subtitle message
            Text(
              'Schedule live sessions with your students\nto see them appear here',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF6B7280),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Professional action button
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 280),
              child: ElevatedButton(
                onPressed: () {
                  _showComingSoonDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: const Color(0xFF3B82F6).withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add_circle_outline,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Schedule Live Session',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Secondary action
            TextButton(
              onPressed: () {
                setState(() {
                  // Refresh or check for updates
                });
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF6B7280),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.refresh,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Refresh Schedule',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLectureCard(LectureItem lecture) {
    return GestureDetector(
      onTap: () => _showLectureDetailModal(lecture),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            // Time
            SizedBox(
              width: 50,
              child: Text(
                lecture.time,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Play Button
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFF3B82F6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 18,
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Lecture Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lecture.title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          lecture.instructor,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF9CA3AF),
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
                        size: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          lecture.timeRange,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF9CA3AF),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Notification Icon
            if (lecture.hasNotification)
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Color(0xFF3B82F6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications,
                  color: Colors.white,
                  size: 10,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showLectureDetailModal(LectureItem lecture) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final screenHeight = MediaQuery.of(context).size.height;
        final maxModalHeight = screenHeight * 0.7; // Prevent overflow
        
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: maxModalHeight,
              maxWidth: MediaQuery.of(context).size.width - 40,
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lecture.title,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Database Management',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 14,
                          color: Color(0xFF1F2937),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            lecture.instructor,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF1F2937),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.access_time_outlined,
                          size: 14,
                          color: Color(0xFF1F2937),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '75 minutes',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Description',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 6),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: maxModalHeight * 0.4, // Limit description height
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          'Prepare for a new career in the high-growth field of data analytics, no experience or degree required. Get professional training designed by Google and have the opportunity to connect with top employers. There are over 381,000 open jobs in data analytics with a median entry-level salary of £E 1,900,000 in Egypt.',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF6B7280),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF3B82F6), width: 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: Text(
                              'Close',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF3B82F6),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              // Handle set reminder
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B82F6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              elevation: 0,
                            ),
                            child: Text(
                              'Set Reminder',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showComingSoonDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Feature icon with gradient background
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF3B82F6).withOpacity(0.1),
                        const Color(0xFF1E40AF).withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Center(
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF3B82F6),
                            Color(0xFF1E40AF),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Icon(
                        Icons.schedule,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Title
                Text(
                  'Feature Coming Soon',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 12),
                
                // Description
                Text(
                  'Live session scheduling is currently in development. This powerful feature will allow you to create and manage live courses with your students.',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 24),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          'Got it',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Could add notification signup here
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          'Notify Me',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalendarPickerModal(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          showCalendarPicker = false;
        });
      },
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Calendar Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
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
                            '2020',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          Text(
                            'NOV',
                            style: GoogleFonts.inter(
                              fontSize: 20,
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
                ),
                
                // Calendar Grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Week days header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
                            .map((day) => Container(
                                  width: 32,
                                  height: 32,
                                  alignment: Alignment.center,
                                  child: Text(
                                    day,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Calendar dates
                      ...List.generate(5, (weekIndex) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(7, (dayIndex) {
                              final dayNumber = weekIndex * 7 + dayIndex + 1;
                              if (dayNumber > 31) return const SizedBox(width: 32, height: 32);
                              
                              final isSelected = dayNumber == 30;
                              
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedDate = DateTime(2020, 11, dayNumber);
                                    showCalendarPicker = false;
                                  });
                                },
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: isSelected 
                                        ? Colors.white.withOpacity(0.2)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$dayNumber',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          
          // Handle navigation based on selected tab
          if (index == 0) { // Home tab
            Navigator.of(context).pop(); // Go back to home
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF3B82F6),
        unselectedItemColor: const Color(0xFF9CA3AF),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        selectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500),
        unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w400),
        backgroundColor: Colors.white,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.home_outlined, size: 22),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.home, size: 22),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.calendar_today_outlined, size: 22),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.calendar_today, size: 22),
            ),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.book_outlined, size: 22),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.book, size: 22),
            ),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.person_outline, size: 22),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.person, size: 22),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class LectureItem {
  final String time;
  final String title;
  final String instructor;
  final String timeRange;
  final bool hasNotification;

  LectureItem({
    required this.time,
    required this.title,
    required this.instructor,
    required this.timeRange,
    required this.hasNotification,
  });
}
