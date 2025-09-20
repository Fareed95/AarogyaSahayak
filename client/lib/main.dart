import 'package:client/component/qr_scanner_widget.dart';

import 'screens/Doctor_screen.dart';
import 'screens/Medical_screen.dart';
import 'screens/login_screen.dart';
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
  print(" Background message received: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Background message registration
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const hackathonApp());
}

class hackathonApp extends StatefulWidget {
  const hackathonApp({super.key});

  @override
  State<hackathonApp> createState() => _hackathonAppState();
}

class _hackathonAppState extends State<hackathonApp> {
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _initFCM();
    setFMC();
  }
  Future<void> setFMC() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    var value = await Info().isLoggedIn();
    print('value ${value}');
    String? jwtToken = await SecureStorageService().getJwtToken();
    if (jwtToken != null) {
      try {
        // API endpoint
        const String apiUrl = 'https://flutter-demo-c7cg.onrender.com/api/user/';

        // Prepare the request body
        final Map<String, dynamic> requestBody = {
          'fcm_token':token
        };

        // Make POST request
        final response = await http.patch(
          Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization':jwtToken
          },
          body: jsonEncode(requestBody),
        );

        // Handle response
        if (response.statusCode == 200 || response.statusCode == 201) {
          // Success
          final responseData = jsonDecode(response.body);


        } else {
          // Error - show appropriate message
          final errorData = jsonDecode(response.body);
          print(errorData);

          // Show error message based on API response

        }
      } catch (error) {
        // Network or other errors
        print(error);

      }}
    else{
      print('No JWT token found');
    }
  }
  Future<void> _initFCM() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      // Request permission (iOS only, safe to call on Android too)
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      print('🔔 User granted permission: ${settings.authorizationStatus}');

      // Get the token
      String? token = await messaging.getToken();


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
        body: Layout(
          isDarkMode: isDarkMode,
          onThemeToggle: () {
            setState(() {
              isDarkMode = !isDarkMode;
            });
          },
        ),

      ),
    );
  }
}
