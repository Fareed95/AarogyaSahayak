import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../component/custom_snackbar.dart.dart';

class ForgotPasswordPage
    extends
        StatefulWidget {
  const ForgotPasswordPage({
    super.key,
  });

  @override
  State<
    ForgotPasswordPage
  >
  createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState
    extends
        State<
          ForgotPasswordPage
        > {
  final _formKey =
      GlobalKey<
        FormState
      >();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _otpSent = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  String _storedEmail = '';

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<
    void
  >
  _resend() async {
    const String apiUrl = 'https://codenebula-internal-round-25.onrender.com/api/authentication/resendotp';

    final Map<
      String,
      dynamic
    >
    requestBody = {
      'email': _emailController.text.trim(),
    };

    try {
      final response = await http.post(
        Uri.parse(
          apiUrl,
        ),
        headers:
            <
              String,
              String
            >{
              'Content-Type': 'application/json; charset=UTF-8',
            },
        body: jsonEncode(
          requestBody,
        ),
      );

      if (response.statusCode ==
              200 ||
          response.statusCode ==
              201) {
        AwesomeSnackbar.success(
          context,
          "OTP resent Successfully",
          "Please check your email for the verification code",
        );
        setState(
          () {
            _isLoading = false;
            _otpSent = true;
          },
        );
      } else {
        final errorData = jsonDecode(
          response.body,
        );
        String errorMessage =
            errorData['message'] ??
            errorData['error'] ??
            "Failed to send OTP";
        AwesomeSnackbar.error(
          context,
          "Failed to send OTP",
          errorMessage,
        );
        setState(
          () => _isLoading = false,
        );
      }
    } catch (
      e
    ) {
      AwesomeSnackbar.error(
        context,
        "Network Error",
        "Please check your internet connection",
      );
      setState(
        () => _isLoading = false,
      );
    }
  }

  Future<
    void
  >
  _sendOtp() async {
    if (_formKey.currentState!.validate()) {
      setState(
        () => _isLoading = true,
      );

      const String apiUrl = 'https://codenebula-internal-round-25.onrender.com/api/authentication/password-reset-request/';

      final Map<
        String,
        dynamic
      >
      requestBody = {
        'email': _emailController.text.trim(),
      };

      _storedEmail = _emailController.text.trim();

      try {
        final response = await http.post(
          Uri.parse(
            apiUrl,
          ),
          headers:
              <
                String,
                String
              >{
                'Content-Type': 'application/json; charset=UTF-8',
              },
          body: jsonEncode(
            requestBody,
          ),
        );

        if (response.statusCode ==
                200 ||
            response.statusCode ==
                201) {
          AwesomeSnackbar.success(
            context,
            "OTP sent Successfully",
            "Please check your email",
          );
          setState(
            () {
              _isLoading = false;
              _otpSent = true;
            },
          );
        } else {
          final errorData = jsonDecode(
            response.body,
          );
          String errorMessage =
              errorData['message'] ??
              errorData['error'] ??
              "Failed to send OTP";
          AwesomeSnackbar.error(
            context,
            "Failed to send OTP",
            errorMessage,
          );
          setState(
            () => _isLoading = false,
          );
        }
      } catch (
        e
      ) {
        AwesomeSnackbar.error(
          context,
          "Network Error",
          "Please check your internet connection",
        );
        setState(
          () => _isLoading = false,
        );
      }
    }
  }

  Future<
    void
  >
  _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(
        () => _isLoading = true,
      );

      const String apiUrl = 'http://192.168.0.107:8000/api/authentication/password-reset/';

      final Map<
        String,
        dynamic
      >
      requestBody = {
        'email': _storedEmail,
        'otp': _otpController.text,
        'new_password': _newPasswordController.text,
        'confirm_password': _confirmPasswordController.text,
      };

      try {
        final response = await http.post(
          Uri.parse(
            apiUrl,
          ),
          headers:
              <
                String,
                String
              >{
                'Content-Type': 'application/json; charset=UTF-8',
              },
          body: jsonEncode(
            requestBody,
          ),
        );

        if (response.statusCode ==
                200 ||
            response.statusCode ==
                201) {
          AwesomeSnackbar.success(
            context,
            "Password Reset Successful",
            "You can now login with your new password",
          );
          Navigator.pop(
            context,
          );
        } else {
          final errorData = jsonDecode(
            response.body,
          );
          String errorMessage =
              errorData['message'] ??
              errorData['error'] ??
              "Password reset failed";
          AwesomeSnackbar.error(
            context,
            "Failed to reset password",
            errorMessage,
          );
          setState(
            () => _isLoading = false,
          );
        }
      } catch (
        e
      ) {
        AwesomeSnackbar.error(
          context,
          "Network Error",
          "Please check your internet connection",
        );
        setState(
          () => _isLoading = false,
        );
      }
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: const Color(
        0xffe5e5e5,
      ),
      appBar: AppBar(
        title: const Text(
          "Forgot Password",
        ),
        backgroundColor: const Color(
          0xfffca311,
        ), // Yellow primary
        foregroundColor: const Color(
          0xff14213d,
        ), // Blue text
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(
            24.0,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 24,
                ),
                _buildHeader(),
                const SizedBox(
                  height: 32,
                ),
                _buildEmailField(),
                const SizedBox(
                  height: 20,
                ),
                if (!_otpSent) _buildSendOtpButton(),
                if (_otpSent) ...[
                  _buildOtpField(),
                  const SizedBox(
                    height: 20,
                  ),
                  _buildNewPasswordField(),
                  const SizedBox(
                    height: 20,
                  ),
                  _buildConfirmPasswordField(),
                  const SizedBox(
                    height: 20,
                  ),
                  _buildResetPasswordButton(),
                ],
                const SizedBox(
                  height: 24,
                ),
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
        const Text(
          'Reset Password',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(
              0xff14213d,
            ), // blue headline
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          _otpSent
              ? 'Enter the OTP and your new password'
              : 'Enter your email to receive OTP',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      enabled: !_otpSent,
      decoration: _inputDecoration(
        "Email Address",
        Icons.email_outlined,
      ),
      validator:
          (
            value,
          ) {
            if (value ==
                    null ||
                value.isEmpty)
              return "Please enter your email";
            if (!value.contains(
              '@',
            ))
              return "Please enter a valid email";
            return null;
          },
    );
  }

  Widget _buildOtpField() {
    return TextFormField(
      controller: _otpController,
      keyboardType: TextInputType.number,
      decoration:
          _inputDecoration(
            "OTP Code",
            Icons.lock_outline,
          ).copyWith(
            suffixIcon: TextButton(
              onPressed: _resend,
              child: const Text(
                "Resend",
                style: TextStyle(
                  color: Color(
                    0xff14213d,
                  ),
                ), // Blue accent
              ),
            ),
          ),
      validator:
          (
            value,
          ) {
            if (value ==
                    null ||
                value.isEmpty)
              return "Please enter OTP";
            if (value.length !=
                6)
              return "OTP must be 6 digits";
            return null;
          },
    );
  }

  Widget _buildNewPasswordField() {
    return TextFormField(
      controller: _newPasswordController,
      obscureText: !_isPasswordVisible,
      decoration:
          _inputDecoration(
            "New Password",
            Icons.lock_outline,
          ).copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible
                    ? Icons.visibility
                    : Icons.visibility_off,
                color: const Color(
                  0xff14213d,
                ),
              ), // Blue icon
              onPressed: () => setState(
                () => _isPasswordVisible = !_isPasswordVisible,
              ),
            ),
          ),
      validator:
          (
            value,
          ) {
            if (value ==
                    null ||
                value.isEmpty)
              return "Please enter new password";
            if (value.length <
                6)
              return "Password must be at least 6 characters";
            return null;
          },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: !_isConfirmPasswordVisible,
      decoration:
          _inputDecoration(
            "Confirm Password",
            Icons.lock_outline,
          ).copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _isConfirmPasswordVisible
                    ? Icons.visibility
                    : Icons.visibility_off,
                color: const Color(
                  0xff14213d,
                ),
              ), // Blue icon
              onPressed: () => setState(
                () => _isConfirmPasswordVisible = !_isConfirmPasswordVisible,
              ),
            ),
          ),
      validator:
          (
            value,
          ) {
            if (value ==
                    null ||
                value.isEmpty)
              return "Please confirm password";
            if (value !=
                _newPasswordController.text) {
              return "Passwords do not match";
            }
            return null;
          },
    );
  }

  Widget _buildSendOtpButton() {
    return _styledButton(
      "Send OTP",
      const Color(
        0xfffca311,
      ),
      _sendOtp,
    );
  }

  Widget _buildResetPasswordButton() {
    return _styledButton(
      "Reset Password",
      const Color(
        0xfffca311,
      ),
      _resetPassword,
    );
  }

  Widget _buildBackToLogin() {
    return Center(
      child: TextButton(
        onPressed: () => Navigator.pop(
          context,
        ),
        child: const Text(
          "Back to Login",
          style: TextStyle(
            color: Color(
              0xff14213d,
            ), // Blue accent
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        icon,
        color: const Color(
          0xff14213d,
        ),
      ), // Blue accent
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          12,
        ),
        borderSide: const BorderSide(
          color: Color(
            0xff14213d,
          ),
        ), // Blue border
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          12,
        ),
        borderSide: const BorderSide(
          color: Color(
            0xfffca311,
          ),
          width: 2,
        ), // Yellow focus
      ),
    );
  }

  Widget _styledButton(
    String text,
    Color bgColor,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor, // Yellow primary
          foregroundColor: const Color(
            0xff14213d,
          ), // Blue text
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              12,
            ),
          ),
          elevation: 3,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(
                    Color(
                      0xff14213d,
                    ),
                  ), // Blue spinner
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
