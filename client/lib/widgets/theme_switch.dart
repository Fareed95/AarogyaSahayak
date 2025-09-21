import 'package:flutter/material.dart';

class ThemeSwitch extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onToggle;
  const ThemeSwitch({super.key, required this.isDarkMode, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isDarkMode ? Icons.dark_mode : Icons.light_mode,
        color: Colors.white, 
      ),
      onPressed: onToggle,
    );
  }
}