import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final ScrollController _scrollController = ScrollController();
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Questions', 'Answered', 'Trending'];

  // Color palette
  static const Color primaryColor = Color(0xFF14213D);
  static const Color accentColor = Color(0xFFFCA311);
  static const Color neutralLight = Color(0xFFE5E5E5);
  static const Color neutralWhite = Color(0xFFFFFFFF);
  static const Color neutralBlack = Color(0xFF000000);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Mock community data
  List<CommunityThread> get _threads => [
    CommunityThread(
      id: '1',
      title: 'Blood pressure readings seem high lately',
      content: 'I\'ve been monitoring my BP and it\'s consistently around 140/90. Should I be concerned? I\'m 45 years old.',
      author: 'Sarah Johnson',
      authorImage: 'https://images.pexels.com/photos/1043471/pexels-photo-1043471.jpeg?auto=compress&cs=tinysrgb&w=400',
      timeAgo: '2 hours ago',
      category: 'Cardiology',
      likes: 12,
      replies: 8,
      isAnswered: true,
      answeredBy: 'Dr. Michael Chen',
      answeredByTitle: 'Cardiologist',
      trending: true,
    ),
    CommunityThread(
      id: '2',
      title: 'Best exercises for lower back pain?',
      content: 'I work from home and have been experiencing lower back pain. What are some effective exercises I can do?',
      author: 'Alex Kumar',
      authorImage: 'https://images.pexels.com/photos/1040880/pexels-photo-1040880.jpeg?auto=compress&cs=tinysrgb&w=400',
      timeAgo: '4 hours ago',
      category: 'Physiotherapy',
      likes: 25,
      replies: 15,
      isAnswered: true,
      answeredBy: 'Dr. Lisa Rodriguez',
      answeredByTitle: 'Physiotherapist',
      trending: false,
    ),
    CommunityThread(
      id: '3',
      title: 'Sleep quality issues after COVID',
      content: 'It\'s been 3 months since I recovered from COVID, but my sleep quality hasn\'t improved. Any suggestions?',
      author: 'Maria Santos',
      authorImage: 'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg?auto=compress&cs=tinysrgb&w=400',
      timeAgo: '6 hours ago',
      category: 'General Medicine',
      likes: 18,
      replies: 12,
      isAnswered: false,
      trending: true,
    ),
    CommunityThread(
      id: '4',
      title: 'Healthy meal prep ideas for diabetes',
      content: 'Recently diagnosed with type 2 diabetes. Looking for practical meal prep ideas that are diabetic-friendly.',
      author: 'Robert Kim',
      authorImage: 'https://images.pexels.com/photos/1040881/pexels-photo-1040881.jpeg?auto=compress&cs=tinysrgb&w=400',
      timeAgo: '8 hours ago',
      category: 'Nutrition',
      likes: 32,
      replies: 20,
      isAnswered: true,
      answeredBy: 'Dr. Emma Thompson',
      answeredByTitle: 'Nutritionist',
      trending: false,
    ),
    CommunityThread(
      id: '5',
      title: 'Managing anxiety without medication',
      content: 'Looking for natural ways to manage anxiety. What techniques have worked for others?',
      author: 'Jennifer Lee',
      authorImage: 'https://images.pexels.com/photos/1043473/pexels-photo-1043473.jpeg?auto=compress&cs=tinysrgb&w=400',
      timeAgo: '12 hours ago',
      category: 'Mental Health',
      likes: 45,
      replies: 28,
      isAnswered: true,
      answeredBy: 'Dr. James Wilson',
      answeredByTitle: 'Psychologist',
      trending: true,
    ),
  ];

  List<CommunityThread> get _filteredThreads {
    switch (_selectedFilter) {
      case 'Questions':
        return _threads.where((thread) => !thread.isAnswered).toList();
      case 'Answered':
        return _threads.where((thread) => thread.isAnswered).toList();
      case 'Trending':
        return _threads.where((thread) => thread.trending).toList();
      default:
        return _threads;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                _buildHeader(),
                _buildFilterTabs(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _handleRefresh,
                    color: primaryColor,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      itemCount: _filteredThreads.length + 1,
                      itemBuilder: (context, index) {
                        if (index == _filteredThreads.length) {
                          return SizedBox(height: 10.h);
                        }
                        return _buildThreadCard(_filteredThreads[index]);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor,
            primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Health Community',
                      style: TextStyle(
                        color: neutralWhite,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Connect, share, and learn together',
                      style: TextStyle(
                        color: neutralWhite.withOpacity(0.8),
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.people_rounded,
                  color: accentColor,
                  size: 30,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          _buildStatsRow(),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatItem('Active Users', '2.4K', Icons.people)),
        Expanded(child: _buildStatItem('Questions', '1.8K', Icons.help_outline)),
        Expanded(child: _buildStatItem('Experts', '150+', Icons.verified)),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(3.w),
      margin: EdgeInsets.symmetric(horizontal: 1.w),
      decoration: BoxDecoration(
        color: neutralWhite.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: accentColor, size: 20),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: TextStyle(
              color: neutralWhite,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: neutralWhite.withOpacity(0.8),
              fontSize: 9.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      margin: EdgeInsets.all(4.w),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.map((filter) => _buildFilterTab(filter)).toList(),
        ),
      ),
    );
  }

  Widget _buildFilterTab(String filter) {
    final isSelected = _selectedFilter == filter;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _selectedFilter = filter);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        margin: EdgeInsets.only(right: 2.w),
        decoration: BoxDecoration(
          color: isSelected ? accentColor : neutralWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? accentColor : neutralLight,
            width: 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: accentColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Text(
          filter,
          style: TextStyle(
            color: isSelected ? neutralWhite : neutralBlack.withOpacity(0.7),
            fontSize: 12.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildThreadCard(CommunityThread thread) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: neutralWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thread header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(thread.authorImage),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              thread.author,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: neutralBlack,
                              ),
                            ),
                          ),
                          if (thread.trending)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE17055).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.trending_up,
                                    size: 12,
                                    color: const Color(0xFFE17055),
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    'Trending',
                                    style: TextStyle(
                                      fontSize: 8.sp,
                                      color: const Color(0xFFE17055),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      Text(
                        thread.timeAgo,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: neutralBlack.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(thread.category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    thread.category,
                    style: TextStyle(
                      fontSize: 9.sp,
                      color: _getCategoryColor(thread.category),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Thread content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  thread.title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  thread.content,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: neutralBlack.withOpacity(0.7),
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Answered indicator
          if (thread.isAnswered)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Answered by ${thread.answeredBy}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade700,
                          ),
                        ),
                        Text(
                          thread.answeredByTitle ?? '',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.green.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.verified,
                    color: Colors.green.shade600,
                    size: 16,
                  ),
                ],
              ),
            ),

          // Thread stats and actions
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                _buildActionButton(
                  Icons.thumb_up_outlined,
                  '${thread.likes}',
                  () => _handleLike(thread.id),
                ),
                SizedBox(width: 4.w),
                _buildActionButton(
                  Icons.chat_bubble_outline,
                  '${thread.replies}',
                  () => _handleReply(thread.id),
                ),
                const Spacer(),
                _buildActionButton(
                  Icons.share_outlined,
                  'Share',
                  () => _handleShare(thread.id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: neutralBlack.withOpacity(0.6),
          ),
          SizedBox(width: 1.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: neutralBlack.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _handleCreateThread,
      backgroundColor: accentColor,
      foregroundColor: neutralWhite,
      label: const Text('Ask Question'),
      icon: const Icon(Icons.add),
      elevation: 8,
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'cardiology':
        return const Color(0xFFE17055);
      case 'physiotherapy':
        return const Color(0xFF00B894);
      case 'general medicine':
        return const Color(0xFF0984E3);
      case 'nutrition':
        return const Color(0xFF6C5CE7);
      case 'mental health':
        return const Color(0xFFFD79A8);
      default:
        return primaryColor;
    }
  }

  // Event handlers
  void _handleLike(String threadId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Thread liked!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _handleReply(String threadId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opening thread details...'),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _handleShare(String threadId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Share options opened'),
        backgroundColor: accentColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _handleCreateThread() {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opening question composer...'),
        backgroundColor: accentColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(seconds: 2));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.refresh, color: Colors.white),
            SizedBox(width: 8),
            Text('Community updated'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// Data model for community threads
class CommunityThread {
  final String id;
  final String title;
  final String content;
  final String author;
  final String authorImage;
  final String timeAgo;
  final String category;
  final int likes;
  final int replies;
  final bool isAnswered;
  final String? answeredBy;
  final String? answeredByTitle;
  final bool trending;

  CommunityThread({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.authorImage,
    required this.timeAgo,
    required this.category,
    required this.likes,
    required this.replies,
    required this.isAnswered,
    this.answeredBy,
    this.answeredByTitle,
    required this.trending,
  });
}