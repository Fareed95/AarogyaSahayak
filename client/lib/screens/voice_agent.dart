import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(VoiceMedicalApp());
}

class VoiceMedicalApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Medical Assistant',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: VoiceCallScreen(),
    );
  }
}

class VoiceCallScreen extends StatefulWidget {
  @override
  _VoiceCallScreenState createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen> {
  final String baseUrl = 'http://192.168.1.100:8000'; // Replace with your actual IP
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isRecording = false;
  bool _isCallActive = false;
  bool _isProcessing = false;
  String? _sessionId;
  String _lastResponse = "Welcome! Tap the call button to start talking to Dr. Sarah.";
  WebSocketChannel? _webSocketChannel;
  String? _currentRecordingPath;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await Permission.microphone.request();
  }

  // Start call
  Future<void> _startCall() async {
    try {
      setState(() => _isProcessing = true);

      final response = await http.post(
        Uri.parse('$baseUrl/start-call'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'user_id': 'flutter_user_${DateTime.now().millisecondsSinceEpoch}'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _sessionId = data['session_id'];
            _isCallActive = true;
            _lastResponse = data['greeting'];
          });

          if (data['audio_greeting'] != null && data['audio_greeting'].isNotEmpty) {
            await _playAudioFromBase64(data['audio_greeting']);
          }

          _initWebSocket();
        } else {
          _showError(data['message'] ?? 'Failed to start call');
        }
      } else {
        _showError('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Failed to start call: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  // Initialize WebSocket for real-time communication
  void _initWebSocket() {
    if (_sessionId != null) {
      try {
        _webSocketChannel = IOWebSocketChannel.connect(
          'ws://192.168.1.100:8000/ws/voice-call/$_sessionId',
        );

        _webSocketChannel!.stream.listen(
          (data) async {
            final message = json.decode(data);
            if (message['type'] == 'response') {
              setState(() => _lastResponse = message['text']);
              if (message['audio'] != null && message['audio'].isNotEmpty) {
                await _playAudioFromBase64(message['audio']);
              }
            } else if (message['type'] == 'call_ended') {
              _endCall();
            }
          },
          onError: (error) => _showError('WebSocket error: $error'),
        );
      } catch (e) {
        _showError('Failed to connect WebSocket: $e');
      }
    }
  }

  // Recording audio - SIMPLIFIED VERSION FOR NOW
  Future<void> _startRecording() async {
    try {
      final status = await Permission.microphone.status;
      if (!status.isGranted) {
        await Permission.microphone.request();
        if (!(await Permission.microphone.status.isGranted)) {
          return _showError('Microphone permission denied');
        }
      }

      final directory = await getTemporaryDirectory();
      _currentRecordingPath = '${directory.path}/voice_message_${DateTime.now().millisecondsSinceEpoch}.m4a';

      // For now, we'll just simulate recording since we don't have a recorder
      setState(() => _isRecording = true);
      
      // In a real app, you'd use a proper audio recording package here
      print('Recording started at: $_currentRecordingPath');
      
    } catch (e) {
      _showError('Failed to start recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      setState(() {
        _isRecording = false;
        _isProcessing = true;
      });

      // Simulate recording stop - in real app, you'd get the actual audio file
      if (_currentRecordingPath != null) {
        // Create a dummy audio file for testing
        final dummyFile = File(_currentRecordingPath!);
        await dummyFile.writeAsBytes(List.generate(1000, (index) => index % 256));
        
        await _sendVoiceMessage(_currentRecordingPath!);
      } else {
        setState(() => _isProcessing = false);
        _showError('No audio recorded');
      }
    } catch (e) {
      setState(() {
        _isRecording = false;
        _isProcessing = false;
      });
      _showError('Failed to stop recording: $e');
    }
  }

  // Send voice message
  Future<void> _sendVoiceMessage(String audioPath) async {
    try {
      final audioFile = File(audioPath);
      if (!audioFile.existsSync()) return _showError('Audio file not found');

      final audioBytes = await audioFile.readAsBytes();
      final audioBase64 = base64Encode(audioBytes);

      if (_webSocketChannel != null) {
        _webSocketChannel!.sink.add(json.encode({'type': 'audio', 'audio_data': audioBase64}));
      } else {
        final response = await http.post(
          Uri.parse('$baseUrl/voice-chat'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'user_id': 'flutter_user', 'audio_data': audioBase64, 'session_id': _sessionId}),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['success']) {
            setState(() => _lastResponse = data['response_text']);
            if (data['audio_response'] != null && data['audio_response'].isNotEmpty) {
              await _playAudioFromBase64(data['audio_response']);
            }
          } else {
            _showError(data['response_text']);
          }
        } else {
          _showError('Server error: ${response.statusCode}');
        }
      }

      if (audioFile.existsSync()) audioFile.deleteSync();
    } catch (e) {
      _showError('Failed to send voice message: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  // Play audio from base64
  Future<void> _playAudioFromBase64(String audioBase64) async {
    try {
      if (audioBase64.isEmpty) return;
      final audioBytes = base64Decode(audioBase64);
      final directory = await getTemporaryDirectory();
      final audioFile = File('${directory.path}/response_audio_${DateTime.now().millisecondsSinceEpoch}.wav');
      await audioFile.writeAsBytes(audioBytes);
      await _audioPlayer.play(UrlSource(audioFile.path));

      Future.delayed(Duration(seconds: 10), () {
        if (audioFile.existsSync()) audioFile.deleteSync();
      });
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  // End call
  Future<void> _endCall() async {
    try {
      if (_sessionId != null) {
        await http.post(
          Uri.parse('$baseUrl/end-call'),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {'session_id': _sessionId},
        );
      }

      _webSocketChannel?.sink.close();

      setState(() {
        _isCallActive = false;
        _sessionId = null;
        _lastResponse = "Call ended. Tap the call button to start a new conversation.";
      });
    } catch (e) {
      _showError('Failed to end call: $e');
    }
  }

  // Show error snackbar
  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red, duration: Duration(seconds: 3)),
      );
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _webSocketChannel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dr. Sarah - Voice Assistant'),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade700, Colors.blue.shade50],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildCallStatus(),
                SizedBox(height: 30),
                _buildResponseBox(),
                SizedBox(height: 30),
                _buildCallButtons(),
                SizedBox(height: 20),
                if (_isCallActive) _buildMicButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCallStatus() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isCallActive ? Colors.green.shade100 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isCallActive ? Colors.green : Colors.grey,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(_isCallActive ? Icons.phone_in_talk : Icons.phone_disabled,
              color: _isCallActive ? Colors.green : Colors.grey),
          SizedBox(width: 12),
          Text(
            _isCallActive ? 'Connected to Dr. Sarah' : 'Not Connected',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _isCallActive ? Colors.green.shade800 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseBox() {
    return Expanded(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [  // FIXED: Changed {} to []
                Icon(Icons.medical_services, color: Colors.blue.shade600),
                SizedBox(width: 8),
                Text(
                  'Dr. Sarah',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade600),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_lastResponse, style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey.shade800)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        !_isCallActive
            ? ElevatedButton.icon(
                onPressed: _isProcessing ? null : _startCall,
                icon: _isProcessing
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                      )
                    : Icon(Icons.phone, size: 24),
                label: Text('Start Call', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              )
            : ElevatedButton.icon(
                onPressed: _endCall,
                icon: Icon(Icons.call_end, size: 24),
                label: Text('End Call', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
      ],
    );
  }

  Widget _buildMicButton() {
    return Column(
      children: [
        GestureDetector(
          onTapDown: (_) => _startRecording(),
          onTapUp: (_) => _stopRecording(),
          onTapCancel: () => _stopRecording(),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _isRecording ? Colors.red : Colors.blue.shade600,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (_isRecording ? Colors.red : Colors.blue.shade600).withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: _isRecording ? 5 : 2,
                ),
              ],
            ),
            child: Icon(_isRecording ? Icons.mic : Icons.mic_none, color: Colors.white, size: 36),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Text(
            _isRecording
                ? 'Recording... Release to send'
                : _isProcessing
                    ? 'Processing...'
                    : 'Hold to speak',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ),
      ],
    );
  }
}