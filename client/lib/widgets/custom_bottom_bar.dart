import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Custom Bottom Navigation Bar for healthcare application with accessible design
class CustomBottomBar extends StatefulWidget {
  /// Current selected index
  final int currentIndex;

  /// Callback when a tab is tapped
  final ValueChanged<int> onTap;

  /// Whether to show labels
  final bool showLabels;

  /// Custom background color
  final Color? backgroundColor;

  /// Custom selected item color
  final Color? selectedItemColor;

  /// Custom unselected item color
  final Color? unselectedItemColor;

  /// Whether to show elevation
  final bool showElevation;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.showLabels = true,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.showElevation = true,
  });

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _animations;

  // Navigation items with healthcare-focused icons and routes
  final List<BottomNavItem> _navItems = [
    BottomNavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      label: 'Dashboard',
      route: '/home-dashboard',
    ),
    BottomNavItem(
      icon: Icons.favorite_outline_rounded,
      activeIcon: Icons.favorite_rounded,
      label: 'Vitals',
      route: '/vitals-tracking',
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

    // Animate the initially selected item
    if (widget.currentIndex < _animationControllers.length) {
      _animationControllers[widget.currentIndex].forward();
    }
  }

  @override
  void didUpdateWidget(CustomBottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _updateAnimations();
    }
  }

  void _updateAnimations() {
    for (int i = 0; i < _animationControllers.length; i++) {
      if (i == widget.currentIndex) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? colorScheme.surface,
        boxShadow: widget.showElevation
            ? [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ]
            : null,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (index) {
              return _buildNavItem(
                context,
                _navItems[index],
                index,
                widget.currentIndex == index,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final Color effectiveSelectedColor =
        widget.selectedItemColor ?? colorScheme.primary;
    final Color effectiveUnselectedColor = widget.unselectedItemColor ??
        colorScheme.onSurface.withValues(alpha: 0.6);

    return Expanded(
      child: AnimatedBuilder(
        animation: _animations[index],
        builder: (context, child) {
          return Transform.scale(
            scale: _animations[index].value,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _handleTap(context, index, item.route),
                borderRadius: BorderRadius.circular(16),
                splashColor: effectiveSelectedColor.withValues(alpha: 0.1),
                highlightColor: effectiveSelectedColor.withValues(alpha: 0.05),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon with indicator
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: isSelected
                            ? BoxDecoration(
                                color: effectiveSelectedColor.withValues(
                                    alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              )
                            : null,
                        child: Icon(
                          isSelected ? item.activeIcon : item.icon,
                          size: 24,
                          color: isSelected
                              ? effectiveSelectedColor
                              : effectiveUnselectedColor,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Label
                      if (widget.showLabels)
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: theme.textTheme.labelSmall!.copyWith(
                            color: isSelected
                                ? effectiveSelectedColor
                                : effectiveUnselectedColor,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                          child: Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                      // Active indicator dot
                      if (isSelected)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: effectiveSelectedColor,
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

  void _handleTap(BuildContext context, int index, String route) {
    // Provide haptic feedback for better accessibility
    HapticFeedback.lightImpact();

    // Call the onTap callback
    widget.onTap(index);

    // Navigate to the selected route if it's different from current
    if (index != widget.currentIndex) {
      Navigator.pushReplacementNamed(context, route);
    }
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

/// Extension to get current route index for external use
extension CustomBottomBarExtension on CustomBottomBar {
  static int getIndexForRoute(String route) {
    const routeIndexMap = {
      '/home-dashboard': 0,
      '/vitals-tracking': 1,
      '/ai-health-chatbot': 2,
      '/nutrition-scan': 3,
    };
    return routeIndexMap[route] ?? 0;
  }

  static String getRouteForIndex(int index) {
    const indexRouteMap = {
      0: '/home-dashboard',
      1: '/vitals-tracking',
      2: '/ai-health-chatbot',
      3: '/nutrition-scan',
    };
    return indexRouteMap[index] ?? '/home-dashboard';
  }
}
