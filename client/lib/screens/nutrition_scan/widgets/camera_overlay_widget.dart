import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CameraOverlayWidget extends StatelessWidget {
  final bool isFlashOn;
  final VoidCallback onFlashToggle;
  final VoidCallback onGalleryTap;
  final VoidCallback onBarcodeTap;
  final bool isBarcodeMode;

  const CameraOverlayWidget({
    super.key,
    required this.isFlashOn,
    required this.onFlashToggle,
    required this.onGalleryTap,
    required this.onBarcodeTap,
    required this.isBarcodeMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // Top overlay with controls
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 20.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Flash toggle
                      Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(6.w),
                        ),
                        child: IconButton(
                          onPressed: onFlashToggle,
                          icon: CustomIconWidget(
                            iconName: isFlashOn ? 'flash_on' : 'flash_off',
                            color: isFlashOn
                                ? AppTheme.lightTheme.colorScheme.secondary
                                : Colors.white,
                            size: 24,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),

                      // Mode toggle
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 3.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: onBarcodeTap,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 2.w, vertical: 0.5.h),
                                decoration: BoxDecoration(
                                  color: !isBarcodeMode
                                      ? AppTheme
                                          .lightTheme.colorScheme.secondary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  'Food',
                                  style: AppTheme
                                      .lightTheme.textTheme.labelMedium
                                      ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: !isBarcodeMode
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 2.w),
                            GestureDetector(
                              onTap: onBarcodeTap,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 2.w, vertical: 0.5.h),
                                decoration: BoxDecoration(
                                  color: isBarcodeMode
                                      ? AppTheme
                                          .lightTheme.colorScheme.secondary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  'Barcode',
                                  style: AppTheme
                                      .lightTheme.textTheme.labelMedium
                                      ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: isBarcodeMode
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Center guide overlay
          Center(
            child: Container(
              width: 70.w,
              height: 35.h,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  // Corner indicators
                  Positioned(
                    top: -1,
                    left: -1,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.secondary,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -1,
                    right: -1,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.secondary,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -1,
                    left: -1,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.secondary,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -1,
                    right: -1,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.secondary,
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Guide text
          Positioned(
            top: 45.h,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                isBarcodeMode
                    ? 'Position barcode within the frame'
                    : 'Frame your food within the guide',
                textAlign: TextAlign.center,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.8),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom overlay with controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 25.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Gallery button
                      Container(
                        width: 15.w,
                        height: 15.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(7.5.w),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: IconButton(
                          onPressed: onGalleryTap,
                          icon: CustomIconWidget(
                            iconName: 'photo_library',
                            color: Colors.white,
                            size: 24,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),

                      // Spacer for capture button (handled by parent)
                      SizedBox(width: 20.w),

                      // Tips button
                      Container(
                        width: 15.w,
                        height: 15.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(7.5.w),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: IconButton(
                          onPressed: () => _showTipsDialog(context),
                          icon: CustomIconWidget(
                            iconName: 'help_outline',
                            color: Colors.white,
                            size: 24,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTipsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Scanning Tips',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTipItem('• Ensure good lighting'),
            _buildTipItem('• Keep food within the frame'),
            _buildTipItem('• Hold camera steady'),
            _buildTipItem('• Capture from above for best results'),
            _buildTipItem('• Include portion reference (hand, plate)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it',
              style: TextStyle(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.5.h),
      child: Text(
        tip,
        style: AppTheme.lightTheme.textTheme.bodyMedium,
      ),
    );
  }
}
