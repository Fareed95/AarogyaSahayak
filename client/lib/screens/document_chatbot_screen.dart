// document_chatbot_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DocumentChatBotScreen extends StatefulWidget {
  const DocumentChatBotScreen({super.key});

  @override
  _DocumentChatBotScreenState createState() => _DocumentChatBotScreenState();
}

class _DocumentChatBotScreenState extends State<DocumentChatBotScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  /// Backend URL - change to your PC IP if running on a real device
  final String _apiUrl = "http://10.0.2.2:1000/process_image_ocr/";

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _messages.add({
            'type': 'image',
            'content': File(image.path),
            'isUser': true,
            'time': DateTime.now(),
          });
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a document first')),
      );
      return;
    }

    final userMessage = _messageController.text.trim();
    if (userMessage.isNotEmpty) {
      setState(() {
        _messages.add({
          'type': 'text',
          'content': userMessage,
          'isUser': true,
          'time': DateTime.now(),
        });
      });
    }

    _messageController.clear();

    setState(() => _isLoading = true);

    try {
      var request = http.MultipartRequest("POST", Uri.parse(_apiUrl));

      request.files.add(
        await http.MultipartFile.fromPath("image", _selectedImage!.path),
      );

      if (userMessage.isNotEmpty) {
        request.fields["prompt"] = userMessage;
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        var data = jsonDecode(responseBody);

        // Add extracted text (only first time after image upload)
        if (data["extracted_text"] != null && userMessage.isEmpty) {
          setState(() {
            _messages.add({
              'type': 'text',
              'content': "📄 Extracted: ${data["extracted_text"]}",
              'isUser': false,
              'time': DateTime.now(),
            });
          });
        }

        // Add AI response
        if (data["ai_response"] != null) {
          setState(() {
            _messages.add({
              'type': 'text',
              'content': "🤖 ${data["ai_response"]}",
              'isUser': false,
              'time': DateTime.now(),
            });
          });
        }
      } else {
        setState(() {
          _messages.add({
            'type': 'text',
            'content': "❌ Error: ${response.statusCode}",
            'isUser': false,
            'time': DateTime.now(),
          });
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({
          'type': 'text',
          'content': "⚠️ Failed: $e",
          'isUser': false,
          'time': DateTime.now(),
        });
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Assistant'),
        backgroundColor: const Color(0xFF14213D),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      alignment:
          message['isUser'] ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message['isUser']
              ? const Color(0xFF14213D).withOpacity(0.8)
              : const Color(0xFFFCA311).withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: message['type'] == 'image'
            ? Image.file(message['content'],
                width: 200, height: 200, fit: BoxFit.cover)
            : Text(
                message['content'],
                style: TextStyle(
                  color: message['isUser'] ? Colors.white : Colors.black,
                ),
              ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.camera_alt, color: Color(0xFF14213D)),
            onPressed: _pickImage,
            tooltip: 'Upload document',
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Ask about your document...',
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFF14213D)),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
