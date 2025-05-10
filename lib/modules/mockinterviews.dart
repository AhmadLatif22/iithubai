import 'dart:async';
import 'package:flutter/material.dart';

class MockInterviewChat extends StatefulWidget {
  @override
  _MockInterviewChatState createState() => _MockInterviewChatState();
}

class _MockInterviewChatState extends State<MockInterviewChat> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {'sender': 'bot', 'message': 'Hi, I’m your Mock Interview Assistant! How can I help you today? 😊'},
  ];

  // Simulate an AI response with a delay.
  Future<void> _simulateResponse(String userInput) async {
    await Future.delayed(Duration(seconds: 1));
    String simulatedResponse =
        "Mock Interview AI: Let’s discuss '$userInput' in your mock interview.";
    setState(() {
      _messages.add({'sender': 'bot', 'message': simulatedResponse});
    });
  }

  void _sendMessage() {
    if (_controller.text.isEmpty) return;
    setState(() {
      _messages.add({'sender': 'user', 'message': _controller.text});
    });
    _simulateResponse(_controller.text);
    _controller.clear();
  }

  Widget _buildMessage(String sender, String message) {
    final isUser = sender == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment:
        isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                radius: 14,
                backgroundColor: Colors.orange[300],
                child: Icon(Icons.smart_toy, size: 16, color: Colors.white),
              ),
            ),
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              margin: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              decoration: BoxDecoration(
                color: isUser ? Colors.pink[100] : Colors.orange[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.orange[200],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.smart_toy, color: Colors.white),
                  ),
                  SizedBox(width: 20),
                  Text(
                    'Mock Interview Assistant',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.only(top: 10),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _buildMessage(msg['sender']!, msg['message']!);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Ask a mock interview question...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.orangeAccent),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.orangeAccent),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
