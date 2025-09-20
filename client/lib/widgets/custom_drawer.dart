import 'package:flutter/material.dart';
import '../screens/Doctor_screen.dart';
import '../screens/Medical_screen.dart';

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
          _buildDrawerItem(Icons.group, "Community", 1),
          _buildDrawerItem(Icons.medication, "nutrition", 2),
          _buildDrawerItem(Icons.person, "My Info", 3),
          _buildDrawerItem(Icons.medical_services, "Doctor", 4, context),
          _buildDrawerItem(Icons.local_pharmacy, "Medical Store", 5, context),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index, [BuildContext? context]) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        if (title == "Doctor" && context != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Doctor_screen()),
          );
        } else if (title == "Medical Store" && context != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Medical_screen()),
          );
        } else {
          onItemTap(index); // fallback for other items
        }
      },
    );
  }
}
