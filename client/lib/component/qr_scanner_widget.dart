// components/qr_scanner_simple.dart
import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:permission_handler/permission_handler.dart';

class QRScannerSimple
    extends
        StatefulWidget {
  final Function(
    String,
  )
  onQRCodeScanned;

  const QRScannerSimple({
    Key? key,
    required this.onQRCodeScanned,
  }) : super(
         key: key,
       );

  @override
  _QRScannerSimpleState createState() => _QRScannerSimpleState();
}

class _QRScannerSimpleState
    extends
        State<
          QRScannerSimple
        > {
  bool _isLoading = false;
  bool _permissionChecked = false;

  Future<
    void
  >
  _scanQRCode() async {
    setState(
      () => _isLoading = true,
    );

    try {
      // Check camera permission
      final status = await Permission.camera.status;
      if (!status.isGranted) {
        final result = await Permission.camera.request();
        if (!result.isGranted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            const SnackBar(
              content: Text(
                'Camera permission is required',
              ),
            ),
          );
          setState(
            () => _isLoading = false,
          );
          return;
        }
      }

      // Add a small delay to ensure camera is ready
      await Future.delayed(
        const Duration(
          milliseconds: 300,
        ),
      );

      // Scan QR code
      final result = await BarcodeScanner.scan();
      if (result.rawContent.isNotEmpty) {
        widget.onQRCodeScanned(
          result.rawContent,
        );
      }
    } catch (
      e
    ) {
      // Handle scan cancellation or errors
      if (e.toString().contains(
            'cancel',
          ) ||
          e.toString().contains(
            'back',
          )) {
        // User cancelled the scan, do nothing
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString()}',
            ),
          ),
        );
      }
    } finally {
      setState(
        () => _isLoading = false,
      );
    }
  }

  Future<
    void
  >
  _checkPermissionsAndScan() async {
    // Check permission first
    final status = await Permission.camera.status;
    setState(
      () => _permissionChecked = true,
    );

    if (status.isGranted) {
      // If permission is already granted, start scan
      _scanQRCode();
    }
    // If not granted, wait for user to press the button
  }

  @override
  void initState() {
    super.initState();
    // Check permissions when screen loads
    WidgetsBinding.instance.addPostFrameCallback(
      (
        _,
      ) => _checkPermissionsAndScan(),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      body: Center(
        child: _isLoading
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                    'Preparing camera...',
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.qr_code_scanner,
                    size: 64,
                    color: Colors.blue,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  const Text(
                    'QR Code Scanner',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  const Text(
                    'Tap the button below to scan a QR code',
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  ElevatedButton(
                    onPressed: _scanQRCode,
                    child: const Text(
                      'Scan QR Code',
                    ),
                  ),
                  if (!_permissionChecked)
                    const Padding(
                      padding: EdgeInsets.only(
                        top: 16,
                      ),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
      ),
    );
  }
}
