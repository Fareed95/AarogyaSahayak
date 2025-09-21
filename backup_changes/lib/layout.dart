import 'package:client/screens/community_home.dart';
import 'package:client/screens/login_screen.dart';
import 'package:client/screens/nutrition.dart';
import 'package:client/services/info.dart';
import 'package:client/screens/voice_agent.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_drawer.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';
import '../widgets/theme_switch.dart';
import 'screens/nutrition.dart';

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

class _LayoutState extends State<Layout> {
  int selectedIndex = 0;
  void _onDrawerItemTap(int index) {
    Navigator.pop(context); // close drawer
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use CommunityHomeScreen (the widget), not CommunityApiService (the service)
    final List<Widget> pages = [
      HomeScreen(),
      CommunityApiService(), // This is the correct widget
      NutritionApp(), 
      ProfileScreen(),
    ];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hackathon"),
        centerTitle: true,
        actions: [
          FutureBuilder<bool>(
            future: Info().isLoggedIn(), 
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              return snapshot.data!
                  ? Container()
                  : TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 14),
                      ),
                    );
            },
          ),
          ThemeSwitch(
            isDarkMode: widget.isDarkMode,
            onToggle: widget.onThemeToggle,
          ),
        ],
      ),
      drawer: CustomDrawer(onItemTap: _onDrawerItemTap),
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: "Community"),
          BottomNavigationBarItem(icon: Icon(Icons.medication), label: "Nutrition"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "My Info"),
        ],
      ),
    );
  }
}