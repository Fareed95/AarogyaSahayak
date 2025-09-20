import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class ChatHeaderWidget extends StatelessWidget {
  final VoidCallback? onClearChat;
  final VoidCallback? onExportChat;
  final bool isOnline;

  const ChatHeaderWidget({
    super.key,
    this.onClearChat,
    this.onExportChat,
    this.isOnline = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.all(2.w),
                child: CustomIconWidget(
                  iconName: 'arrow_back_ios',
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            SizedBox(width: 3.w),
            _buildAIAvatar(),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Health Assistant',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      Container(
                        width: 2.w,
                        height: 2.w,
                        decoration: BoxDecoration(
                          color: isOnline ? Colors.green : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        isOnline ? 'Online' : 'Offline',
                        style: GoogleFonts.roboto(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildAIAvatar() {
    return Container(
      width: 12.w,
      height: 12.w,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: CustomIconWidget(
        iconName: 'smart_toy',
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        if (onExportChat != null)
          GestureDetector(
            onTap: onExportChat,
            child: Container(
              padding: EdgeInsets.all(2.w),
              child: CustomIconWidget(
                iconName: 'download',
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        if (onClearChat != null)
          GestureDetector(
            onTap: onClearChat,
            child: Container(
              padding: EdgeInsets.all(2.w),
              child: CustomIconWidget(
                iconName: 'refresh',
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
      ],
    );
  }
}