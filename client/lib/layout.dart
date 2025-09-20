import 'package:flutter/material.dart';
import '../widgets/custom_drawer.dart';
import '../screens/home_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/orders_screen.dart';
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
<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< HEAD
      HomeScreen(),
      cart_screen(),
      const order_screen(),
      const profile_screen(),
=======
      const HomeDashboardScreen(), 
      const CommunityScreen(), 
      const AIHealthChatbotScreen(), 
      const NutritionScanScreen(), 
>>>>>>> f5951477d6de4c2a90880f5404c0d12bb62bf1c3
=======
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
      home_screen(),
      cart_screen(),
      const order_screen(),
      const profile_screen(),
<<<<<<< Updated upstream
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Hackathon"),
        centerTitle: true,
        actions: [
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
              icon: Icon(Icons.shopping_cart), label: "Cart"),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long), label: "Orders"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "My Info"),
        ],
      ),
    );
  }
}
