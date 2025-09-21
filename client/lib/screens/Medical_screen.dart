import 'dart:convert';

import 'package:client/component/qr_scanner_widget.dart';
import 'package:client/screens/MedicineInfo.dart';
import 'package:flutter/material.dart';
import '../component/custom_snackbar.dart.dart';
import '../services/info.dart';
import 'Doctor_screen.dart'; // Ensure this import is correct
import 'package:http/http.dart' as http;
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

          Expanded(
            flex: 4,
            child: QRScannerSimple(
              onQRCodeScanned: (code) {
                setState(() => scannedData = code);
               if(code.isNotEmpty){
                 Navigator.push(context, MaterialPageRoute(builder: (context) => MedicalInfo(data: code,),));
               }
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
