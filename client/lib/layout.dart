import 'package:client/screens/community_home.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/theme_switch.dart';
import '../services/info.dart';
import '../screens/home_screen.dart';
import '../screens/community_home.dart';
import '../screens/nutrition.dart';
import '../screens/profile_screen.dart';
import '../screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/community_home.dart';

// Add the required parameters here
class Layout extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  
  const Layout({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<Layout> createState() => _LayoutState();
}

<<<<<<< HEAD
class _LayoutState extends State<Layout> with TickerProviderStateMixin {
  int selectedIndex = 0;
  late AnimationController _fabAnimationController;
  late AnimationController _rippleAnimationController;
  late AnimationController _bounceAnimationController;
  late Animation<double> _fabAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _bounceAnimation;
  
  int _tappedIndex = -1;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _rippleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _bounceAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fabAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.elasticOut),
    );
    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleAnimationController, curve: Curves.easeOut),
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _bounceAnimationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _rippleAnimationController.dispose();
    _bounceAnimationController.dispose();
    super.dispose();
  }

  void _onDrawerItemTap(int index) {
    Navigator.pop(context);
    setState(() {
      selectedIndex = index;
    });
  }

  void _onBottomNavTap(int index) {
    // Trigger animations
    setState(() {
      _tappedIndex = index;
    });
    
    _rippleAnimationController.forward().then((_) {
      _rippleAnimationController.reset();
    });
    
    _bounceAnimationController.forward().then((_) {
      _bounceAnimationController.reverse();
    });
    
    if (index == 2) { // AI Chatbot button
      _fabAnimationController.forward().then((_) {
        _fabAnimationController.reverse();
      });
      // Add your AI Chatbot navigation logic here
      return;
    }
    
    // Handle other navigation items (adjust indices since AI chat is in middle)
    int actualIndex = index > 2 ? index - 1 : index;
    
    // Add a small delay for visual feedback before changing the page
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        selectedIndex = actualIndex;
        _tappedIndex = -1; // Reset tapped index
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    final pages = [
      const HomeScreen(),
      const CommunityApiService(),
      const Nutrition(),
      const profile_screen(),
    ];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                isDark ? const Color(0xFF14213D) : const Color(0xFF14213D).withOpacity(0.9),
                isDark ? const Color(0xFF14213D).withOpacity(0.8) : const Color(0xFF14213D).withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // AppBar content
              SafeArea(
                child: Container(
                  height: kToolbarHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      // Fixed: Wrap the IconButton with a Builder to get the correct context
                      Builder(
                        builder: (BuildContext context) {
                          return IconButton(
                            icon: const Icon(Icons.menu, color: Colors.white),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          );
                        },
                      ),
                      Expanded(
                        child: const Text(
                          "Aarogya Sahayak",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      ThemeSwitch(
                        isDarkMode: widget.isDarkMode,
                        onToggle: widget.onThemeToggle,
                      ),
                      const SizedBox(width: 8),
                      FutureBuilder<bool>(
                        future: Info().isLoggedIn(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            );
                          }
                          return snapshot.data!
                              ? const SizedBox.shrink()
                              : IconButton(
                                  icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const login_screen(),
                                      ),
                                    );
                                  },
                                );
                        },
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: CustomDrawer(onItemTap: _onDrawerItemTap),
      body: pages[selectedIndex],
      bottomNavigationBar: _buildCustomBottomNavBar(isDark),
      floatingActionButton: _buildAIChatButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildCustomBottomNavBar(bool isDark) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFE5E5E5),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Home',
            index: 0,
            isDark: isDark,
          ),
          _buildNavItem(
            icon: Icons.play_circle_outline,
            activeIcon: Icons.play_circle,
            label: 'Wellness Clips',
            index: 1,
            isDark: isDark,
          ),
          const SizedBox(width: 56), // Space for FAB
          _buildNavItem(
            icon: Icons.search,
            activeIcon: Icons.search,
            label: 'NutriScan',
            index: 3,
            isDark: isDark,
          ),
          _buildNavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profile',
            index: 4,
            isDark: isDark,
=======
class _LayoutState extends State<Layout> {
  int _currentIndex = 0;

  // Remove the local _isDarkMode state since we get it from parent
  // bool _isDarkMode = false; // REMOVE THIS LINE

  @override
  void initState() {
    super.initState();
    // Remove _loadThemePreference since we get theme from parent
    // _loadThemePreference(); // REMOVE THIS LINE
  }

  // Remove these methods since theme is now controlled by parent
  // _loadThemePreference() async {...} // REMOVE
  // _toggleTheme(bool value) async {...} // REMOVE

  List<Widget> get _screens => const [
        CommunitiesScreen(),
        PostsScreen(),
        ActivityScreen(),
        ProfileScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Icon(
                  widget.isDarkMode ? Icons.nightlight_round : Icons.wb_sunny, // Use widget.isDarkMode
                  color: widget.isDarkMode ? Colors.white : Colors.black, // Use widget.isDarkMode
                ),
                const SizedBox(width: 8),
                Switch(
                  value: widget.isDarkMode, // Use widget.isDarkMode
                  onChanged: widget.onThemeToggle, // Use the callback from parent
                  activeColor: Colors.white,
                  activeTrackColor: Colors.grey,
                  inactiveThumbColor: Colors.black,
                  inactiveTrackColor: Colors.grey[300],
                ),
              ],
            ),
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Communities',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.post_add),
            label: 'Posts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Activity',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
>>>>>>> 1548bdf8b182f49f595363a77effb8ea0c5a39de
          ),
        ],
      ),
    );
  }
<<<<<<< HEAD

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required bool isDark,
  }) {
    int actualIndex = index > 2 ? index - 1 : index;
    bool isActive = selectedIndex == actualIndex;
    bool isTapped = _tappedIndex == index;
    
    return GestureDetector(
      onTap: () => _onBottomNavTap(index),
      child: AnimatedBuilder(
        animation: Listenable.merge([_bounceAnimation, _rippleAnimation]),
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Ripple effect
                    if (isTapped)
                      AnimatedBuilder(
                        animation: _rippleAnimation,
                        builder: (context, child) {
                          return Container(
                            width: 50 * _rippleAnimation.value,
                            height: 50 * _rippleAnimation.value,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF14213D).withOpacity(
                                0.2 * (1 - _rippleAnimation.value),
                              ),
                            ),
                          );
                        },
                      ),
                    // Icon container with bounce effect
                    Transform.scale(
                      scale: isTapped ? _bounceAnimation.value : 1.0,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isActive 
                              ? const Color(0xFF14213D).withOpacity(0.1)
                              : (isTapped ? const Color(0xFF14213D).withOpacity(0.05) : Colors.transparent),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: isTapped ? [
                            BoxShadow(
                              color: const Color(0xFF14213D).withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ] : null,
                        ),
                        child: Icon(
                          isActive ? activeIcon : icon,
                          color: isActive 
                              ? const Color(0xFF14213D)
                              : (isDark ? const Color(0xFF14213D).withOpacity(0.6) : const Color(0xFF14213D).withOpacity(0.7)),
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: isTapped ? 12 : 11,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive 
                        ? const Color(0xFF14213D)
                        : (isDark ? const Color(0xFF14213D).withOpacity(0.6) : const Color(0xFF14213D).withOpacity(0.7)),
                  ),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
=======
}
// Communities Screen with Fallback
class CommunitiesScreen extends StatelessWidget {
  const CommunitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadCommunitiesWithFallback(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'API Connection Error',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // Trigger rebuild to retry
                    (context as Element).markNeedsBuild();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    _showApiSetupDialog(context);
                  },
                  child: const Text('Check API Setup'),
                ),
              ],
            ),
          );
        } else if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.group_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No communities found'),
              ],
            ),
          );
        } else {
          final communities = snapshot.data as List;
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: communities.length,
            itemBuilder: (context, index) {
              final community = communities[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    backgroundImage: community['profile_picture'] != null 
                        ? NetworkImage(community['profile_picture']) 
                        : null,
                    child: community['profile_picture'] == null 
                        ? const Icon(Icons.group, color: Colors.white) 
                        : null,
                  ),
                  title: Text(
                    community['name'] ?? 'Unknown Community',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(community['description'] ?? 'No description'),
                  trailing: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${community['total_members_count'] ?? 0}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Text('members', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Tapped on ${community['name']}'),
                      ),
                    );
                  },
                ),
              );
            },
          );
        }
      },
    );
  }

  Future<List<dynamic>> _loadCommunitiesWithFallback() async {
    try {
      return await CommunityApiService.getCommunities();
    } catch (e) {
      // If API fails, return mock data for testing
      print('⚠️ API failed, using mock data: $e');
      return CommunityApiService.getMockCommunities();
    }
  }

  void _showApiSetupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('API Setup Required'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('To fix this error, you need to:'),
            SizedBox(height: 8),
            Text('1. Update baseUrl in CommunityApiService'),
            Text('2. Set the correct frontendSecret'),
            Text('3. Ensure your API server is running'),
            Text('4. Check your JWT token is valid'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// Posts Screen with Fallback
class PostsScreen extends StatelessWidget {
  const PostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadPostsWithFallback(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    (context as Element).markNeedsBuild();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        } else if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.post_add, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No posts found'),
              ],
            ),
          );
        } else {
          final posts = snapshot.data as List;
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['title'] ?? 'Untitled Post',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        post['content'] ?? 'No content',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Chip(
                            label: Text(post['community_name'] ?? 'Unknown'),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              const Icon(Icons.thumb_up, size: 16),
                              const SizedBox(width: 4),
                              Text('${post['votes_like_count'] ?? 0}'),
                              const SizedBox(width: 16),
                              const Icon(Icons.thumb_down, size: 16),
                              const SizedBox(width: 4),
                              Text('${post['votes_dislike_count'] ?? 0}'),
                            ],
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
      },
    );
  }

  Future<List<dynamic>> _loadPostsWithFallback() async {
    try {
      return await CommunityApiService.getPosts();
    } catch (e) {
      print('⚠️ Posts API failed, using mock data: $e');
      return CommunityApiService.getMockPosts();
    }
  }
}

// Activity Screen with Fallback
class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadActivityWithFallback(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    (context as Element).markNeedsBuild();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        } else if (!snapshot.hasData) {
          return const Center(child: Text('No activity found'));
        } else {
          final activity = snapshot.data as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User Activity',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text('Email: ${activity['email'] ?? 'Unknown'}'),
                const SizedBox(height: 16),
                Text(
                  'Communities',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: (activity['communities'] as List?)?.length ?? 0,
                    itemBuilder: (context, index) {
                      final community = activity['communities'][index];
                      return Card(
                        child: ListTile(
                          title: Text(community['community_name'] ?? 'Unknown'),
                          subtitle: Text('Role: ${community['role'] ?? 'Unknown'}'),
                          trailing: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Posts: ${community['user_posts_count'] ?? 0}'),
                              Text('Likes: ${community['liked_posts_count'] ?? 0}'),
                            ],
                          ),
                        ),
                      );
                    },
>>>>>>> 1548bdf8b182f49f595363a77effb8ea0c5a39de
                  ),
                ),
              ],
            ),
          );
<<<<<<< HEAD
        },
      ),
    );
  }

  Widget _buildAIChatButton() {
    return AnimatedBuilder(
      animation: _fabAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _fabAnimation.value,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFCA311),
                  Color(0xFFE8940F),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFCA311).withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: const Color(0xFFFCA311).withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: () => _onBottomNavTap(2),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                        Positioned(
                          right: 2,
                          bottom: 2,
                          child: Text(
                            'AI',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
=======
        }
      },
    );
  }

  Future<Map<String, dynamic>> _loadActivityWithFallback() async {
    try {
      return await CommunityApiService.getUserActivity();
    } catch (e) {
      print('⚠️ Activity API failed, using mock data: $e');
      return CommunityApiService.getMockUserActivity();
    }
  }
}

// Simple Profile Screen
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Profile Screen'),
          Text('API functionality will be added here'),
        ],
      ),
    );
  }
>>>>>>> 1548bdf8b182f49f595363a77effb8ea0c5a39de
}