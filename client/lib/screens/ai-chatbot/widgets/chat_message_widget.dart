import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class ChatMessageWidget extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isUser;
  final VoidCallback? onCopy;
  final VoidCallback? onShare;

  const ChatMessageWidget({
    super.key,
    required this.message,
    required this.isUser,
    this.onCopy,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 1.h, horizontal: 4.w),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatarWidget(),
          if (!isUser) SizedBox(width: 2.w),
          Flexible(
            child: GestureDetector(
              onLongPress: () => _showMessageOptions(context),
              child: Container(
                constraints: BoxConstraints(maxWidth: 75.w),
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: isUser
                      ? AppTheme.lightTheme.colorScheme.secondary
                      : AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMessageContent(),
                    SizedBox(height: 1.h),
                    _buildTimestamp(),
                  ],
                ),
              ),
            ),
          ),
          if (isUser) SizedBox(width: 2.w),
          if (isUser) _buildUserAvatar(),
        ],
      ),
    );
  }

  Widget _buildAvatarWidget() {
    return Container(
      width: 8.w,
      height: 8.w,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary,
        shape: BoxShape.circle,
      ),
      child: CustomIconWidget(
        iconName: 'smart_toy',
        color: Colors.white,
        size: 16,
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 8.w,
      height: 8.w,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.secondary,
        shape: BoxShape.circle,
      ),
      child: CustomIconWidget(
        iconName: 'person',
        color: Colors.white,
        size: 16,
      ),
    );
  }

  Widget _buildMessageContent() {
    final content = message['content'] as String? ?? '';
    final messageType = message['type'] as String? ?? 'text';

    switch (messageType) {
      case 'text':
        return Text(
          content,
          style: GoogleFonts.roboto(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: isUser
                ? Colors.white
                : AppTheme.lightTheme.colorScheme.onSurface,
            height: 1.4,
          ),
        );
      case 'rich':
        return _buildRichContent();
      case 'emergency':
        return _buildEmergencyContent();
      default:
        return Text(
          content,
          style: GoogleFonts.roboto(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: isUser
                ? Colors.white
                : AppTheme.lightTheme.colorScheme.onSurface,
          ),
        );
    }
  }

  Widget _buildRichContent() {
    final content = message['content'] as String? ?? '';
    final hasActions = message['actions'] != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          content,
          style: GoogleFonts.roboto(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppTheme.lightTheme.colorScheme.onSurface,
            height: 1.4,
          ),
        ),
        if (hasActions) ...[
          SizedBox(height: 2.h),
          _buildActionButtons(),
        ],
      ],
    );
  }

  Widget _buildEmergencyContent() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.error,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'warning',
                color: AppTheme.lightTheme.colorScheme.error,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Emergency Detected',
                style: GoogleFonts.roboto(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.error,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            message['content'] as String? ?? '',
            style: GoogleFonts.roboto(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppTheme.lightTheme.colorScheme.onSurface,
              height: 1.4,
            ),
          ),
          SizedBox(height: 2.h),
          ElevatedButton.icon(
            onPressed: () {
              // Handle emergency call
            },
            icon: CustomIconWidget(
              iconName: 'phone',
              color: Colors.white,
              size: 16,
            ),
            label: Text(
              'Call Health Worker',
              style: GoogleFonts.roboto(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final actions = message['actions'] as List<dynamic>? ?? [];

    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: actions.map<Widget>((action) {
        final actionMap = action as Map<String, dynamic>;
        final title = actionMap['title'] as String? ?? '';
        final type = actionMap['type'] as String? ?? 'default';

        return OutlinedButton(
          onPressed: () {
            _handleActionTap(type, actionMap);
          },
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            side: BorderSide(
              color: AppTheme.lightTheme.colorScheme.primary,
              width: 1,
            ),
          ),
          child: Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimestamp() {
    final timestamp = message['timestamp'] as DateTime? ?? DateTime.now();
    final timeString =
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';

    return Text(
      timeString,
      style: GoogleFonts.roboto(
        fontSize: 10.sp,
        fontWeight: FontWeight.w400,
        color: isUser
            ? Colors.white.withValues(alpha: 0.7)
            : AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6),
      ),
    );
  }

  void _handleActionTap(String type, Map<String, dynamic> action) {
    switch (type) {
      case 'appointment':
        // Handle appointment booking
        break;
      case 'reminder':
        // Handle reminder setting
        break;
      case 'vitals':
        // Handle vitals tracking
        break;
      default:
        break;
    }
  }

  void _showMessageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'copy',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 20,
              ),
              title: Text(
                'Copy Message',
                style: GoogleFonts.roboto(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _copyMessage();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'share',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 20,
              ),
              title: Text(
                'Share Message',
                style: GoogleFonts.roboto(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                if (onShare != null) onShare!();
              },
            ),
            if (!isUser)
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'flag',
                  color: AppTheme.lightTheme.colorScheme.error,
                  size: 20,
                ),
                title: Text(
                  'Flag Incorrect',
                  style: GoogleFonts.roboto(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.lightTheme.colorScheme.error,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _flagMessage();
                },
              ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _copyMessage() {
    final content = message['content'] as String? ?? '';
    Clipboard.setData(ClipboardData(text: content));
    if (onCopy != null) onCopy!();
  }

  void _flagMessage() {
    // Handle flagging incorrect message
  }
}