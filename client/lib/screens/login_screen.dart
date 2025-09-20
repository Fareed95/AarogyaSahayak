import '../services/info.dart';
import 'package:flutter/material.dart';
import 'forgotPassword.dart';
import 'register_screen.dart';
import '../component/custom_snackbar.dart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/secure_storage_service.dart';

class login_screen extends StatefulWidget {
  const login_screen({super.key});

  @override
  State<login_screen> createState() => _LoginPageState();
}

class _LoginPageState extends State<login_screen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        // API endpoint
        const String apiUrl = 'https://codenebula-internal-round-25.onrender.com/api/authentication/login';

        // Prepare the request body
        final Map<String, dynamic> requestBody = {
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
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
        if (response.statusCode == 200 || response.statusCode == 201) {
          // Success
          final responseData = jsonDecode(response.body);
          
            await SecureStorageService().storeJwtToken(responseData['jwt']);
            print("token stored successfully");
            print(responseData['jwt']);
          // Show success message
          AwesomeSnackbar.success(
              context,
              "Registration Successful",
              "Please check your email for the verification code"
          );
            Info().setLoggedIn(true);
          Navigator.pop(context);

          _emailController.clear();
          _passwordController.clear();
        } else {
          // Error - show appropriate message
          final errorData = jsonDecode(response.body);
          print(errorData);

          // Show error message based on API response
          String errorMessage = "Registration failed";
          if (errorData.containsKey('message')) {
            errorMessage = errorData['message'];
          } else if (errorData.containsKey('error')) {
            errorMessage = errorData['error'];
          }

          AwesomeSnackbar.error(context, "Login Failed", errorMessage);
        }
      } catch (error) {
        // Network or other errors
        print(error);
        AwesomeSnackbar.error(
            context,
            "Network Error",
            "Please check your internet connection and try again"
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 80),
              // App Logo and Title
              _buildHeader(),
              const SizedBox(height: 48),
              // Login Form
              _buildLoginForm(),
              const SizedBox(height: 32),
              // Login Button
              _buildLoginButton(),
              const SizedBox(height: 24),
              // Divider
              _buildDivider(),
              const SizedBox(height: 24),
              // Social Login Options
              _buildSocialLogin(),
              const SizedBox(height: 32),
              // Sign Up Link
              _buildSignUpLink(),
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


        ),
        const SizedBox(height: 24),
        Text(
          'hackathon',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to continue',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
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
          ),
          const SizedBox(height: 20),
          // Password Field
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Password',
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
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordPage()));},
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                  color: Colors.blue.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
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
          'Sign In',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(color: Colors.grey.shade300),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Or continue with',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Expanded(
          child: Divider(color: Colors.grey.shade300),
        ),
      ],
    );
  }

  Widget _buildSocialLogin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton(
          icon: Icons.g_mobiledata,
          onPressed: () {},
          color: Colors.red.shade400,
        ),

      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(color: Colors.grey.shade600),
        ),
        GestureDetector(
          onTap: () {
           Navigator.push(context, MaterialPageRoute(builder: (context) => SignupPage(),));
          },
          child: Text(
            'Sign Up',
            style: TextStyle(
              color: Colors.blue.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}