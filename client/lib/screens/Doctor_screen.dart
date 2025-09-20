import 'package:client/screens/DoctorInfo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../component/qr_scanner_widget.dart';
class Doctor_screen extends StatefulWidget {

  const Doctor_screen({super.key});

  @override
  State<Doctor_screen> createState() => _Doctor_screenState();
}

class _Doctor_screenState extends State<Doctor_screen> {
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Doctorinfo(data: code,),));
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
