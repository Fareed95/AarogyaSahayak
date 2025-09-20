import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'voice_agent.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String baseUrl = 'http://127.0.0.1:8000'; // Change to your backend URL
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  List<Map<String, dynamic>> messages = [
    {"text": "Welcome! Tap the call button to talk to Dr. Sarah.", "isUser": false}
  ];

  bool _isProcessing = false;

  // ---------------- Text message ----------------
  Future<void> _sendTextMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.add({"text": text, "isUser": true});
      _textController.clear();
      _isProcessing = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/text_chat/'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'conversation_id': 'flutter_chat',
          'message': text,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          messages.add({"text": data['ai_response'], "isUser": false});
        });
      } else {
        _showError('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Failed to send text: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  // ---------------- Image message ----------------
  Future<void> _sendImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() {
      messages.add({"text": "[Image sent]", "isUser": true});
      _isProcessing = true;
    });

    try {
      final bytes = await pickedFile.readAsBytes();
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/process_image_ocr/'));
      request.fields['conversation_id'] = 'flutter_chat';
      request.files.add(http.MultipartFile.fromBytes('image', bytes, filename: pickedFile.name));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String extracted = data['extracted_text'] ?? '';
        String aiResponse = data['ai_response'] ?? '';
        setState(() {
          if (extracted.isNotEmpty) {
            messages.add({"text": "[Extracted Text]: $extracted", "isUser": false});
          }
          messages.add({"text": aiResponse, "isUser": false});
        });
      } else {
        _showError('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Failed to send image: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  // ---------------- Chat bubble widget ----------------
  Widget _buildChatBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue.shade600 : Colors.grey.shade300,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(color: isUser ? Colors.white : Colors.black87),
        ),
      ),
    );
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dr. Sarah - Voice & AI Assistant'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  return _buildChatBubble(msg["text"], msg["isUser"]);
                },
              ),
            ),
            if (_isProcessing)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image, color: Colors.green),
                  onPressed: _sendImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: "Type a message",
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: () => _sendTextMessage(_textController.text),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.phone),
              label: const Text("Start Voice Call"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VoiceCallScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
