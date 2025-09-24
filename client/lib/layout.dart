import 'package:client/widgets/community_home.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/theme_switch.dart';
import '../services/info.dart';
import '../screens/home_screen.dart';
import '../screens/community_home.dart'; // Ensure this is a widget, not a service
import '../screens/nutrition.dart';
import '../screens/profile_screen.dart';
import '../screens/login_screen.dart';

class Layout
    extends
        StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const Layout({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<
    Layout
  >
  createState() => _LayoutState();
}

class _LayoutState
    extends
        State<
          Layout
        > {
  int selectedIndex = 0;

  void _onDrawerItemTap(
    int index,
  ) {
    Navigator.pop(
      context,
    ); // Close drawer
    setState(
      () {
        selectedIndex = index;
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final pages = [
      const HomeScreen(), // Widget
      const CommunityHome(),
      const Nutrition(), // Widget
      const ProfileScreen(), // Widget (PascalCase)
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(
          0xFF2C3E50,
        ),
        foregroundColor: Colors.white,
        title: const Text(
          "Aarogya Sahayak",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: Builder(
          builder:
              (
                context,
              ) => IconButton(
                icon: const Icon(
                  Icons.menu,
                  color: Colors.white,
                ),
                onPressed: () => Scaffold.of(
                  context,
                ).openDrawer(),
              ),
        ),
        actions: [
          ThemeSwitch(
            isDarkMode: widget.isDarkMode,
            onToggle: widget.onThemeToggle,
          ),
          FutureBuilder<
            bool
          >(
            future: Info().isLoggedIn(),
            builder:
                (
                  context,
                  snapshot,
                ) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return snapshot.data!
                      ? const SizedBox.shrink()
                      : TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (
                                      context,
                                    ) => const login_screen(), // PascalCase
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            foregroundColor: Colors.white,
                            side: const BorderSide(
                              color: Colors.white,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                15,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        );
                },
          ),
          const SizedBox(
            width: 8,
          ), // Small spacing from edge
        ],
      ),
      drawer: CustomDrawer(
        onItemTap: _onDrawerItemTap,
      ),
      body: pages[selectedIndex], // Now all items in `pages` are widgets
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(
          context,
        ).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap:
            (
              index,
            ) {
              setState(
                () {
                  selectedIndex = index;
                },
              );
            },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.group,
            ),
            label: "Community",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.medication,
            ),
            label: "Nutrition",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
            ),
            label: "My Info",
          ),
        ],
      ),
    );
  }
}
