import 'package:flutter/material.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/theme_switch.dart';
import '../services/info.dart';
import '../screens/home_screen.dart';
import '../screens/community_home.dart';
import '../screens/nutrition.dart';
import '../screens/profile_screen.dart';
import '../screens/login_screen.dart';

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
          ),
        ],
      ),
    );
  }

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
                  ),
                ),
              ],
            ),
          );
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
}