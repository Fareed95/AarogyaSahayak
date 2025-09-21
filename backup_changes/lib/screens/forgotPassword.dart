import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../component/custom_snackbar.dart.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _otpSent = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Store the email for later use in the reset request
  String _storedEmail = '';

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  Future<void> _resend() async{
    const String apiUrl = 'https://codenebula-internal-round-25.onrender.com/api/authentication/resendotp';

    final Map<String, dynamic> requestBody = {
      'email': _emailController.text.trim(),
    };

    try {
      // Make POST request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success
        final responseData = jsonDecode(response.body);

        // Show success message
        AwesomeSnackbar.success(
            context,
            "OTP resent Successfully",
            "Please check your email for the verification code"
        );

        setState(() {
          _isLoading = false;
          _otpSent = true;
        });
      } else {
        // Error - show appropriate message
        final errorData = jsonDecode(response.body);
        print(errorData);

        // Show error message based on API response
        String errorMessage = "Failed to send OTP";
        if (errorData.containsKey('message')) {
          errorMessage = errorData['message'];
        } else if (errorData.containsKey('error')) {
          errorMessage = errorData['error'];
        }

        AwesomeSnackbar.error(context, "Failed to send OTP", errorMessage);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      AwesomeSnackbar.error(context, "Network Error", "Please check your internet connection");
      setState(() => _isLoading = false);
    }


  }
  Future<void> _sendOtp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      const String apiUrl = 'https://codenebula-internal-round-25.onrender.com/api/authentication/password-reset-request/';

      final Map<String, dynamic> requestBody = {
        'email': _emailController.text.trim(),
      };

      // Store the email for the reset request
      _storedEmail = _emailController.text.trim();

      print(_storedEmail);

      try {
        // Make POST request
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          // Success
          final responseData = jsonDecode(response.body);

          // Show success message
          AwesomeSnackbar.success(
              context,
              "OTP sent Successfully",
              "Please check your email for the verification code"
          );

          setState(() {
            _isLoading = false;
            _otpSent = true;
          });
        } else {
          // Error - show appropriate message
          final errorData = jsonDecode(response.body);
          print(errorData);

          // Show error message based on API response
          String errorMessage = "Failed to send OTP";
          if (errorData.containsKey('message')) {
            errorMessage = errorData['message'];
          } else if (errorData.containsKey('error')) {
            errorMessage = errorData['error'];
          }

          AwesomeSnackbar.error(context, "Failed to send OTP", errorMessage);
          setState(() => _isLoading = false);
        }
      } catch (e) {
        AwesomeSnackbar.error(context, "Network Error", "Please check your internet connection");
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      const String apiUrl = 'https://codenebula-internal-round-25.onrender.com/api/authentication/password-reset/';

      final Map<String, dynamic> requestBody = {
        'email': _storedEmail,
        'otp': _otpController.text,
        'new_password': _newPasswordController.text
      };
      print('$_storedEmail, ${_otpController.text}, ${_newPasswordController.text}');

      try {
        // Make POST request to reset password with OTP and new password
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          // Success
          final responseData = jsonDecode(response.body);

          // Show success message
          AwesomeSnackbar.success(
              context,
              "Password Reset Successful",
              "You can now login with your new password"
          );

          // Navigate back to login
          Navigator.pop(context);
        } else {
          // Error - show appropriate message
          final errorData = jsonDecode(response.body);
          print(errorData);

          // Show error message based on API response
          String errorMessage = "Password reset failed";
          if (errorData.containsKey('message')) {
            errorMessage = errorData['message'];
          } else if (errorData.containsKey('error')) {
            errorMessage = errorData['error'];
          }

          AwesomeSnackbar.error(context, "Failed to reset password", errorMessage);
          setState(() => _isLoading = false);
        }
      } catch (e) {
        AwesomeSnackbar.error(context, "Network Error", "Please check your internet connection");
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Header
                _buildHeader(),
                const SizedBox(height: 32),

                // Email Input (always visible)
                _buildEmailField(),
                const SizedBox(height: 20),

                // Send OTP Button (only before OTP is sent)
                if (!_otpSent) _buildSendOtpButton(),

                // OTP Input (visible after OTP is sent)
                if (_otpSent) _buildOtpField(),
                if (_otpSent) const SizedBox(height: 20),

                // New Password Fields (visible after OTP is sent)
                if (_otpSent) _buildNewPasswordField(),
                if (_otpSent) const SizedBox(height: 20),
                if (_otpSent) _buildConfirmPasswordField(),
                if (_otpSent) const SizedBox(height: 20),

                // Reset Password Button (visible after OTP is sent)
                if (_otpSent) _buildResetPasswordButton(),

                const SizedBox(height: 24),

                // Back to Login
                _buildBackToLogin(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reset Password',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _otpSent
              ? 'Enter the OTP and your new password'
              : 'Enter your email to receive OTP',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      enabled: !_otpSent, // Disable after OTP is sent
      decoration: InputDecoration(
        labelText: 'Email Address',
        prefixIcon: Icon(Icons.email_outlined, color: Colors.blue.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!value.contains('@')) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildOtpField() {
    return TextFormField(
      controller: _otpController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'OTP Code',
        prefixIcon: Icon(Icons.lock_outline, color: Colors.blue.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
        ),
        suffixIcon: _otpSent
            ? TextButton(
          onPressed: () {
            // Resend OTP functionality
            _resend();
          },
          child: Text(
            'Resend',
            style: TextStyle(color: Colors.blue.shade600),
          ),
        )
            : null,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter OTP';
        }
        if (value.length != 6) {
          return 'OTP must be 6 digits';
        }
        return null;
      },
    );
  }

  Widget _buildNewPasswordField() {
    return TextFormField(
      controller: _newPasswordController,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: 'New Password',
        prefixIcon: Icon(Icons.lock_outline, color: Colors.blue.shade600),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.blue.shade600,
          ),
          onPressed: () {
            setState(() => _isPasswordVisible = !_isPasswordVisible);
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter new password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: !_isConfirmPasswordVisible,
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        prefixIcon: Icon(Icons.lock_outline, color: Colors.blue.shade600),
        suffixIcon: IconButton(
          icon: Icon(
            _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.blue.shade600,
          ),
          onPressed: () {
            setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please confirm your password';
        }
        if (value != _newPasswordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  Widget _buildSendOtpButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _sendOtp,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
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
          'Send OTP',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildResetPasswordButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _resetPassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade600,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
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
          'Reset Password',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBackToLogin() {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text(
          'Back to Login',
          style: TextStyle(
            color: Colors.blue.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}