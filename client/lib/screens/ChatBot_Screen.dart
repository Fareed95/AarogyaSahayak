import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ✅ Update yaha path
import 'package:client/services/secure_storage_service.dart';

class ChatBotScreen
    extends
        StatefulWidget {
  const ChatBotScreen({
    Key? key,
  }) : super(
         key: key,
       );

  @override
  State<
    ChatBotScreen
  >
  createState() => _ChatBotScreenState();
}

class _ChatBotScreenState
    extends
        State<
          ChatBotScreen
        > {
  final TextEditingController _controller = TextEditingController();
  final SecureStorageService _storageService = SecureStorageService();

  List<
    Map<
      String,
      String
    >
  >
  messages = [];
  bool isLoading = false;

  Future<
    void
  >
  sendMessage(
    String message,
  ) async {
    if (message.trim().isEmpty) return;

    setState(
      () {
        messages.add(
          {
            "sender": "user",
            "text": message,
          },
        );
        isLoading = true;
      },
    );

    try {
      String? token = await _storageService.getJwtToken();
      print(
        "Retrieved JWT Token: $token",
      );
      if (token ==
          null)
        throw Exception(
          "JWT Token not found",
        );

      final response = await http.post(
        Uri.parse(
          "http://192.168.0.107:8000/api/reports/chatbot/",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": token,
        },
        body: jsonEncode(
          {
            "message": message,
          },
        ),
      );

      // 🔹 DEBUG: print full response
      print(
        "Status Code: ${response.statusCode}",
      );
      print(
        "Response Body: ${response.body}",
      );

      if (response.statusCode ==
          200) {
        final data = jsonDecode(
          response.body,
        );
        String agentReply =
            data['response'] ??
            "No reply";

        setState(
          () {
            messages.add(
              {
                "sender": "agent",
                "text": agentReply,
              },
            );
          },
        );
      } else {
        // Show full server error message
        setState(
          () {
            messages.add(
              {
                "sender": "agent",
                "text": "Error ${response.statusCode}: ${response.body}",
              },
            );
          },
        );
      }
    } catch (
      e
    ) {
      setState(
        () {
          messages.add(
            {
              "sender": "agent",
              "text": "Error: $e",
            },
          );
        },
      );
    } finally {
      setState(
        () {
          isLoading = false;
        },
      );
    }
  }

  Widget buildMessage(
    Map<
      String,
      String
    >
    msg,
  ) {
    bool isUser =
        msg["sender"] ==
        "user";
    return Align(
      alignment: isUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 12,
        ),
        margin: const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? Colors.blue
              : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(
            12,
          ),
        ),
        child: Text(
          msg["text"] ??
              "",
          style: TextStyle(
            color: isUser
                ? Colors.white
                : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chat with Agent",
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder:
                  (
                    context,
                    index,
                  ) => buildMessage(
                    messages[index],
                  ),
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(
                8.0,
              ),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(
              8.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Type your message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.send,
                  ),
                  onPressed: () {
                    sendMessage(
                      _controller.text,
                    );
                    _controller.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
