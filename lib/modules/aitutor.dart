
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AITutorChat extends StatefulWidget {
  // Add a parameter to accept studentId explicitly
  final String? studentId;

  // Constructor with optional studentId parameter
  const AITutorChat({super.key, this.studentId});

  @override
  _AITutorChatState createState() => _AITutorChatState();
}

class _AITutorChatState extends State<AITutorChat> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> _messages = [
    {'sender': 'bot', 'message': 'Hi, I am AI Tutor! How can I help you today? 😊', 'timestamp': DateTime.now().toIso8601String()},
  ];

  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isLoading = false;
  bool _isLoadingHistory = true;

  // Firebase instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Student ID for logged-in students
  String? _studentId;

  // Conversation ID to group messages
  String _conversationId = '';

  // Student info
  String _studentName = '';
  String _studentSemester = '';

  // Gemini API key
  final String _apiKey = 'AIzaSyDu4hwJ701gyYElEQEKQfEQPct9549RGjY';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    // First check if studentId was passed in constructor
    if (widget.studentId != null) {
      _studentId = widget.studentId;
    } else {
      // Check if user is authenticated
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        // Extract roll number from email (email format is rollnumber@iit.com)
        _studentId = currentUser.email?.split('@')[0];
      } else {
        // Fallback to anonymous ID if needed
        final prefs = await SharedPreferences.getInstance();
        _studentId = prefs.getString('anonymous_user_id') ?? const Uuid().v4();
        await prefs.setString('anonymous_user_id', _studentId!);
      }
    }

    // Load student information if authenticated
    if (_auth.currentUser != null) {
      await _loadStudentInfo();
    }

    // Create or retrieve existing conversation
    final prefs = await SharedPreferences.getInstance();
    String convPrefKey = 'current_conversation_id_$_studentId';
    _conversationId = prefs.getString(convPrefKey) ?? const Uuid().v4();
    await prefs.setString(convPrefKey, _conversationId);

    // Load chat history
    await _loadChatHistory();
  }

  Future<void> _loadStudentInfo() async {
    try {
      if (_studentId != null) {
        final docSnapshot = await _firestore.collection('users').doc(_studentId).get();
        if (docSnapshot.exists) {
          final data = docSnapshot.data();
          if (data != null) {
            setState(() {
              _studentName = '${data['firstName']} ${data['lastName']}';
              _studentSemester = data['semester'] ?? '';
            });
          }
        }
      }
    } catch (e) {
      print('Error loading student info: $e');
    }
  }

  Future<void> _loadChatHistory() async {
    try {
      setState(() {
        _isLoadingHistory = true;
      });

      final snapshot = await _firestore
          .collection('users')
          .doc(_studentId)
          .collection('conversations')
          .doc(_conversationId)
          .collection('messages')
          .orderBy('timestamp')
          .get();

      if (snapshot.docs.isNotEmpty) {
        List<Map<String, String>> loadedMessages = [];
        for (var doc in snapshot.docs) {
          final data = doc.data();
          loadedMessages.add({
            'sender': data['sender'] as String,
            'message': data['message'] as String,
            'timestamp': data['timestamp'] as String,
          });
        }

        if (loadedMessages.isNotEmpty) {
          setState(() {
            _messages = loadedMessages;
          });
        }
      }
    } catch (e) {
      print('Error loading chat history: $e');
    } finally {
      setState(() {
        _isLoadingHistory = false;
      });
    }
  }

  Future<void> _saveMessage(Map<String, String> message) async {
    try {
      await _firestore
          .collection('users')
          .doc(_studentId)
          .collection('conversations')
          .doc(_conversationId)
          .collection('messages')
          .add({
        'sender': message['sender'],
        'message': message['message'],
        'timestamp': message['timestamp'] ?? DateTime.now().toIso8601String(),
      });

      // Also update conversation metadata
      await _firestore
          .collection('users')
          .doc(_studentId)
          .collection('conversations')
          .doc(_conversationId)
          .set({
        'lastMessage': message['message'],
        'lastUpdated': DateTime.now().toIso8601String(),
        'title': _getConversationTitle(),
      });
    } catch (e) {
      print('Error saving message: $e');
    }
  }

  String _getConversationTitle() {
    // Use the first user message as the title, or a default if none exists
    for (var message in _messages) {
      if (message['sender'] == 'user') {
        String title = message['message'] ?? '';
        // Truncate long titles
        return title.length > 30 ? '${title.substring(0, 27)}...' : title;
      }
    }
    return 'New Conversation';
  }

  Future<void> _startNewConversation() async {
    final prefs = await SharedPreferences.getInstance();
    String convPrefKey = 'current_conversation_id_$_studentId';
    setState(() {
      _conversationId = const Uuid().v4();
      _messages = [
        {'sender': 'bot', 'message': 'Hi, I am AI Tutor! How can I help you today? 😊', 'timestamp': DateTime.now().toIso8601String()},
      ];
    });
    await prefs.setString(convPrefKey, _conversationId);
    await _saveMessage(_messages[0]);
  }

  Future<String> _getAIResponse(String userMessage) async {
    try {
      // Add student context to prompt if available
      String contextPrompt = '';
      if (_studentName.isNotEmpty) {
        contextPrompt = 'The student\'s name is $_studentName.';
        if (_studentSemester.isNotEmpty) {
          contextPrompt += ' They are currently in semester $_studentSemester.';
        }
      }

      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': 'You are a helpful AI tutor. Your goal is to assist students with their studies, provide educational content, and offer motivation. Be friendly, concise, and helpful. $contextPrompt Here is the student\'s message: $userMessage'
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 500,
          },
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['candidates'][0]['content']['parts'][0]['text'];
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return 'Sorry, I encountered an issue. Please try again later.';
      }
    } catch (e) {
      print('Exception: $e');
      return 'Sorry, I encountered an error. Please check your internet connection.';
    }
  }

  void _sendMessage(String text) async {
    if (text.isEmpty) return;

    final userMessage = {
      'sender': 'user',
      'message': text,
      'timestamp': DateTime.now().toIso8601String()
    };

    setState(() {
      _messages.add(userMessage);
      _controller.clear();
      _isLoading = true;
    });

    // Save user message to Firebase
    await _saveMessage(userMessage);

    // Get AI response
    final aiResponse = await _getAIResponse(text);
    final botMessage = {
      'sender': 'bot',
      'message': aiResponse,
      'timestamp': DateTime.now().toIso8601String()
    };

    setState(() {
      _messages.add(botMessage);
      _isLoading = false;
    });

    // Save bot message to Firebase
    await _saveMessage(botMessage);
  }

  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(onResult: (result) {
        setState(() {
          _controller.text = result.recognizedWords;
        });
      });
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      String fileName = result.files.single.name;
      final userMessage = {
        'sender': 'user',
        'message': '📎 Sent a file: $fileName',
        'timestamp': DateTime.now().toIso8601String()
      };

      setState(() {
        _messages.add(userMessage);
      });

      // Save file message to Firebase
      await _saveMessage(userMessage);

      // Here you would process the file content, possibly send it to the API
      // Currently this just acknowledges receipt, but doesn't process the file
      Timer(const Duration(milliseconds: 800), () async {
        final botMessage = {
          'sender': 'bot',
          'message': 'I received your file "$fileName". What would you like to know about it?',
          'timestamp': DateTime.now().toIso8601String()
        };

        setState(() {
          _messages.add(botMessage);
        });

        // Save bot response to Firebase
        await _saveMessage(botMessage);
      });
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
            const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                radius: 15,
                backgroundColor: Color(0xFF16213E),
                child: Icon(Icons.smart_toy, size: 16, color: Colors.white),
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: isUser ?
                const Color(0x0f180935) : const Color(0xFF16213E),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft:
                  isUser ? const Radius.circular(16) : const Radius.circular(0),
                  bottomRight:
                  isUser ? const Radius.circular(0) : const Radius.circular(16),
                ),
              ),
              child: MarkdownBody(
                data: message,
                selectable: true,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(color: Colors.white),
                  h1: const TextStyle(color: Colors.white),
                  h2: const TextStyle(color: Colors.white),
                  h3: const TextStyle(color: Colors.white),
                  h4: const TextStyle(color: Colors.white),
                  h5: const TextStyle(color: Colors.white),
                  h6: const TextStyle(color: Colors.white),
                  code: const TextStyle(color: Colors.white),
                  blockquote: const TextStyle(color: Colors.white),
                  em: const TextStyle(color: Colors.white),
                  strong: const TextStyle(color: Colors.white),
                  listBullet: const TextStyle(color: Colors.white),
                  tableHead: const TextStyle(color: Colors.white),
                  tableBody: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildQuickReplies() {
    String semester = _studentSemester;
    List<String> suggestions = [
      "Help me study effectively",
      "I need motivation to study",
      "Explain a difficult concept",
    ];

    // Add semester-specific quick replies if student semester is known
    if (semester.isNotEmpty) {
      suggestions.add("What should I focus on in semester $semester?");
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Wrap(
        spacing: 12,
        runSpacing: 10,
        children: suggestions.map((label) => _quickReplyButton(label)).toList(),
      ),
    );
  }

  Widget _quickReplyButton(String label) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        shape: const StadiumBorder(),
        side: const BorderSide(color: Colors.lightBlueAccent),
      ),
      child: Text(label, style: const TextStyle(color: Colors.blue)),
      onPressed: () => _sendMessage(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    String welcomeTitle = _studentName.isEmpty ? 'AI Tutor' : 'AI Tutor ';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        title: Text(welcomeTitle,style: const TextStyle(color: Colors.white),),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: const BoxDecoration(
              color:Color(0xFF16213E),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy, size: 16, color: Colors.white),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () {
              // Show past conversations for this student
              _showConversationsDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _startNewConversation,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0A0A), // Deep black
              Color(0xFF1A1A2E), // Dark navy
              Color(0xFF16213E), // Darker blue
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              if (_isLoadingHistory)
                const LinearProgressIndicator(
                  backgroundColor: Color(0xFF0A0A0A),
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0A0A0A)),
                ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 10),
                  itemCount: _messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isLoading) {
                      // Show typing indicator when loading
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF16213E),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF16213E),),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text("Thinking...", style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    final msg = _messages[index];
                    return _buildMessage(msg['sender']!, msg['message']!);
                  },
                ),
              ),

              if (_messages.length == 1) _buildQuickReplies(),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.attach_file, color: Colors.white),
                      onPressed: _pickFile,
                    ),
                    IconButton(
                      icon: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: Colors.white,
                      ),
                      onPressed: _isListening ? _stopListening : _startListening,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: Color(0xFF16213E)),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () => _sendMessage(_controller.text),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showConversationsDialog() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_studentId)
          .collection('conversations')
          .orderBy('lastUpdated', descending: true)
          .get();

      if (snapshot.docs.isNotEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Your Conversations'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.docs.length,
                itemBuilder: (context, index) {
                  final conversation = snapshot.docs[index];
                  final data = conversation.data();
                  return ListTile(
                    title: Text(data['title'] ?? 'Untitled Conversation'),
                    subtitle: Text(
                      data['lastMessage'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () async {
                      Navigator.pop(context);

                      // Switch to selected conversation
                      final prefs = await SharedPreferences.getInstance();
                      String convPrefKey = 'current_conversation_id_$_studentId';
                      setState(() {
                        _conversationId = conversation.id;
                        _isLoadingHistory = true;
                      });
                      await prefs.setString(convPrefKey, _conversationId);
                      await _loadChatHistory();
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No past conversations found'))
        );
      }
    } catch (e) {
      print('Error loading conversations: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error loading conversations'))
      );
    }
  }
}