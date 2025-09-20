import 'package:flutter/material.dart';
import '../splash_screen/splash_screen.dart';
import '../screens/home_screen.dart';
import '../screens/nutrition_scan/nutrition_scan.dart';
import '../screens/login_screen.dart';
import '../screens/ai_chatbot/ai_health_chatbot.dart';
//import '../screens/vitals_tracking/vitals_tracking.dart';

class AppRoutes {
  static const String initial = '/';
  static const String splash = '/splash-screen';
  static const String homeDashboard = '/home-dashboard';
  static const String nutritionScan = '/nutrition-scan';
  static const String login = '/login-screen';
  static const String aiHealthChatbot = '/ai-health-chatbot';
  static const String vitalsTracking = '/vitals-tracking';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splash: (context) => const SplashScreen(),
    homeDashboard: (context) => const HomeDashboard(),
    nutritionScan: (context) => const NutritionScan(),
    login: (context) => const LoginScreen(),
    aiHealthChatbot: (context) => const AiHealthChatbot(),
    vitalsTracking: (context) => const VitalsTracking(),
  };
}
