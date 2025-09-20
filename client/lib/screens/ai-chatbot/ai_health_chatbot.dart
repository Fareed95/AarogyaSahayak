import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/chat_header_widget.dart';
import './widgets/chat_input_widget.dart';
import './widgets/chat_message_widget.dart';
import './widgets/disclaimer_widget.dart';
import './widgets/typing_indicator_widget.dart';
import 'widgets/chat_header_widget.dart';
import 'widgets/chat_input_widget.dart';
import 'widgets/chat_message_widget.dart';
import 'widgets/disclaimer_widget.dart';
import 'widgets/typing_indicator_widget.dart';

class AiHealthChatbot extends StatefulWidget {
  const AiHealthChatbot({super.key});

  @override
  State<AiHealthChatbot> createState() => _AiHealthChatbotState();
}

class _AiHealthChatbotState extends State<AiHealthChatbot>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;
  bool _isOnline = true;
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;

  // Mock conversation data
  final List<Map<String, dynamic>> _mockConversations = [
    {
      'id': 1,
      'content':
          'Hello! I\'m your AI Health Assistant. How can I help you with your health concerns today?',
      'isUser': false,
      'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
      'type': 'text',
    },
    {
      'id': 2,
      'content':
          'I have been experiencing headaches for the past few days. What could be the cause?',
      'isUser': true,
      'timestamp': DateTime.now().subtract(const Duration(minutes: 4)),
      'type': 'text',
    },
    {
      'id': 3,
      'content':
          'Headaches can have various causes including stress, dehydration, lack of sleep, or eye strain. Here are some recommendations:',
      'isUser': false,
      'timestamp': DateTime.now().subtract(const Duration(minutes: 3)),
      'type': 'rich',
      'actions': [
        {'title': 'Track Symptoms', 'type': 'vitals'},
        {'title': 'Set Reminder', 'type': 'reminder'},
        {'title': 'Find Health Worker', 'type': 'appointment'},
      ],
    },
  ];

  final List<Map<String, dynamic>> _aiResponses = [
    {
      'content':
          'Based on your symptoms, I recommend monitoring your blood pressure and staying hydrated. Would you like me to set up a reminder for you?',
      'type': 'rich',
      'actions': [
        {'title': 'Set BP Reminder', 'type': 'reminder'},
        {'title': 'Track Vitals', 'type': 'vitals'},
      ],
    },
    {
      'content':
          'For diabetes management, it\'s important to monitor your blood sugar regularly and maintain a balanced diet. Here are some tips:',
      'type': 'rich',
      'actions': [
        {'title': 'Nutrition Guide', 'type': 'nutrition'},
        {'title': 'Set Meal Reminder', 'type': 'reminder'},
      ],
    },
    {
      'content':
          'Your symptoms suggest you should consult a health worker immediately. This could be a medical emergency.',
      'type': 'emergency',
    },
    {
      'content':
          'Regular exercise is crucial for managing chronic conditions. Start with 15-20 minutes of walking daily and gradually increase.',
      'type': 'text',
    },
    {
      'content':
          'Medication adherence is very important. Would you like me to help you set up reminders for your medications?',
      'type': 'rich',
      'actions': [
        {'title': 'Set Med Reminder', 'type': 'reminder'},
        {'title': 'Track Medications', 'type': 'vitals'},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadConversationHistory();
    _checkConnectivity();
  }

  void _initializeAnimations() {
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimationController.forward();
  }

  void _loadConversationHistory() {
    setState(() {
      _messages.addAll(_mockConversations);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isOnline = connectivityResult != ConnectivityResult.none;
    });

    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _isOnline = result != ConnectivityResult.none;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            ChatHeaderWidget(
              onClearChat: _clearChat,
              onExportChat: _exportChat,
              isOnline: _isOnline,
            ),
            Expanded(
              child: _buildChatArea(),
            ),
            if (_isTyping) const TypingIndicatorWidget(),
            ChatInputWidget(
              onSendMessage: _handleSendMessage,
              onVoiceMessage: _handleVoiceMessage,
            ),
            const DisclaimerWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatArea() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.lightTheme.scaffoldBackgroundColor,
            AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.5),
          ],
        ),
      ),
      child: _messages.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(vertical: 2.h),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatMessageWidget(
                  message: message,
                  isUser: message['isUser'] as bool? ?? false,
                  onCopy: () => _showToast('Message copied to clipboard'),
                  onShare: () => _shareMessage(message),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: CustomIconWidget(
              iconName: 'smart_toy',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 40,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'AI Health Assistant',
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Ask me about your health concerns,\nsymptoms, or medication reminders',
            style: GoogleFonts.roboto(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.6),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _handleSendMessage(String message) {
    if (message.trim().isEmpty) return;

    // Add user message
    final userMessage = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'content': message,
      'isUser': true,
      'timestamp': DateTime.now(),
      'type': 'text',
    };

    setState(() {
      _messages.add(userMessage);
      _isTyping = true;
    });

    _scrollToBottom();

    // Simulate AI response
    Future.delayed(const Duration(milliseconds: 1500), () {
      _generateAIResponse(message);
    });
  }

  void _handleVoiceMessage(String audioPath) {
    // Simulate voice-to-text conversion
    final transcribedText =
        'I have been feeling dizzy lately and my blood pressure seems high';
    _handleSendMessage(transcribedText);
    _showToast('Voice message transcribed');
  }

  void _generateAIResponse(String userMessage) {
    final lowercaseMessage = userMessage.toLowerCase();
    Map<String, dynamic> aiResponse;

    // Detect emergency keywords
    if (_containsEmergencyKeywords(lowercaseMessage)) {
      aiResponse = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'content':
            'Your symptoms suggest you should consult a health worker immediately. This could be a medical emergency.',
        'isUser': false,
        'timestamp': DateTime.now(),
        'type': 'emergency',
      };
    } else {
      // Select appropriate response based on keywords
      final responseIndex = _selectResponseIndex(lowercaseMessage);
      final selectedResponse = _aiResponses[responseIndex];

      aiResponse = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'content': selectedResponse['content'],
        'isUser': false,
        'timestamp': DateTime.now(),
        'type': selectedResponse['type'],
        if (selectedResponse['actions'] != null)
          'actions': selectedResponse['actions'],
      };
    }

    setState(() {
      _isTyping = false;
      _messages.add(aiResponse);
    });

    _scrollToBottom();
  }

  bool _containsEmergencyKeywords(String message) {
    final emergencyKeywords = [
      'chest pain',
      'heart attack',
      'stroke',
      'unconscious',
      'bleeding',
      'severe pain',
      'difficulty breathing',
      'emergency',
      'urgent'
    ];

    return emergencyKeywords.any((keyword) => message.contains(keyword));
  }

  int _selectResponseIndex(String message) {
    if (message.contains('blood pressure') || message.contains('bp')) {
      return 0;
    } else if (message.contains('diabetes') || message.contains('sugar')) {
      return 1;
    } else if (message.contains('exercise') || message.contains('workout')) {
      return 3;
    } else if (message.contains('medication') || message.contains('medicine')) {
      return 4;
    }
    return 0; // Default response
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Clear Chat History',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to clear all chat messages? This action cannot be undone.',
          style: GoogleFonts.roboto(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.roboto(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _messages.clear();
              });
              _showToast('Chat history cleared');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: Text(
              'Clear',
              style: GoogleFonts.roboto(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _exportChat() {
    final chatContent = _messages.map((message) {
      final sender =
          (message['isUser'] as bool? ?? false) ? 'You' : 'AI Assistant';
      final timestamp = (message['timestamp'] as DateTime).toString();
      final content = message['content'] as String? ?? '';
      return '$sender [$timestamp]: $content';
    }).join('\n\n');

    // For demonstration, we'll show a dialog with export options
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Export Chat',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Chat conversation has been prepared for export. You can share this with your health worker.',
          style: GoogleFonts.roboto(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.roboto(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showToast('Chat exported successfully');
            },
            child: Text(
              'Export',
              style: GoogleFonts.roboto(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _shareMessage(Map<String, dynamic> message) {
    final content = message['content'] as String? ?? '';
    _showToast(
        'Message shared: ${content.substring(0, content.length > 30 ? 30 : content.length)}...');
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.roboto(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: EdgeInsets.all(4.w),
      ),
    );
  }
}