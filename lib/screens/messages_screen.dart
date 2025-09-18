import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Search Bar
            _buildSearchBar(screenWidth),

            // Tab Bar
            _buildTabBar(),

            // Tab Bar View
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildCourseChat(), _buildDirectMessages()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          const Spacer(),
          Text(
            'Messages',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          const Spacer(),
          const SizedBox(width: 40), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildSearchBar(double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search here..',
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF9CA3AF),
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: Color(0xFF9CA3AF),
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF3A4FDE),
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF6B7280),
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'Course Chat'),
          Tab(text: 'Direct Messages'),
        ],
      ),
    );
  }

  Widget _buildCourseChat() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 6,
      itemBuilder: (context, index) {
        final doctors = [
          {
            'name': 'Dr. Mohamed',
            'message': 'Hello Muhamed , what is up?',
            'time': '09:18',
            'avatar': 'assets/images/doctor1.png',
            'hasUnread': index == 0,
          },
          {
            'name': 'Dr. Michel',
            'message': 'Hello Muhamed , what is up?',
            'time': '09:18',
            'avatar': 'assets/images/doctor2.png',
            'hasUnread': false,
          },
          {
            'name': 'Dr. Hani Fares',
            'message': 'Hello Muhamed , what is up?',
            'time': '09:18',
            'avatar': 'assets/images/doctor3.png',
            'hasUnread': false,
          },
          {
            'name': 'Dr. Karim Ahmed',
            'message': 'Hello Muhamed , what is up?',
            'time': '09:18',
            'avatar': 'assets/images/doctor4.png',
            'hasUnread': false,
          },
          {
            'name': 'Dr. Weal Saber',
            'message': 'Hello Muhamed , what is up?',
            'time': '09:18',
            'avatar': 'assets/images/doctor5.png',
            'hasUnread': false,
          },
          {
            'name': 'Dr. Ramy Abbas',
            'message': 'Hello Muhamed , what is up?',
            'time': '09:18',
            'avatar': 'assets/images/doctor6.png',
            'hasUnread': false,
          },
        ];

        final doctor = doctors[index % doctors.length];
        return _buildMessageItem(
          name: doctor['name'] as String,
          message: doctor['message'] as String,
          time: doctor['time'] as String,
          avatarPath: doctor['avatar'] as String,
          hasUnread: doctor['hasUnread'] as bool,
        );
      },
    );
  }

  Widget _buildDirectMessages() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 6,
      itemBuilder: (context, index) {
        final doctors = [
          {
            'name': 'Dr. Mohamed',
            'message': 'Hello Muhamed , what is up?',
            'time': '09:18',
            'avatar': 'assets/images/doctor1.png',
            'hasUnread': index == 0,
          },
          {
            'name': 'Dr. Michel',
            'message': 'Hello Muhamed , what is up?',
            'time': '09:18',
            'avatar': 'assets/images/doctor2.png',
            'hasUnread': false,
          },
          {
            'name': 'Dr. Hani Fares',
            'message': 'Hello Muhamed , what is up?',
            'time': '09:18',
            'avatar': 'assets/images/doctor3.png',
            'hasUnread': false,
          },
          {
            'name': 'Dr. Karim Ahmed',
            'message': 'Hello Muhamed , what is up?',
            'time': '09:18',
            'avatar': 'assets/images/doctor4.png',
            'hasUnread': false,
          },
          {
            'name': 'Dr. Weal Saber',
            'message': 'Hello Muhamed , what is up?',
            'time': '09:18',
            'avatar': 'assets/images/doctor5.png',
            'hasUnread': false,
          },
          {
            'name': 'Dr. Ramy Abbas',
            'message': 'Hello Muhamed , what is up?',
            'time': '09:18',
            'avatar': 'assets/images/doctor6.png',
            'hasUnread': false,
          },
        ];

        final doctor = doctors[index % doctors.length];
        return _buildMessageItem(
          name: doctor['name'] as String,
          message: doctor['message'] as String,
          time: doctor['time'] as String,
          avatarPath: doctor['avatar'] as String,
          hasUnread: doctor['hasUnread'] as bool,
        );
      },
    );
  }

  Widget _buildMessageItem({
    required String name,
    required String message,
    required String time,
    required String avatarPath,
    required bool hasUnread,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ChatScreen(doctorName: name, avatarPath: avatarPath),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: animation.drive(
                      Tween(begin: const Offset(1.0, 0.0), end: Offset.zero),
                    ),
                    child: child,
                  );
                },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: const Color(0xFFF3F4F6),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  avatarPath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3A4FDE), Color(0xFF1B52E8)],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          name.split(' ').map((e) => e[0]).take(2).join(),
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Message Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6B7280),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Time and Unread Indicator
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
                if (hasUnread) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3A4FDE),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
