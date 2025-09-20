import 'screens/login_screen.dart';
import 'screens/voice_agent.dart';
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'layout.dart';
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
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    var value = await Info().isLoggedIn();
    print('User logged in? $value');
    String? jwtToken = await SecureStorageService().getJwtToken();

    if (jwtToken != null) {
      try {
        const String apiUrl = 'https://flutter-demo-c7cg.onrender.com/api/user/';
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
          print("FCM token updated successfully: $responseData");
        } else {
          final errorData = jsonDecode(response.body);
          print("Error updating FCM token: $errorData");
        }
      } catch (error) {
        print("Network or other error: $error");
      }
    } else {
      print('No JWT token found');
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
      print('FCM Token: $token');
    } catch (e) {
      print("❌ Error getting FCM token: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'hackathon',
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      home: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: Layout(
                isDarkMode: isDarkMode,
                onThemeToggle: () {
                  setState(() {
                    isDarkMode = !isDarkMode;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CartScreen(),
                    ),
                  );
                },
                child: const Text("Open Voice Assistant"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

