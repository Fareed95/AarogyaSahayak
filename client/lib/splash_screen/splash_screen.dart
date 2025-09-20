import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';  // Add this import

import '../../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _progressAnimationController;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _progressAnimation;

  bool _isInitializing = true;
  bool _showRetryOption = false;
  String _initializationStatus = 'Initializing Aarogya Sahayak...';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startInitialization();
  }

  void _setupAnimations() {
    // Logo animation controller
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Progress animation controller
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Logo fade animation
    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    // Logo scale animation
    _logoScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
    ));

    // Progress animation
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOut,
    ));

    // Start logo animation
    _logoAnimationController.forward();
  }

  Future<void> _startInitialization() async {
    try {
      // Start progress animation
      _progressAnimationController.forward();

      // Simulate initialization steps with realistic delays
      await _performInitializationSteps();

      // Navigate based on initialization results
      await _navigateToNextScreen();
    } catch (e) {
      _handleInitializationError();
    }
  }

  Future<void> _performInitializationSteps() async {
    // Step 1: Check authentication status
    setState(() {
      _initializationStatus = 'Checking authentication...';
    });
    await Future.delayed(const Duration(milliseconds: 800));

    // Step 2: Load user health preferences
    setState(() {
      _initializationStatus = 'Loading health preferences...';
    });
    await Future.delayed(const Duration(milliseconds: 600));

    // Step 3: Fetch local health worker data
    setState(() {
      _initializationStatus = 'Connecting to health workers...';
    });
    await Future.delayed(const Duration(milliseconds: 700));

    // Step 4: Prepare cached medical documents
    setState(() {
      _initializationStatus = 'Preparing medical documents...';
    });
    await Future.delayed(const Duration(milliseconds: 500));

    // Step 5: Final setup
    setState(() {
      _initializationStatus = 'Almost ready...';
    });
    await Future.delayed(const Duration(milliseconds: 400));
  }

  Future<void> _navigateToNextScreen() async {
    if (!mounted) return;

    // Simulate authentication check
    final bool isAuthenticated = await _checkAuthenticationStatus();
    final bool isFirstTime = await _checkFirstTimeUser();

    // Add a small delay for smooth transition
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    if (isFirstTime) {
      // New users see onboarding (for now, redirect to login)
      Navigator.pushReplacementNamed(context, '/login-screen');
    } else if (isAuthenticated) {
      // Authenticated users go to dashboard
      Navigator.pushReplacementNamed(context, '/home-dashboard');
    } else {
      // Non-authenticated returning users go to login
      Navigator.pushReplacementNamed(context, '/login-screen');
    }
  }

  Future<bool> _checkAuthenticationStatus() async {
    // Simulate authentication check
    // In real implementation, check stored tokens/credentials
    return false; // Default to not authenticated for demo
  }

  Future<bool> _checkFirstTimeUser() async {
    // Simulate first-time user check
    // In real implementation, check if user has completed onboarding
    return true; // Default to first-time for demo
  }

  void _handleInitializationError() {
    if (!mounted) return;

    setState(() {
      _isInitializing = false;
      _showRetryOption = true;
      _initializationStatus =
          'Connection failed. Please check your internet connection.';
    });

    // Show retry option after 5 seconds if not already shown
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && !_showRetryOption) {
        setState(() {
          _showRetryOption = true;
        });
      }
    });
  }

  void _retryInitialization() {
    setState(() {
      _isInitializing = true;
      _showRetryOption = false;
      _initializationStatus = 'Retrying initialization...';
    });

    // Reset and restart animations
    _progressAnimationController.reset();
    _startInitialization();
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppTheme.primaryLight,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryLight, // Dark blue
              AppTheme.primaryVariantLight, // Darker blue
              Color(0xFF8E8E93), // Light gray
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Spacer to push content to center
              const Spacer(flex: 2),

              // App Logo Section
              _buildLogoSection(),

              SizedBox(height: 48.h),

              // Loading Section
              _buildLoadingSection(),

              // Spacer to balance layout
              const Spacer(flex: 2),

              // Bottom branding
              _buildBottomBranding(),

              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return AnimatedBuilder(
      animation: _logoAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScaleAnimation.value,
          child: Opacity(
            opacity: _logoFadeAnimation.value,
            child: Column(
              children: [
                // App Logo
                Container(
                  width: 25.w,
                  height: 25.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.w),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'health_and_safety',
                      color: AppTheme.primaryLight,
                      size: 12.w,
                    ),
                  ),
                ),

                SizedBox(height: 3.h),

                // App Name
                Text(
                  'Aarogya Sahayak',
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),

                SizedBox(height: 1.h),

                // App Tagline
                Text(
                  'Your Health Companion',
                  style: GoogleFonts.roboto(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.8),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingSection() {
    return Column(
      children: [
        // Progress Indicator
        if (_isInitializing) ...[
          SizedBox(
            width: 60.w,
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: _progressAnimation.value,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.secondaryLight,
                  ),
                  minHeight: 0.8.h,
                );
              },
            ),
          ),

          SizedBox(height: 2.h),

          // Status Text
          Text(
            _initializationStatus,
            style: GoogleFonts.roboto(
              fontSize: 11.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],

        // Retry Button
        if (_showRetryOption) ...[
          SizedBox(height: 2.h),
          ElevatedButton(
            onPressed: _retryInitialization,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryLight,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: 8.w,
                vertical: 1.5.h,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.w),
              ),
              elevation: 2,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'refresh',
                  color: Colors.white,
                  size: 4.w,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Retry',
                  style: GoogleFonts.roboto(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBottomBranding() {
    return Column(
      children: [
        // Healthcare certification badge
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 4.w,
            vertical: 1.h,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(2.w),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: 'verified',
                color: AppTheme.secondaryLight,
                size: 3.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Certified Healthcare App',
                style: GoogleFonts.roboto(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 2.h),

        // Version info
        Text(
          'Version 1.0.0',
          style: GoogleFonts.roboto(
            fontSize: 9.sp,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}