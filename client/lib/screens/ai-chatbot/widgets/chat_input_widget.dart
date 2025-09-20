import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class ChatInputWidget extends StatefulWidget {
  final Function(String) onSendMessage;
  final Function(String) onVoiceMessage;
  final VoidCallback? onSuggestionTap;

  const ChatInputWidget({
    super.key,
    required this.onSendMessage,
    required this.onVoiceMessage,
    this.onSuggestionTap,
  });

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final AudioRecorder _audioRecorder = AudioRecorder();

  bool _isRecording = false;
  bool _hasText = false;
  late AnimationController _recordingAnimationController;
  late Animation<double> _recordingAnimation;

  final List<String> _quickSuggestions = [
    'Check symptoms',
    'Medication reminders',
    'Diet advice',
    'Exercise tips',
    'Blood pressure',
    'Diabetes care',
  ];

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);

    _recordingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _recordingAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _recordingAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _recordingAnimationController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _textController.text.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildQuickSuggestions(),
            _buildInputRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSuggestions() {
    return Container(
      height: 6.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _quickSuggestions.length,
        separatorBuilder: (context, index) => SizedBox(width: 2.w),
        itemBuilder: (context, index) {
          return _buildSuggestionChip(_quickSuggestions[index]);
        },
      ),
    );
  }

  Widget _buildSuggestionChip(String suggestion) {
    return GestureDetector(
      onTap: () => _handleSuggestionTap(suggestion),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          suggestion,
          style: GoogleFonts.roboto(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildInputRow() {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _handleSendMessage,
                      decoration: InputDecoration(
                        hintText: 'Type your health question...',
                        hintStyle: GoogleFonts.roboto(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 2.h,
                        ),
                      ),
                      style: GoogleFonts.roboto(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  _buildVoiceButton(),
                ],
              ),
            ),
          ),
          SizedBox(width: 2.w),
          _buildSendButton(),
        ],
      ),
    );
  }

  Widget _buildVoiceButton() {
    return GestureDetector(
      onTap: _hasText ? null : _toggleRecording,
      child: Container(
        padding: EdgeInsets.all(2.w),
        child: AnimatedBuilder(
          animation: _recordingAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _isRecording ? _recordingAnimation.value : 1.0,
              child: Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: _isRecording
                      ? AppTheme.lightTheme.colorScheme.error
                      : (_hasText
                          ? AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.3)
                          : AppTheme.lightTheme.colorScheme.primary),
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: _isRecording ? 'stop' : 'mic',
                  color: Colors.white,
                  size: 16,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return GestureDetector(
      onTap: _hasText ? () => _handleSendMessage(_textController.text) : null,
      child: Container(
        width: 12.w,
        height: 12.w,
        decoration: BoxDecoration(
          color: _hasText
              ? AppTheme.lightTheme.colorScheme.secondary
              : AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: CustomIconWidget(
          iconName: 'send',
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  void _handleSuggestionTap(String suggestion) {
    _textController.text = suggestion;
    _focusNode.requestFocus();
    if (widget.onSuggestionTap != null) {
      widget.onSuggestionTap!();
    }
  }

  void _handleSendMessage(String message) {
    if (message.trim().isNotEmpty) {
      widget.onSendMessage(message.trim());
      _textController.clear();
      setState(() {
        _hasText = false;
      });
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      if (!kIsWeb) {
        final permission = await Permission.microphone.request();
        if (!permission.isGranted) {
          return;
        }
      }

      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start(const RecordConfig(),
            path: 'audio_recording.m4a');

        setState(() {
          _isRecording = true;
        });

        _recordingAnimationController.repeat(reverse: true);
      }
    } catch (e) {
      // Handle recording error silently
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();

      setState(() {
        _isRecording = false;
      });

      _recordingAnimationController.stop();
      _recordingAnimationController.reset();

      if (path != null) {
        widget.onVoiceMessage(path);
      }
    } catch (e) {
      // Handle stop recording error silently
      setState(() {
        _isRecording = false;
      });
      _recordingAnimationController.stop();
      _recordingAnimationController.reset();
    }
  }
}