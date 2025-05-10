import 'dart:async';

import 'package:flutter/material.dart';

class ExamPrepChat extends StatefulWidget {
  @override
  _ExamPrepChatState createState() => _ExamPrepChatState();
}

class _ExamPrepChatState extends State<ExamPrepChat> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {'sender': 'bot', 'message': 'Hello, I’m your Exam Preparation Assistant! How can I help you today? 😊'},
  ];

  void _sendMessage(String text) {
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'message': text});
      _controller.clear();
    });

    // Simulate bot's response
    Timer(Duration(seconds: 1), () {
      setState(() {
        String botResponse = _getExamPreparationRecommendation(text);
        _messages.add({'sender': 'bot', 'message': botResponse});
      });
    });
  }

  String _getExamPreparationRecommendation(String userInput) {
    userInput = userInput.toLowerCase();

    if (userInput.contains("math") || userInput.contains("algebra")) {
      return "Math Exam Preparation: \n1. Algebra Basics\n2. Calculus for Beginners\n3. Trigonometry Practice";
    } else if (userInput.contains("science") || userInput.contains("physics")) {
      return "Science Exam Preparation: \n1. Physics Basics\n2. Chemistry Concepts\n3. Biology Introduction";
    } else if (userInput.contains("history") || userInput.contains("geography")) {
      return "History & Geography Exam Preparation: \n1. World History\n2. Geography for Beginners\n3. Civilizations Overview";
    } else {
      return "I’m here to help! Ask about exam prep for Math, Science, History, or Geography.";
    }
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
                backgroundColor: Colors.green[300],
                child: Icon(Icons.school, size: 16, color: Colors.white),
              ),
            ),
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              margin: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              decoration: BoxDecoration(
                color: isUser ? Colors.yellowAccent[100] : Colors.green[100],
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
                color: Colors.green[200],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.green,
                    child: Icon(Icons.school, color: Colors.white),
                  ),
                  SizedBox(width: 20),
                  Text(
                    'Exam Preparation Assistant',
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
                        hintText: 'Ask about exam preparation...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.greenAccent),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.greenAccent),
                    onPressed: () => _sendMessage(_controller.text),
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
