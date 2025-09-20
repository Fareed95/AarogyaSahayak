// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:sizer/sizer.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import '../services/info.dart';
// import '../services/secure_storage_service.dart';
// import '../component/custom_snackbar.dart';
// import 'forgotPassword.dart';
// import 'register_screen.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen>
//     with TickerProviderStateMixin {
//   bool _isLoading = false;
//   bool _isSocialLoading = false;
//   bool _isPasswordVisible = false;
  
//   late AnimationController _fadeController;
//   late AnimationController _slideController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;

//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();

//   // Color palette
//   static const Color primaryColor = Color(0xFF14213D);
//   static const Color accentColor = Color(0xFFFCA311);
//   static const Color neutralLight = Color(0xFFE5E5E5);
//   static const Color neutralWhite = Color(0xFFFFFFFF);
//   static const Color neutralBlack = Color(0xFF000000);

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//     _startAnimations();
//   }

//   void _initializeAnimations() {
//     _fadeController = AnimationController(
//       duration: const Duration(milliseconds: 1000),
//       vsync: this,
//     );

//     _slideController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _fadeController,
//       curve: Curves.easeInOut,
//     ));

//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.3),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _slideController,
//       curve: Curves.easeOutCubic,
//     ));
//   }

//   void _startAnimations() {
//     Future.delayed(const Duration(milliseconds: 300), () {
//       _fadeController.forward();
//     });

//     Future.delayed(const Duration(milliseconds: 500), () {
//       _slideController.forward();
//     });
//   }

//   @override
//   void dispose() {
//     _fadeController.dispose();
//     _slideController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   Future<void> _login() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });

//       try {
//         // API endpoint
//         const String apiUrl = 'https://flutter-demo-c7cg.onrender.com/login/';

//         // Prepare the request body
//         final Map<String, dynamic> requestBody = {
//           'email': _emailController.text.trim(),
//           'password': _passwordController.text,
//         };

//         // Make POST request
//         final response = await http.post(
//           Uri.parse(apiUrl),
//           headers: <String, String>{
//             'Content-Type': 'application/json; charset=UTF-8',
//           },
//           body: jsonEncode(requestBody),
//         );

//         // Handle response
//         if (response.statusCode == 200 || response.statusCode == 201) {
//           // Success
//           final responseData = jsonDecode(response.body);
//           await SecureStorageService().storeJwtToken(responseData['jwt']);
          
//           // Provide haptic feedback
//           HapticFeedback.mediumImpact();

//           // Show success message
//           AwesomeSnackbar.success(
//             context,
//             "Login Successful",
//             "Welcome back! Redirecting to dashboard..."
//           );

//           Info().setLoggedIn(true);
          
//           // Navigate to home dashboard
//           Navigator.pushReplacementNamed(context, '/home-dashboard');

//           _emailController.clear();
//           _passwordController.clear();
//         } else {
//           // Error - show appropriate message
//           final errorData = jsonDecode(response.body);
          
//           HapticFeedback.heavyImpact();

//           String errorMessage = "Login failed";
//           if (errorData.containsKey('message')) {
//             errorMessage = errorData['message'];
//           } else if (errorData.containsKey('error')) {
//             errorMessage = errorData['error'];
//           }

//           AwesomeSnackbar.error(context, "Login Failed", errorMessage);
//         }
//       } catch (error) {
//         // Network or other errors
//         HapticFeedback.heavyImpact();
//         AwesomeSnackbar.error(
//           context,
//           "Network Error",
//           "Please check your internet connection and try again"
//         );
//       } finally {
//         if (mounted) {
//           setState(() {
//             _isLoading = false;
//           });
//         }
//       }
//     }
//   }

//   Future<void> _handleGoogleLogin() async {
//     setState(() {
//       _isSocialLoading = true;
//     });

//     // Simulate Google login process
//     await Future.delayed(const Duration(seconds: 3));

//     if (mounted) {
//       AwesomeSnackbar.info(
//         context,
//         "Coming Soon",
//         "Google login feature will be available soon"
//       );

//       setState(() {
//         _isSocialLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       body: SafeArea(
//         child: FadeTransition(
//           opacity: _fadeAnimation,
//           child: SlideTransition(
//             position: _slideAnimation,
//             child: SingleChildScrollView(
//               physics: const BouncingScrollPhysics(),
//               child: Container(
//                 constraints: BoxConstraints(
//                   minHeight: MediaQuery.of(context).size.height -
//                       MediaQuery.of(context).padding.top -
//                       MediaQuery.of(context).padding.bottom,
//                 ),
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 6.w),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       SizedBox(height: 8.h),

//                       // Healthcare Logo Section
//                       _buildHealthcareLogo(),

//                       SizedBox(height: 6.h),

//                       // Welcome Text
//                       Text(
//                         'Welcome Back!',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 28.sp,
//                           fontWeight: FontWeight.bold,
//                           color: primaryColor,
//                         ),
//                       ),

//                       SizedBox(height: 1.h),

//                       Text(
//                         'Sign in to continue your healthcare journey',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 14.sp,
//                           color: neutralBlack.withOpacity(0.7),
//                         ),
//                       ),

//                       SizedBox(height: 5.h),

//                       // Login Form
//                       _buildLoginForm(),

//                       SizedBox(height: 4.h),

//                       // Login Button
//                       _buildLoginButton(),

//                       SizedBox(height: 3.h),

//                       // Divider
//                       _buildDivider(),

//                       SizedBox(height: 3.h),

//                       // Social Login Section
//                       _buildSocialLogin(),

//                       SizedBox(height: 4.h),

//                       // Sign Up Link
//                       _buildSignUpLink(),

//                       SizedBox(height: 3.h),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHealthcareLogo() {
//     return Container(
//       padding: EdgeInsets.all(6.w),
//       child: Column(
//         children: [
//           Container(
//             width: 100,
//             height: 100,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   primaryColor,
//                   accentColor,
//                 ],
//               ),
//               borderRadius: BorderRadius.circular(24),
//               boxShadow: [
//                 BoxShadow(
//                   color: primaryColor.withOpacity(0.3),
//                   blurRadius: 20,
//                   offset: const Offset(0, 10),
//                 ),
//               ],
//             ),
//             child: const Icon(
//               Icons.local_hospital_rounded,
//               size: 50,
//               color: Colors.white,
//             ),
//           ),
//           SizedBox(height: 2.h),
//           Text(
//             'HealthCare Assistant',
//             style: TextStyle(
//               fontSize: 20.sp,
//               fontWeight: FontWeight.bold,
//               color: primaryColor,
//               letterSpacing: 1.2,
//             ),
//           ),
//           Text(
//             'Your Health, Our Priority',
//             style: TextStyle(
//               fontSize: 12.sp,
//               color: neutralBlack.withOpacity(0.6),
//               fontStyle: FontStyle.italic,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLoginForm() {
//     return Container(
//       padding: EdgeInsets.all(6.w),
//       decoration: BoxDecoration(
//         color: neutralWhite,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: primaryColor.withOpacity(0.1),
//             blurRadius: 20,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Form(
//         key: _formKey,
//         child: Column(
//           children: [
//             // Email Field
//             TextFormField(
//               controller: _emailController,
//               keyboardType: TextInputType.emailAddress,
//               style: TextStyle(
//                 fontSize: 14.sp,
//                 color: neutralBlack,
//               ),
//               decoration: InputDecoration(
//                 labelText: 'Email Address',
//                 labelStyle: TextStyle(color: neutralBlack.withOpacity(0.7)),
//                 prefixIcon: Icon(
//                   Icons.email_outlined,
//                   color: primaryColor,
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(16),
//                   borderSide: BorderSide(color: neutralLight),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(16),
//                   borderSide: BorderSide(color: primaryColor, width: 2),
//                 ),
//                 filled: true,
//                 fillColor: const Color(0xFFF8F9FA),
//               ),
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter your email';
//                 }
//                 if (!value.contains('@')) {
//                   return 'Please enter a valid email';
//                 }
//                 return null;
//               },
//             ),
//             SizedBox(height: 3.h),
            
//             // Password Field
//             TextFormField(
//               controller: _passwordController,
//               obscureText: !_isPasswordVisible,
//               style: TextStyle(
//                 fontSize: 14.sp,
//                 color: neutralBlack,
//               ),
//               decoration: InputDecoration(
//                 labelText: 'Password',
//                 labelStyle: TextStyle(color: neutralBlack.withOpacity(0.7)),
//                 prefixIcon: Icon(
//                   Icons.lock_outline,
//                   color: primaryColor,
//                 ),
//                 suffixIcon: IconButton(
//                   icon: Icon(
//                     _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
//                     color: primaryColor,
//                   ),
//                   onPressed: () {
//                     setState(() => _isPasswordVisible = !_isPasswordVisible);
//                   },
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(16),
//                   borderSide: BorderSide(color: neutralLight),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(16),
//                   borderSide: BorderSide(color: primaryColor, width: 2),
//                 ),
//                 filled: true,
//                 fillColor: const Color(0xFFF8F9FA),
//               ),
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter your password';
//                 }
//                 if (value.length < 6) {
//                   return 'Password must be at least 6 characters';
//                 }
//                 return null;
//               },
//             ),
            
//             SizedBox(height: 2.h),
            
//             // Forgot Password
//             Align(
//               alignment: Alignment.centerRight,
//               child: TextButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => ForgotPasswordPage())
//                   );
//                 },
//                 child: Text(
//                   'Forgot Password?',
//                   style: TextStyle(
//                     color: primaryColor,
//                     fontWeight: FontWeight.w600,
//                     fontSize: 12.sp,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLoginButton() {
//     return Container(
//       width: double.infinity,
//       height: 56,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.centerLeft,
//           end: Alignment.centerRight,
//           colors: [primaryColor, primaryColor.withOpacity(0.8)],
//         ),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: primaryColor.withOpacity(0.4),
//             blurRadius: 15,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: ElevatedButton(
//         onPressed: _isLoading ? null : _login,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.transparent,
//           shadowColor: Colors.transparent,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//         ),
//         child: _isLoading
//             ? const SizedBox(
//                 width: 24,
//                 height: 24,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2,
//                   valueColor: AlwaysStoppedAnimation(Colors.white),
//                 ),
//               )
//             : Text(
//                 'Sign In',
//                 style: TextStyle(
//                   fontSize: 16.sp,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//       ),
//     );
//   }

//   Widget _buildDivider() {
//     return Row(
//       children: [
//         Expanded(
//           child: Divider(color: neutralLight, thickness: 1),
//         ),
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: 4.w),
//           child: Text(
//             'Or continue with',
//             style: TextStyle(
//               color: neutralBlack.withOpacity(0.6),
//               fontSize: 12.sp,
//             ),
//           ),
//         ),
//         Expanded(
//           child: Divider(color: neutralLight, thickness: 1),
//         ),
//       ],
//     );
//   }

//   Widget _buildSocialLogin() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         _buildSocialButton(
//           icon: Icons.g_mobiledata,
//           onPressed: _handleGoogleLogin,
//           color: Colors.red.shade400,
//           label: 'Google',
//         ),
//       ],
//     );
//   }

//   Widget _buildSocialButton({
//     required IconData icon,
//     required VoidCallback onPressed,
//     required Color color,
//     required String label,
//   }) {
//     return GestureDetector(
//       onTap: onPressed,
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
//         decoration: BoxDecoration(
//           color: neutralWhite,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: neutralLight),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.1),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: _isSocialLoading
//             ? const SizedBox(
//                 width: 24,
//                 height: 24,
//                 child: CircularProgressIndicator(strokeWidth: 2),
//               )
//             : Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(icon, color: color, size: 24),
//                   SizedBox(width: 2.w),
//                   Text(
//                     'Continue with $label',
//                     style: TextStyle(
//                       color: neutralBlack,
//                       fontWeight: FontWeight.w600,
//                       fontSize: 14.sp,
//                     ),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }

//   Widget _buildSignUpLink() {
//     return Container(
//       padding: EdgeInsets.all(4.w),
//       decoration: BoxDecoration(
//         color: neutralWhite,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: neutralLight),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             "Don't have an account? ",
//             style: TextStyle(
//               color: neutralBlack.withOpacity(0.7),
//               fontSize: 14.sp,
//             ),
//           ),
//           GestureDetector(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => SignupPage())
//               );
//             },
//             child: Text(
//               'Sign Up',
//               style: TextStyle(
//                 color: accentColor,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 14.sp,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }