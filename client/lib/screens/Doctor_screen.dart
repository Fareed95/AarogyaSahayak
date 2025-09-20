import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
class Doctor_screen extends StatelessWidget {
  final String data = 'https://example.com';
  const Doctor_screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generate QR')),
      body: Center(
        child: QrImageView(
          data: data,
          version: QrVersions.auto,
          size: 200.0,
        ),
      ),
    );
  }
}
