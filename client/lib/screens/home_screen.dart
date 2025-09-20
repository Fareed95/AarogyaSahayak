import 'dart:convert';
import '../component/custom_snackbar.dart.dart';
import '../services/info.dart';
import 'login_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../screens/notification_screen.dart';
<<<<<<< HEAD
import 'voice_agent.dart'; // Import your Intervo WebView screen

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
=======

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
      const String apiUrl = 'https://codenebula-internal-round-25.onrender.com/api/authentication/user';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization':''
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
        String errorMessage = "Registration failed";
        if (errorData.containsKey('message')) {
          errorMessage = errorData['message'];
        } else if (errorData.containsKey('error')) {
          errorMessage = errorData['error'];
        }
        // Optionally show the error message
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
>>>>>>> c212cdb29c129226f411376acf4104ef8eaac5cc

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
<<<<<<< HEAD
        mainAxisAlignment: MainAxisAlignment.center,
=======
>>>>>>> c212cdb29c129226f411376acf4104ef8eaac5cc
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
<<<<<<< HEAD
                MaterialPageRoute(builder: (context) => const login_screen()),
              );
            },
            child: const Text('Login'),
=======
                MaterialPageRoute(builder: (context) => login_screen()),
              );
            },
            child: Text('Login'),
>>>>>>> c212cdb29c129226f411376acf4104ef8eaac5cc
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationScreen()),
              );
            },
<<<<<<< HEAD
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
=======
            child: Text('Notification'),
          ),
>>>>>>> c212cdb29c129226f411376acf4104ef8eaac5cc
        ],
      ),
    );
  }
}
