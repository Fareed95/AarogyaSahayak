import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final Function(int) onItemTap;
  const CustomDrawer({super.key, required this.onItemTap});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF153D8A)),
            child: Text(
              'hackathon',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          _buildDrawerItem(Icons.home, "Home", 0),
          _buildDrawerItem(Icons.shopping_cart, "Cart", 1),
          _buildDrawerItem(Icons.receipt_long, "Orders", 2),
          _buildDrawerItem(Icons.person, "My Info", 3),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () => onItemTap(index), // ✅ this triggers Layout's method
    );
  }
}
