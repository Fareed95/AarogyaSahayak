import 'package:flutter/material.dart';
import '../screens/Doctor_screen.dart';
import '../screens/Medical_screen.dart';

class CustomDrawer extends StatelessWidget {
  final Function(int) onItemTap;
  
  const CustomDrawer({super.key, required this.onItemTap});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Drawer(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF14213D),
                  const Color(0xFF14213D).withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.health_and_safety,
                  color: Color(0xFFFCA311),
                  size: 40,
                ),
                SizedBox(height: 12),
                Text(
                  'Aarogya Sahayak',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Your Health Companion',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFFCA311),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _buildDrawerItem(
            context, 
            Icons.home_outlined, 
            Icons.home, 
            "Home", 
            0, 
            isDark
          ),
           _buildDrawerItem(
            context, 
            Icons.restaurant_outlined, 
            Icons.person_outline, 
            "AI Chatbot", 
            1, 
            isDark
          ),
          _buildDrawerItem(
            context, 
            Icons.people_outline, 
            Icons.people, 
            "Community", 
            2, 
            isDark
          ),
          _buildDrawerItem(
            context, 
            Icons.restaurant_outlined, 
            Icons.restaurant, 
            "Nutrition", 
            3, 
            isDark
          ),
          _buildDrawerItem(
            context, 
            Icons.person_outline, 
            Icons.person, 
            "My Info", 
            4, 
            isDark
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Divider(),
          ),
          _buildSpecialDrawerItem(
            context, 
            Icons.medical_services_outlined, 
            Icons.medical_services, 
            "Doctor", 
            isDark
          ),
          _buildSpecialDrawerItem(
            context, 
            Icons.local_pharmacy_outlined, 
            Icons.local_pharmacy, 
            "Medical Store", 
            isDark
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData outlinedIcon,
    IconData filledIcon,
    String title, 
    int index, 
    bool isDark
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          outlinedIcon,
          color: isDark ? Colors.white70 : const Color(0xFF14213D).withOpacity(0.8),
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF14213D),
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: () {
          onItemTap(index);
        },
        hoverColor: const Color(0xFF14213D).withOpacity(0.1),
        splashColor: const Color(0xFF14213D).withOpacity(0.2),
      ),
    );
  }

  Widget _buildSpecialDrawerItem(
    BuildContext context,
    IconData outlinedIcon,
    IconData filledIcon,
    String title, 
    bool isDark
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFCA311).withOpacity(0.1),
            const Color(0xFFFCA311).withOpacity(0.05),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: ListTile(
        leading: Icon(
          outlinedIcon,
          color: const Color(0xFFFCA311),
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF14213D),
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: const Color(0xFFFCA311),
          size: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: () {
          if (title == "Doctor") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Doctor_screen()),
            );
          } else if (title == "Medical Store") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Medical_screen()),
            );
          }
        },
        hoverColor: const Color(0xFFFCA311).withOpacity(0.1),
        splashColor: const Color(0xFFFCA311).withOpacity(0.2),
      ),
    );
  }
}