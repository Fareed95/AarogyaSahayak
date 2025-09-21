import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http_parser/http_parser.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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
  final ScrollController _scrollController = ScrollController();

  bool _isRecording = false;
  bool _isWaitingForResponse = false;
  String? _audioPath;
  WebSocketChannel? _voiceChannel;
  String? _callSessionId;

  final String serverIP = "192.168.0.100";
  final int serverPort = 8000;

  @override
  void initState() {
    super.initState();
    _initRecorder();
    _messages.add({
      "role": "assistant",
      "content": "I'm CodeNebula AI. How can I assist you today?"
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
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  // -------- Voice Call ----------
  Future<void> _startCall() async {
    setState(() => _isWaitingForResponse = true);
    try {
      final response = await http.post(
        Uri.parse("http://$serverIP:$serverPort/start-call"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"user_id": "user_${DateTime.now().millisecondsSinceEpoch}"}),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _callSessionId = data['session_id'];
        _connectToVoiceCall(_callSessionId!);
      }
    } catch (e) {
      _messages.add({"role": "assistant", "content": "Call start error: $e"});
    }
    setState(() => _isWaitingForResponse = false);
  }

  Future<void> _endCall() async {
    if (_callSessionId != null) {
      await http.post(
        Uri.parse("http://$serverIP:$serverPort/end-call"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"session_id": _callSessionId}),
      );
    }
    _disconnectFromVoiceCall();
    setState(() => _callSessionId = null);
  }

  void _connectToVoiceCall(String sessionId) {
    _voiceChannel = IOWebSocketChannel.connect(
      'ws://$serverIP:$serverPort/ws/voice-call/$sessionId',
    );
    _voiceChannel!.stream.listen((data) {
      final message = json.decode(data);
      if (message['type'] == 'response') {
        setState(() {
          _messages.add({"role": "assistant", "content": message['text'] ?? "No response"});
        });
        _scrollToBottom();
      }
    });
  }

  void _disconnectFromVoiceCall() {
    _voiceChannel?.sink.close();
    _voiceChannel = null;
  }

  Future<void> _initRecorder() async {
    await _recorder.hasPermission();
  }

  // -------- Text Chat ----------
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
      final response = await http.post(
        Uri.parse("http://$serverIP:$serverPort/text_chat/"),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {"message": userText, "conversation_id": DateTime.now().millisecondsSinceEpoch.toString()},
      );
      final data = json.decode(response.body);
      setState(() {
        _messages.add({"role": "assistant", "content": data["ai_response"] ?? "No response"});
        _isWaitingForResponse = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({"role": "assistant", "content": "Network error: $e"});
        _isWaitingForResponse = false;
      });
    }
    _scrollToBottom();
  }

  // -------- Image Upload ----------
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source, imageQuality: 80);
    if (pickedFile == null) return;
    File imageFile = File(pickedFile.path);

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://$serverIP:$serverPort/process_image_ocr/'),
    );
    request.fields['conversation_id'] = DateTime.now().millisecondsSinceEpoch.toString();
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    var response = await http.Response.fromStream(await request.send());
    final data = json.decode(response.body);
    setState(() {
      _messages.add({"role": "assistant", "content": data["ai_response"] ?? "No response"});
    });
    _scrollToBottom();
  }

  // -------- Audio Recording ----------
  Future<void> _startRecording() async {
    final tempDir = await getTemporaryDirectory();
    final audioPath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(const RecordConfig(), path: audioPath);
    setState(() {
      _isRecording = true;
      _audioPath = audioPath;
    });
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stop();
    setState(() => _isRecording = false);

    if (path == null) return;
    File audioFile = File(path);

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://$serverIP:$serverPort/process_audio/'),
    );
    request.fields['conversation_id'] = DateTime.now().millisecondsSinceEpoch.toString();
    request.files.add(await http.MultipartFile.fromPath(
      'audio',
      audioFile.path,
      filename: 'audio.m4a',
      contentType: MediaType('audio', 'm4a'),
    ));

    var response = await http.Response.fromStream(await request.send());
    final data = json.decode(response.body);
    setState(() {
      _messages.add({"role": "assistant", "content": data["ai_response"] ?? "No response"});
    });
    _scrollToBottom();
  }

  // -------- UI ----------
  Widget _buildMessage(Map<String, String> msg) {
    bool isUser = msg["role"] == "user";
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isUser ? Colors.blueAccent : Colors.grey[700],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(msg["content"] ?? "", style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("CodeNebula AI")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, i) => _buildMessage(_messages[i]),
            ),
          ),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.photo), onPressed: () => _pickImage(ImageSource.gallery)),
              IconButton(
                icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                onPressed: _isRecording ? _stopRecording : _startRecording,
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(hintText: "Message..."),
                  onSubmitted: (_) => _sendText(),
                ),
              ),
              IconButton(icon: const Icon(Icons.send), onPressed: _sendText),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: _startCall, child: const Text("Start Call")),
              const SizedBox(width: 10),
              ElevatedButton(onPressed: _endCall, child: const Text("End Call")),
            ],
          ),
        ],
      ),
    );
  }
}