// lib/screens/cart_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http_parser/http_parser.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final ImagePicker picker = ImagePicker();
  final AudioRecorder _recorder = AudioRecorder();

  bool _isRecording = false;
  String? _audioPath;
  final ScrollController _scrollController = ScrollController();
  bool _isWaitingForResponse = false;
  WebSocketChannel? _voiceChannel;
  String? _callSessionId;

  final String serverIP = "192.168.0.100";
  final int serverPort = 8000;

  @override
  void initState() {
    super.initState();
    _initRecorder();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _messages.add({
          "role": "assistant",
          "content": "I'm CodeNebula AI. How can I assist you today?"
        });
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _recorder.dispose();
    _scrollController.dispose();
    _disconnectFromVoiceCall();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // ---------- Voice Call ----------
  Future<void> _startCall() async {
    setState(() {
      _isWaitingForResponse = true;
    });

    try {
      var response = await http.post(
        Uri.parse("http://$serverIP:$serverPort/start-call"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"user_id": "user_${DateTime.now().millisecondsSinceEpoch}"}),
      );

      if (response.statusCode != 200) {
        setState(() {
          _messages.add({
            "role": "assistant",
            "content": "Failed to start call: ${response.statusCode}"
          });
          _isWaitingForResponse = false;
        });
        return;
      }

      var data = json.decode(response.body);
      _callSessionId = data['session_id'];
      
      // Connect to WebSocket for real-time voice
      _connectToVoiceCall(_callSessionId!);
      
      // Play greeting audio if available
      if (data['audio_greeting'] != null) {
        // You'll need to implement audio playback here
      }

    } catch (e) {
      setState(() {
        _messages.add({
          "role": "assistant",
          "content": "Call start error: ${e.toString()}"
        });
        _isWaitingForResponse = false;
      });
    }
  }

  Future<void> _endCall() async {
    if (_callSessionId != null) {
      try {
        var response = await http.post(
          Uri.parse("http://$serverIP:$serverPort/end-call"),
          headers: {"Content-Type": "application/json"},
          body: json.encode({"session_id": _callSessionId}),
        );

        if (response.statusCode != 200) {
          // Handle error
        }
      } catch (e) {
        // Handle error
      }
    }
    _disconnectFromVoiceCall();
    setState(() {
      _callSessionId = null;
    });
  }

  void _connectToVoiceCall(String sessionId) {
    try {
      _voiceChannel = IOWebSocketChannel.connect(
        'ws://$serverIP:$serverPort/ws/voice-call/$sessionId',
      );

      _voiceChannel!.stream.listen((data) {
        final message = json.decode(data);
        if (message['type'] == 'response') {
          // Handle AI response
          setState(() {
            _messages.add({
              "role": "assistant",
              "content": message['text'] ?? "No text response"
            });
          });
        }
      }, onError: (error) {
        print("WebSocket error: $error");
      });
    } catch (e) {
      print("WebSocket connection error: $e");
    }
  }

  void _disconnectFromVoiceCall() {
    if (_voiceChannel != null) {
      _voiceChannel!.sink.close();
      _voiceChannel = null;
    }
  }

  Future<void> _initRecorder() async {
    try {
      await _recorder.hasPermission();
    } catch (e) {
      print("Recorder initialization error: $e");
    }
  }

  // ---------- Text chat ----------
  Future<void> _sendText() async {
    if (_controller.text.trim().isEmpty) return;
    String userText = _controller.text.trim();
    setState(() {
      _messages.add({"role": "user", "content": userText});
      _controller.clear();
      _isWaitingForResponse = true;
    });
    _scrollToBottom();

    try {
      var response = await http.post(
        Uri.parse("http://$serverIP:$serverPort/text_chat/"),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          "message": userText,
          "conversation_id": DateTime.now().millisecondsSinceEpoch.toString(),
        },
      );

      if (response.statusCode != 200) {
        setState(() {
          _messages.add({
            "role": "assistant",
            "content": "Server error: ${response.statusCode} - ${response.body}"
          });
          _isWaitingForResponse = false;
        });
        _scrollToBottom();
        return;
      }

      var data = json.decode(response.body);
      setState(() {
        _messages.add({
          "role": "assistant",
          "content": data["ai_response"] ?? "No response from server"
        });
        _isWaitingForResponse = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add({
          "role": "assistant",
          "content": "Network error: ${e.toString()}"
        });
        _isWaitingForResponse = false;
      });
      _scrollToBottom();
    }
  }

  // ---------- Image upload ----------
  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await picker.pickImage(source: source, imageQuality: 80);
      if (pickedFile == null) return;

      File imageFile = File(pickedFile.path);

      if (!pickedFile.path.toLowerCase().endsWith('.jpg') &&
          !pickedFile.path.toLowerCase().endsWith('.jpeg') &&
          !pickedFile.path.toLowerCase().endsWith('.png') &&
          !pickedFile.path.toLowerCase().endsWith('.gif')) {
        setState(() {
          _messages.add({
            "role": "assistant",
            "content": "Please select a valid image file (JPG, PNG, GIF)"
          });
        });
        _scrollToBottom();
        return;
      }

      setState(() {
        _messages.add({"role": "user", "content": "Sent an image"});
        _isWaitingForResponse = true;
      });
      _scrollToBottom();

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://$serverIP:$serverPort/process_image_ocr/'),
      );
      request.fields['conversation_id'] =
          DateTime.now().millisecondsSinceEpoch.toString();

      String contentType = 'image/jpeg';
      if (pickedFile.path.toLowerCase().endsWith('.png')) {
        contentType = 'image/png';
      } else if (pickedFile.path.toLowerCase().endsWith('.gif')) {
        contentType = 'image/gif';
      }

      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType.parse(contentType),
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        setState(() {
          _messages.add({
            "role": "assistant",
            "content": "Image upload failed: ${response.statusCode} - ${response.body}"
          });
          _isWaitingForResponse = false;
        });
        _scrollToBottom();
        return;
      }

      var data = json.decode(response.body);
      setState(() {
        _messages.add({
          "role": "assistant",
          "content": data["ai_response"] ?? "No response from server"
        });
        _isWaitingForResponse = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add({
          "role": "assistant",
          "content": "Image send error: ${e.toString()}"
        });
        _isWaitingForResponse = false;
      });
      _scrollToBottom();
    }
  }

  // ---------- Audio recording ----------
  Future<void> _startRecording() async {
    try {
      final micStatus = await Permission.microphone.status;
      if (!micStatus.isGranted) {
        final result = await Permission.microphone.request();
        if (!result.isGranted) {
          setState(() {
            _messages.add({
              "role": "assistant",
              "content": "Microphone permission denied"
            });
          });
          _scrollToBottom();
          return;
        }
      }

      final tempDir = await getTemporaryDirectory();
      final audioPath =
          '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
          numChannels: 1,
        ),
        path: audioPath,
      );

      setState(() {
        _isRecording = true;
        _audioPath = audioPath;
      });
    } catch (e) {
      setState(() {
        _messages.add({"role": "assistant", "content": "Record start error: $e"});
      });
      _scrollToBottom();
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _recorder.stop();
      setState(() {
        _isRecording = false;
      });

      final audioPath = path ?? _audioPath;

      if (audioPath == null) {
        setState(() {
          _messages.add({
            "role": "assistant",
            "content": "Recording failed: no file path"
          });
        });
        _scrollToBottom();
        return;
      }

      File audioFile = File(audioPath);
      if (!await audioFile.exists()) {
        setState(() {
          _messages.add({
            "role": "assistant",
            "content": "Recording file not found"
          });
        });
        _scrollToBottom();
        return;
      }

      setState(() {
        _messages.add({"role": "user", "content": "Sent a voice message"});
        _isWaitingForResponse = true;
      });
      _scrollToBottom();

      // FIXED: Changed from /voice_chat/ to /process_audio/
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://$serverIP:$serverPort/process_audio/'),
      );
      request.fields['conversation_id'] =
          DateTime.now().millisecondsSinceEpoch.toString();
      request.files.add(await http.MultipartFile.fromPath(
        'audio',
        audioFile.path,
        filename: 'audio.m4a',
        contentType: MediaType('audio', 'm4a'),
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        setState(() {
          _messages.add({
            "role": "assistant",
            "content": "Audio upload failed: ${response.statusCode} - ${response.body}"
          });
          _isWaitingForResponse = false;
        });
        _scrollToBottom();
        return;
      }

      var data = json.decode(response.body);
      setState(() {
        _messages.add({
          "role": "assistant",
          "content": data["ai_response"] ?? "No response from server"
        });
        _isWaitingForResponse = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add({"role": "assistant", "content": "Audio send error: $e"});
        _isWaitingForResponse = false;
      });
      _scrollToBottom();
    }
  }

  // ---------- F1-style Chat Bubble ----------
  Widget _buildMessage(Map<String, String> msg, int index) {
    bool isUser = msg["role"] == "user";
    bool showAvatar = index == 0 || _messages[index - 1]["role"] != msg["role"];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser && showAvatar)
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 241, 1, 1).withOpacity(0.7),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: const Icon(Icons.flash_on, color: Colors.white, size: 18),
            )
          else if (!isUser)
            const SizedBox(width: 40),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isUser
                    ? LinearGradient(
                        colors: [Colors.grey[850]!, Colors.black],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight)
                    : LinearGradient(
                        colors: [const Color.fromARGB(255, 255, 0, 0), const Color.fromARGB(255, 255, 0, 0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 246, 2, 2).withOpacity(0.6),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showAvatar)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        isUser ? "You" : "CodeNebula AI",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  SelectableText(
                    msg["content"]!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 253, 2, 2),
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 246, 2, 2).withOpacity(0.7),
                  blurRadius: 8,
                  spreadRadius: 1,
                )
              ],
            ),
            child: const Icon(Icons.flash_on, color: Colors.white, size: 18),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.black, Colors.grey[900]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 222, 1, 1).withOpacity(0.6),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < 3; i++)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 249, 2, 2),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "CodeNebula AI",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.grey[900],
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, size: 22),
            onPressed: () {},
            color: Colors.white,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.black,
              child: _messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                  colors: [const Color.fromARGB(255, 252, 1, 1), const Color.fromARGB(255, 247, 3, 3)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight),
                            ),
                            child: const Icon(
                              Icons.flash_on,
                              size: 36,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "CodeNebula AI",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "How can I help you today?",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _messages.length + (_isWaitingForResponse ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < _messages.length) {
                          return _buildMessage(_messages[index], index);
                        } else {
                          return _buildTypingIndicator();
                        }
                      },
                    ),
            ),
          ),
          // Add call buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[800],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _startCall,
                  child: const Text("Start Call"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton(
                  onPressed: _endCall,
                  child: const Text("End Call"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[900],
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Colors.grey[850]!, Colors.black],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color.fromARGB(255, 245, 2, 2)),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add, size: 22),
                          color: const Color.fromARGB(255, 253, 3, 3),
                          onPressed: () {
                            showModalBottomSheet(
                              backgroundColor: Colors.grey[900],
                              context: context,
                              builder: (context) => Container(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.photo, color: Color.fromARGB(255, 254, 2, 2)),
                                      title: const Text("Photo Library",
                                          style: TextStyle(color: Colors.white)),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _pickImage(ImageSource.gallery);
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.camera_alt, color: Color.fromARGB(255, 249, 4, 4)),
                                      title: const Text("Take Photo",
                                          style: TextStyle(color: Colors.white)),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _pickImage(ImageSource.camera);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              hintText: "Message CodeNebula AI...",
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                            style: const TextStyle(color: Colors.white),
                            onSubmitted: (_) => _sendText(),
                            maxLines: null,
                          ),
                        ),
                        GestureDetector(
                          onTap: _isRecording ? _stopRecording : _startRecording,
                          child: Icon(
                            _isRecording ? Icons.stop : Icons.mic,
                            color: _isRecording ? Colors.redAccent : Colors.grey,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.redAccent, const Color.fromARGB(255, 139, 27, 27)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}