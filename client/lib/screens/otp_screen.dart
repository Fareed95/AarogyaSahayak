import 'package:flutter/material.dart';
import '../screens/otp_screen.dart';
import '../component/custom_snackbar.dart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/secure_storage_service.dart';
import '../services/info.dart';
class OtpScreen extends StatefulWidget {
  final String email;

  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;
  bool _isResending = false;
  int _countdown = 60;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    print('Received email: ${widget.email}');
    print('Email is empty: ${widget.email.isEmpty}');
    // Set up focus node listeners for auto-moving between OTP fields
    for (int i = 0; i < _focusNodes.length; i++) {
      _focusNodes[i].addListener(() {
        if (!_focusNodes[i].hasFocus && i < _focusNodes.length - 1) {
          FocusScope.of(context).requestFocus(_focusNodes[i + 1]);
        }
      });
    }
  }

  void _startCountdown() {
    // Start a 60-second countdown for resend OTP
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _countdown > 0) {
        setState(() => _countdown--);
        _startCountdown();
      }
    });
  }

  Future<void> _verifyOtp() async {
    String otp = _otpControllers.map((controller) => controller.text).join();

    if (otp.length != 6) {
      AwesomeSnackbar.error(context, "Invalid OTP", "Please enter the 6-digit code");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // API endpoint for OTP verification
      const String apiUrl = 'https://flutter-demo-c7cg.onrender.com/register/';

      // Prepare the request body
      final Map<String, dynamic> requestBody = {
        'email': widget.email,
        'otp': otp,
      };
      print(otp);
      print(widget.email);
      // Make POST request
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      // Handle response
      if (response.statusCode == 200) {
        // Success
        final responseData = jsonDecode(response.body);
        // print(responseData['jwt']);
        if (responseData.containsKey('jwt')) {

          try {
          await SecureStorageService().storeJwtToken(responseData['jwt']);
          print('JWT token stored securely');
          Info().setLoggedIn(true);
        } catch (e) {
          print('Error storing token: $e');
          AwesomeSnackbar.error(context, "Storage Error", "Could not save login information");
        }}
        AwesomeSnackbar.success(context, "Verification Success", "Your account has been verified!");
        Navigator.pop(context);
        // Navigate to the home screen or next step
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
      } else {
        // Error
        final errorData = jsonDecode(response.body);
        print(errorData);
        AwesomeSnackbar.error(context, "Verification Failed", errorData['message'] ?? 'Invalid OTP code');
      }
    } catch (error) {
      // Network or other errors
      print(error);
      AwesomeSnackbar.error(context, "Error", "Network error. Please try again.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    try{
      const String apiUrl='https://flutter-demo-c7cg.onrender.com/resendotp/';
      final Map<String,dynamic>reqbody={
        'email':widget.email
      };
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(reqbody),

      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success
        final responseData = jsonDecode(response.body);
        print(responseData);
        AwesomeSnackbar.success(
            context,
            "OTP Resent Successful",
            "Please check your email for the verification code"
        );
      }
    } catch(error){
      print(error);
      AwesomeSnackbar.error(
          context,
          "Network Error",
          "Please check your internet connection and try again");
    }
    setState(() {
      _isResending = true;
      _countdown = 60;
    });

    try {
      // API endpoint for resending OTP
      const String apiUrl = 'https://flutter-demo-c7cg.onrender.com/resendotp/';

      // Prepare the request body
      final Map<String, dynamic> requestBody = {
        'email': widget.email,
      };

      // Make POST request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      // Handle response
      if (response.statusCode == 200) {
        // Success
        AwesomeSnackbar.success(context, "OTP Sent", "A new verification code has been sent to your email");
        _startCountdown();
      } else {
        // Error
        final errorData = jsonDecode(response.body);
        print(errorData);
        AwesomeSnackbar.error(context, "Error", errorData['message'] ?? 'Failed to resend OTP');
      }
    } catch (error) {
      // Network or other errors
      print(error);
      AwesomeSnackbar.error(context, "Error", "Network error. Please try again.");
    } finally {
      setState(() => _isResending = false);
    }
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // App Logo and Title
              _buildHeader(),
              const SizedBox(height: 32),
              // OTP Form
              _buildOtpForm(),
              const SizedBox(height: 32),
              // Verify Button
              _buildVerifyButton(),
              const SizedBox(height: 24),
              // Resend OTP Link
              _buildResendLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blue.shade200, width: 2),
          ),
          child: Icon(
            Icons.verified_user,
            size: 50,
            color: Colors.blue.shade700,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'VERIFICATION',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Enter the 6-digit code sent to',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.email,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade700,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildOtpForm() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 45,
              child: TextFormField(
                controller: _otpControllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                decoration: InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                  ),
                ),
                onChanged: (value) {
                  if (value.length == 1 && index < 5) {
                    FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
                  }

                  // Auto-submit when all fields are filled
                  if (index == 5 && value.isNotEmpty) {
                    bool allFilled = true;
                    for (var controller in _otpControllers) {
                      if (controller.text.isEmpty) {
                        allFilled = false;
                        break;
                      }
                    }
                    if (allFilled) {
                      _verifyOtp();
                    }
                  }
                },
              ),
            );
          }),
        ),
        const SizedBox(height: 20),
        Text(
          'Didn\'t receive the code?',
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _verifyOtp,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(Colors.white),
          ),
        )
            : const Text(
          'Verify',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildResendLink() {
    return _countdown > 0
        ? Text(
      'Resend code in $_countdown seconds',
      style: TextStyle(
        color: Colors.grey.shade600,
      ),
    )
        : _isResending
        ? const CircularProgressIndicator()
        : TextButton(
      onPressed: _resendOtp,
      child: Text(
        'Resend Verification Code',
        style: TextStyle(
          color: Colors.blue.shade700,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}