import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'component/custom_snackbar.dart.dart';
import 'theme/app_theme.dart';
import 'layout.dart';
import 'screens/login_screen.dart';
import 'firebase_options.dart';
import 'services/secure_storage_service.dart';
import 'services/info.dart';
import 'screens/login_screen.dart';

/// 🔙 Background message handler
Future<
  void
>
_firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print(
    "Background message received: ${message.messageId}",
  );
}

void
main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Background message registration
  FirebaseMessaging.onBackgroundMessage(
    _firebaseMessagingBackgroundHandler,
  );

  runApp(
    const HackathonApp(),
  );
}

class HackathonApp
    extends
        StatefulWidget {
  const HackathonApp({
    super.key,
  });

  @override
  State<
    HackathonApp
  >
  createState() => _HackathonAppState();
}

class _HackathonAppState
    extends
        State<
          HackathonApp
        > {
  bool isDarkMode = false;
  Widget? _homeScreen;

  @override
  void initState() {
    super.initState();
    _initFCM();
    _checkAuthentication();
  }

  /// Initialize FCM
  Future<
    void
  >
  _initFCM() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      print(
        '🔔 User granted permission: ${settings.authorizationStatus}',
      );
      String? token = await messaging.getToken();
      print(
        '📱 FCM Token: $token',
      );
      _setFCM(
        token,
      );
    } catch (
      e
    ) {
      print(
        "❌ Error initializing FCM: $e",
      );
    }
  }

  /// Send FCM token to backend if JWT exists
  Future<
    void
  >
  _setFCM(
    String? token,
  ) async {
    try {
      if (token ==
          null)
        return;
      String? jwtToken = await SecureStorageService().getJwtToken();
      if (jwtToken !=
          null) {
        const String apiUrl = 'https://codenebula-internal-round-25.onrender.com/api/user/';
        final response = await http.patch(
          Uri.parse(
            apiUrl,
          ),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': jwtToken,
          },
          body: jsonEncode(
            {
              'fcm_token': token,
            },
          ),
        );
        print(
          'FCM update status: ${response.statusCode}',
        );
        if (response.statusCode ==
                200 ||
            response.statusCode ==
                201) {
          final data = jsonDecode(
            response.body,
          );
          print(
            "FCM token updated successfully: $data",
          );
        }
      }
    } catch (
      e
    ) {
      print(
        "Error sending FCM token: $e",
      );
    }
  }

  /// Check JWT token and validate user
  Future<
    void
  >
  _checkAuthentication() async {
    String? jwtToken = await SecureStorageService().getJwtToken();

    if (jwtToken !=
        null) {
      try {
        final response = await http.get(
          Uri.parse(
            'https://codenebula-internal-round-25.onrender.com/api/authentication/user',
          ),
          headers: {
            'Authorization': jwtToken,
          },
        );

        if (response.statusCode ==
            200) {
          // Token valid → show Layout
          _homeScreen = Layout(
            isDarkMode: isDarkMode,
            onThemeToggle: () {
              setState(
                () => isDarkMode = !isDarkMode,
              );
            },
          );
        } else {
          // Token invalid → show Login
          _homeScreen = Layout(
            isDarkMode: isDarkMode,
            onThemeToggle: () {
              setState(
                    () => isDarkMode = !isDarkMode,
              );
            },
          );
        }
      } catch (
        e
      ) {
        print(
          "Error validating JWT: $e",
        );
        _homeScreen = Layout(
          isDarkMode: isDarkMode,
          onThemeToggle: () {
            setState(
                  () => isDarkMode = !isDarkMode,
            );
          },
        );
      }
    } else {
      // No token → Login screen
      _homeScreen = Layout(
        isDarkMode: isDarkMode,
        onThemeToggle: () {
          setState(
                () => isDarkMode = !isDarkMode,
          );
        },
      );
    }

    setState(
      () {},
    ); // Rebuild to show correct screen
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    // While checking auth, show loading
    if (_homeScreen ==
        null) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Arogya Sahayak',
      debugShowCheckedModeBanner: false,
      theme: isDarkMode
          ? AppTheme.darkTheme
          : AppTheme.lightTheme,
      home: _homeScreen,
    );
  }
}
