// components/qr_generator.dart
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRGenerator extends StatelessWidget {
  final String data;
  final double size;
  final Color backgroundColor;
  final Color? foregroundColor;
  final String? errorText;
  final EdgeInsets? padding;

  const QRGenerator({
    Key? key,
    required this.data,
    this.size = 200,
    this.backgroundColor = Colors.white,
    this.foregroundColor = Colors.black,
    this.errorText,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      color: backgroundColor,
      child: QrImageView(
        data: data,
        version: QrVersions.auto,
        size: size,
        backgroundColor: backgroundColor,
        eyeStyle: QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: foregroundColor!,
        ),
        dataModuleStyle: QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: foregroundColor!,
        ),
        errorStateBuilder: (context, error) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 40, color: Colors.red),
              const SizedBox(height: 8),
              Text(
                errorText ?? 'Error generating QR code',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          );
        },
      ),
    );
  }
}