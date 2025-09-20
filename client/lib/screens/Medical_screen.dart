import 'package:client/component/qr_scanner_widget.dart';
import 'package:flutter/material.dart';
import 'Doctor_screen.dart'; // Ensure this import is correct

class Medical_screen extends StatefulWidget {
  const Medical_screen({super.key});

  @override
  State<Medical_screen> createState() => _Medical_screenState();
}

class _Medical_screenState extends State<Medical_screen> {
  String? scannedData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Doctor_screen()),
              );
            },
            child: const Text("Go to Doctor Screen"),
          ),
          Expanded(
            flex: 4,
            child: QRScannerSimple(
              onQRCodeScanned: (code) {
                setState(() => scannedData = code);
                // Optionally, you can navigate or handle the result here
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(scannedData ?? 'Scan a code'),
            ),
          ),
        ],
      ),
    );
  }
}
