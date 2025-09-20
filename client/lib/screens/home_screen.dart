import 'dart:convert';
import 'package:client/services/secure_storage_service.dart';
import '../component/custom_snackbar.dart.dart';
import '../services/info.dart';
import 'login_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../screens/notification_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isDoctor = false;
  bool _isMedical = false;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    try {
      const String apiUrl = 'https://codenebula-internal-round-25.onrender.com/api/authentication/user';

      var token = await SecureStorageService().getJwtToken();

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': '$token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        bool doctor = responseData['is_doctor'];
        bool medical = responseData['is_medical_store'];

        setState(() {
          _isDoctor = doctor;
          _isMedical = medical;
        });

        Info().setDoctor(doctor);
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

  void _handleFileUpload() {
    print("File upload initiated");
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            _buildWelcomeSection(isDark),
            const SizedBox(height: 32),

            // File upload section
            _buildUploadSection(isDark),
            const SizedBox(height: 40),

            // Quick access section
            _buildQuickAccessSection(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Welcome to HealthHub",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF153D8A),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Upload your medical reports in PDF format and get instant insights about your health. Our AI-powered system will analyze your reports and provide you with easy-to-understand information.",
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildUploadSection(bool isDark) {
    return Center(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.blueGrey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.blueGrey[700]! : Colors.blueGrey[100]!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black54 : Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.medical_services,
              size: 64,
              color: isDark ? Colors.blueGrey[300] : const Color(0xFF153D8A),
            ),
            const SizedBox(height: 16),
            Text(
              "Upload Your Medical Reports",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF153D8A),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Supported format: PDF (Max size: 10MB)",
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _handleFileUpload,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF153D8A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 3,
              ),
              child: const Text("Select PDF File"),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {},
              child: Text(
                "How to get your medical reports?",
                style: TextStyle(
                  color: isDark ? Colors.blueGrey[300] : const Color(0xFF153D8A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quick Access",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF153D8A),
          ),
        ),
        const SizedBox(height: 20),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.9,
          children: [
            _buildFeatureButton(
              icon: Icons.medical_services,
              label: "Immediate Diagnosis",
              isDark: isDark,
              onTap: () {},
            ),
            _buildFeatureButton(
              icon: Icons.people,
              label: "Communities",
              isDark: isDark,
              onTap: () {},
            ),
            _buildFeatureButton(
              icon: Icons.chat,
              label: "AI Chat",
              isDark: isDark,
              onTap: () {},
            ),
            _buildFeatureButton(
              icon: Icons.restaurant,
              label: "Nutrition",
              isDark: isDark,
              onTap: () {},
            ),
            _buildFeatureButton(
              icon: Icons.summarize,
              label: "Report Summary",
              isDark: isDark,
              onTap: () {},
            ),
            _buildFeatureButton(
              icon: Icons.medication,
              label: "Medicines",
              isDark: isDark,
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureButton({
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.blueGrey[700]! : Colors.blueGrey[100]!,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black54 : Colors.grey.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: isDark ? Colors.blueGrey[300] : const Color(0xFF153D8A),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[300] : Colors.grey[800],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}