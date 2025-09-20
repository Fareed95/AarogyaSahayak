import 'package:client/screens/community.dart';
import 'package:client/screens/login_screen.dart';
import 'package:client/screens/nutrition.dart';
import 'package:client/services/info.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_drawer.dart';
import '../screens/home_screen.dart';

import '../screens/profile_screen.dart';
import '../widgets/theme_switch.dart';
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
    final pages = [
      HomeScreen(),
<<<<<<< HEAD
      cart_screen(),
      const order_screen(),
      const profile_screen(),
=======
      community(),
      nutrition(),
      profile_screen(),
>>>>>>> c212cdb29c129226f411376acf4104ef8eaac5cc
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Hackathon"),
        centerTitle: true,
        actions: [
          FutureBuilder(future: Info().isLoggedIn(), builder: (context,snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            return snapshot.data!
                ? Center()
                : TextButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => login_screen(),));
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                // keeps it small
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      15), // optional rounded corners
                ),
              ),
              child: const Text(
                'Login',
                style: TextStyle(fontSize: 14), // small text
              ),
            );
          }),
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
          BottomNavigationBarItem(
              icon: Icon(Icons.group), label: "community"),
          BottomNavigationBarItem(
              icon: Icon(Icons.medication), label: "nutrition"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "My Info"),
        ],
      ),
    );
  }
}
