import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../component/custom_snackbar.dart.dart';
import '../screens/notification_screen.dart';
import '../services/info.dart';
import 'login_screen.dart';
import 'voice_agent.dart'; // Intervo WebView screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _getUserData(); // Call your API here
  }

  Future<void> _getUserData() async {
    try {
      const String apiUrl =
          'https://codenebula-internal-round-25.onrender.com/api/authentication/user';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': '' // TODO: add token here
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        print(responseData);
        bool doctor = responseData['is_doctor'];
        Info().setDoctor(doctor);
        bool medical = responseData['is_medical_store'];
        Info().setMedical(medical);
      } else {
        final errorData = jsonDecode(response.body);
        print(errorData);
        String errorMessage = "Request failed";
        if (errorData.containsKey('message')) {
          errorMessage = errorData['message'];
        } else if (errorData.containsKey('error')) {
          errorMessage = errorData['error'];
        }
        AwesomeSnackbar.error(context, "Error", errorMessage);
      }
    } catch (error) {
      print(error);
      AwesomeSnackbar.error(
        context,
        "Network Error",
        "Please check your internet connection and try again",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const login_screen()),
              );
            },
            child: const Text('Login'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NotificationScreen()),
              );
            },
            child: const Text('Notification'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
            child: const Text('Voice Assistant'),
          ),
        ],
      ),
    );
  }
}
