import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';

class AwesomeSnackbar {
  static void _show({
    required BuildContext context,
    required String title,
    required String message,
    required ContentType contentType,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: title,
          message: message,
          contentType: contentType,
        ),
      ),
    );
  }

  static void success(BuildContext context, String title, String message) {
    _show(context: context, title: title, message: message, contentType: ContentType.success);
  }

  static void error(BuildContext context, String title, String message) {
    _show(context: context, title: title, message: message, contentType: ContentType.failure);
  }

  static void info(BuildContext context, String title, String message) {
    _show(context: context, title: title, message: message, contentType: ContentType.help);
  }

  static void warning(BuildContext context, String title, String message) {
    _show(context: context, title: title, message: message, contentType: ContentType.warning);
  }
}