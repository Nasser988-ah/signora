import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/lecture.dart';

class LiveLecturesScreen extends StatefulWidget {
  const LiveLecturesScreen({super.key});

  @override
  State<LiveLecturesScreen> createState() => _LiveLecturesScreenState();
}

class _LiveLecturesScreenState extends State<LiveLecturesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  // Sample lecture data matching the design
  final List<Lecture> upcomingLectures = [
    Lecture(
      id: '1',
      title: 'Database system',
      subtitle: '',
      instructor: 'Dr. Ahmed Hassan',
      startTime: '09:00 AM',
      endTime: '10:30 AM',
      duration: 90,
      description: 'Database Management Systems fundamentals',
      hasNotification: false,
    ),
    Lecture(
      id: '2',
      title: 'UI UX',
      subtitle: '',
      instructor: 'Dr. Ahmed Hassan',
      startTime: '09:00 AM',
      endTime: '10:30 AM',
      duration: 90,
      description: 'User Interface and User Experience Design',
      hasNotification: false,
    ),
    Lecture(
      id: '3',
      title: 'Data Science',
      subtitle: '',
      instructor: 'Dr. Ahmed Hassan',
      startTime: '09:00 AM',
      endTime: '10:30 AM',
      duration: 90,
      description: 'Introduction to Data Science and Analytics',
      hasNotification: false,
    ),
    Lecture(
      id: '4',
      title: 'Database system',
      subtitle: '',
      instructor: 'Dr. Ahmed Hassan',
      startTime: '08:00 AM',
      endTime: '10:30 AM',
      duration: 150,
      description: 'Advanced Database Management Systems',
      hasNotification: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(screenWidth),

            // Search Bar
            _buildSearchBar(screenWidth),

            // Tab Bar
            _buildTabBar(screenWidth),

            // Content
            Expanded(child: _buildTabContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: 16,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Color(0xFF1F2937),
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Live Lectures',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: 8,
      ),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search here..',
            hintStyle: GoogleFonts.inter(
              color: const Color(0xFF9CA3AF),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: Color(0xFF9CA3AF),
              size: 18,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: 16,
      ),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(24),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: const Color(0xFF3A4FDE),
            borderRadius: BorderRadius.circular(24),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF6B7280),
          labelStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Live Now'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildUpcomingLectures(),
        _buildLiveNowLectures(),
        _buildCompletedLectures(),
      ],
    );
  }

  Widget _buildUpcomingLectures() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.05,
        vertical: 16,
      ),
      itemCount: upcomingLectures.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildLectureCard(upcomingLectures[index]),
        );
      },
    );
  }

  Widget _buildLiveNowLectures() {
    return const Center(
      child: Text(
        'No live lectures at the moment',
        style: TextStyle(color: Color(0xFF6B7280), fontSize: 16),
      ),
    );
  }

  Widget _buildCompletedLectures() {
    return const Center(
      child: Text(
        'No completed lectures',
        style: TextStyle(color: Color(0xFF6B7280), fontSize: 16),
      ),
    );
  }

  Widget _buildLectureCard(Lecture lecture) {
    return Container(
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
          // Play button
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF3A4FDE),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.play_arrow, color: Colors.white, size: 24),
          ),

          const SizedBox(width: 16),

          // Lecture details
          Expanded(
            child: Column(
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
            ),
          ),

          // Reminder button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF3A4FDE), width: 1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Reminder',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF3A4FDE),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
