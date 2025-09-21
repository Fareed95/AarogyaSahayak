import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'layout.dart';
import 'screens/login_screen.dart';
import 'screens/voice_agent.dart';
import 'screens/community_home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'services/secure_storage_service.dart';
import 'services/info.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// 🔙 Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("Background message received: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Background message registration
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const HackathonApp());
}

class HackathonApp extends StatefulWidget {
  const HackathonApp({super.key});

  @override
  State<HackathonApp> createState() => _HackathonAppState();
}

class _HackathonAppState extends State<HackathonApp> {
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _initFCM();
    _setFCM();
  }

  Future<void> _setFCM() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      String? token = await messaging.getToken();
      var value = await Info().isLoggedIn();
      print('User logged in? $value');
      String? jwtToken = await SecureStorageService().getJwtToken();

      if (jwtToken != null && token != null) {
        try {
          // API endpoint
          const String apiUrl = 'https://codenebula-internal-round-25.onrender.com/api/user/';
          final Map<String, dynamic> requestBody = {'fcm_token': token};

          final response = await http.patch(
            Uri.parse(apiUrl),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': jwtToken
            },
            body: jsonEncode(requestBody),
          );

          if (response.statusCode == 200 || response.statusCode == 201) {
            final responseData = jsonDecode(response.body);
            print("✅ FCM token updated successfully: $responseData");
          } else {
            final errorData = jsonDecode(response.body);
            print("❌ Error updating FCM token: $errorData");
          }
        } catch (error) {
          print("❌ Network or other error: $error");
        }
      } else {
        print('⚠️ No JWT token or FCM token found');
      }
    } catch (e) {
      print("❌ Error in _setFCM: $e");
    }
  }

  Future<void> _initFCM() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      print('🔔 User granted permission: ${settings.authorizationStatus}');
      String? token = await messaging.getToken();
      print('📱 FCM Token: $token');
    } catch (e) {
      print("❌ Error getting FCM token: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hackathon',
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      // ✅ Fixed: Removed the unnecessary Scaffold wrapper
      home: Layout(
        isDarkMode: isDarkMode,
        onThemeToggle: () {
          setState(() {
            isDarkMode = !isDarkMode;
          });
        },
      ),
    );
  }
}