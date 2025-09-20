import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

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
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _animations;

  final List<BottomNavItem> _navItems = [
    BottomNavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      label: 'Dashboard',
      route: '/home-dashboard',
    ),
    BottomNavItem(
      icon: Icons.people_outline_rounded,
      activeIcon: Icons.people_rounded,
      label: 'Community',
      route: '/community',
    ),
    BottomNavItem(
      icon: Icons.chat_bubble_outline_rounded,
      activeIcon: Icons.chat_bubble_rounded,
      label: 'AI Chat',
      route: '/ai-health-chatbot',
    ),
    BottomNavItem(
      icon: Icons.camera_alt_outlined,
      activeIcon: Icons.camera_alt_rounded,
      label: 'Nutrition',
      route: '/nutrition-scan',
    ),
  ];

  // Color palette
  static const Color primaryColor = Color(0xFF14213D);
  static const Color accentColor = Color(0xFFFCA311);
  static const Color neutralLight = Color(0xFFE5E5E5);
  static const Color neutralWhite = Color(0xFFFFFFFF);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationControllers = List.generate(
      _navItems.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );

    _animations = _animationControllers.map((controller) {
      return Tween<double>(begin: 0.95, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    if (selectedIndex < _animationControllers.length) {
      _animationControllers[selectedIndex].forward();
    }
  }

  void _updateAnimations() {
    for (int i = 0; i < _animationControllers.length; i++) {
      if (i == selectedIndex) {
        _animationControllers[i].forward();
      } else {
        _animationControllers[i].reverse();
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onDrawerItemTap(int index) {
    Navigator.pop(context);
    setState(() {
      selectedIndex = index;
    });
    _updateAnimations();
  }

  void _onBottomNavTap(int index) {
    setState(() {
      selectedIndex = index;
    });
    _updateAnimations();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeDashboardScreen(), 
      const CommunityScreen(), 
      const AIHealthChatbotScreen(), 
      const NutritionScanScreen(), 
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("HealthCare Assistant"),
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: primaryColor,
          statusBarIconBrightness: Brightness.light,
        ),
        actions: [
          
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onThemeToggle,
          ),
          const SizedBox(width: 8),
        ],
      ),
     
      body: pages[selectedIndex],
      bottomNavigationBar: _buildCustomBottomBar(context),
    );
  }

  Widget _buildCustomBottomBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 2.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (index) {
              return _buildNavItem(
                context,
                _navItems[index],
                index,
                selectedIndex == index,
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    BottomNavItem item,
    int index,
    bool isSelected,
  ) {
    final Color selectedColor = accentColor;
    final Color unselectedColor = Colors.grey.shade600;

    return Expanded(
      child: AnimatedBuilder(
        animation: _animations[index],
        builder: (context, child) {
          return Transform.scale(
            scale: _animations[index].value,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _handleNavTap(context, index),
                borderRadius: BorderRadius.circular(16),
                splashColor: selectedColor.withOpacity(0.1),
                highlightColor: selectedColor.withOpacity(0.05),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 1.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon container with background when selected
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(10),
                        decoration: isSelected
                            ? BoxDecoration(
                                color: selectedColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selectedColor.withOpacity(0.3),
                                  width: 1,
                                ),
                              )
                            : null,
                        child: Icon(
                          isSelected ? item.activeIcon : item.icon,
                          size: 24,
                          color: isSelected ? selectedColor : unselectedColor,
                        ),
                      ),

                      SizedBox(height: 0.5.h),

                      // Label with animation
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: isSelected ? selectedColor : unselectedColor,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                        child: Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Active indicator dot
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(top: 2),
                        width: isSelected ? 6 : 0,
                        height: isSelected ? 6 : 0,
                        decoration: BoxDecoration(
                          color: selectedColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleNavTap(BuildContext context, int index) {
    // Provide haptic feedback
    HapticFeedback.lightImpact();
    
    // Update selected index
    _onBottomNavTap(index);
    
    // Show feedback for navigation
    final itemName = _navItems[index].label;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Switched to $itemName'),
        duration: const Duration(milliseconds: 800),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

/// Data class for bottom navigation items
class BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  const BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}

/// Placeholder screens - Replace with your actual implementations
class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8F9FA), Color(0xFFE8F4FD)],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.dashboard_rounded,
              size: 64,
              color: Color(0xFF14213D),
            ),
            SizedBox(height: 16),
            Text(
              'Healthcare Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF14213D),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your health insights at a glance',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8F9FA), Color(0xFFFFF3E0)],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_rounded,
              size: 64,
              color: Color(0xFFFCA311),
            ),
            SizedBox(height: 16),
            Text(
              'Health Community',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF14213D),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Connect with others on their health journey',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AIHealthChatbotScreen extends StatelessWidget {
  const AIHealthChatbotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8F9FA), Color(0xFFF3E5F5)],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_rounded,
              size: 64,
              color: Color(0xFF6C5CE7),
            ),
            SizedBox(height: 16),
            Text(
              'AI Health Assistant',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF14213D),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Get instant answers to your health questions',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NutritionScanScreen extends StatelessWidget {
  const NutritionScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8F9FA), Color(0xFFE8F5E8)],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_rounded,
              size: 64,
              color: Color(0xFF00B894),
            ),
            SizedBox(height: 16),
            Text(
              'Nutrition Scanner',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF14213D),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Scan food to analyze nutritional content',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}