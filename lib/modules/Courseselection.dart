import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;

class CourseSelectionScreen extends StatefulWidget {
  @override
  _CourseSelectionScreenState createState() => _CourseSelectionScreenState();
}

class _CourseSelectionScreenState extends State<CourseSelectionScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  bool _isUploading = false;
  String? _timetableData;
  List<String> _currentCourses = [];
  List<String> _userInterests = [];

  // Study scheme data
  Map<String, List<Map<String, dynamic>>> _allCourses = {
    "Core Courses": [],
    "Elective Courses": []
  };

  // Map to store elective courses - removed original electives
  Map<String, dynamic> _electiveCourses = {};

  // IT Electives from the study scheme
  Map<String, dynamic> _itElectives = {
    "IT Electives": [
      {
        "code": "IT-412",
        "name": "Theory of Automata",
        "credits": 3,
        "category": "General",
        "description": "Study of abstract machines and automata, as well as computational problems that can be solved using them.",
        "tags": ["theory", "computational models", "algorithms"]
      },
      {
        "code": "IT-402",
        "name": "Visual Programming",
        "credits": 3,
        "category": "General",
        "description": "Development of graphical user interfaces and applications using visual programming tools.",
        "tags": ["UI/UX", "front-end", "GUI"]
      },
      {
        "code": "IT-434",
        "name": "Software Requirement Engineering",
        "credits": 3,
        "category": "General",
        "description": "Process of determining, analyzing, documenting, and validating software requirements.",
        "tags": ["software engineering", "requirements", "documentation"]
      },
      {
        "code": "IT-435",
        "name": "Component Based Software Engineering",
        "credits": 3,
        "category": "General",
        "description": "Software engineering approach based on reusable software components.",
        "tags": ["software engineering", "components", "reusability"]
      },
      {
        "code": "IT-436",
        "name": "Software Quality Assurance",
        "credits": 3,
        "category": "General",
        "description": "Processes and methods for ensuring software quality, testing, and verification.",
        "tags": ["QA", "testing", "software quality"]
      },
      {
        "code": "IT-441",
        "name": "Mobile Computing",
        "credits": 3,
        "category": "General",
        "description": "Development of applications for mobile devices and understanding mobile computing platforms.",
        "tags": ["mobile", "Android", "iOS", "app development"]
      },
      {
        "code": "IT-401",
        "name": "Rapid Application Development",
        "credits": 3,
        "category": "General",
        "description": "Fast and efficient application development methodologies and tools.",
        "tags": ["agile", "development methodologies", "frameworks"]
      },
      {
        "code": "IT-431",
        "name": "Information System",
        "credits": 3,
        "category": "General",
        "description": "Study of information systems in organizations, their design, implementation, and management.",
        "tags": ["information systems", "databases", "business"]
      },
      {
        "code": "IT-432",
        "name": "Advanced Database Systems",
        "credits": 3,
        "category": "General",
        "description": "Advanced database concepts including distributed databases, NoSQL, and data warehousing.",
        "tags": ["databases", "SQL", "NoSQL", "data warehousing"]
      },
      {
        "code": "IT-433",
        "name": "Software Project Management",
        "credits": 3,
        "category": "General",
        "description": "Planning, organizing, and managing resources for successful software project completion.",
        "tags": ["project management", "leadership", "agile"]
      },
      {
        "code": "IT-421",
        "name": "Microcontroller and Interfacing",
        "credits": 3,
        "category": "General",
        "description": "Design and implementation of microcontroller-based systems and their interfacing.",
        "tags": ["hardware", "embedded systems", "IoT"]
      },
      {
        "code": "IT-442",
        "name": "Digital Image Processing",
        "credits": 3,
        "category": "General",
        "description": "Techniques for processing and analyzing digital images.",
        "tags": ["image processing", "computer vision", "graphics"]
      },
      {
        "code": "IT-451",
        "name": "Introduction to Machine Learning",
        "credits": 3,
        "category": "General",
        "description": "Fundamental concepts of machine learning algorithms and their applications.",
        "tags": ["machine learning", "AI", "data science"]
      },
      {
        "code": "IT-461",
        "name": "Organizational Behaviour",
        "credits": 3,
        "category": "General",
        "description": "Study of human behavior in organizational settings and its impact on performance.",
        "tags": ["psychology", "management", "leadership"]
      }
    ]
  };

  // Free time slots parsed from timetable
  Map<String, List<String>> _freeTimeSlots = {};

  // Recommended courses based on interests and schedule
  List<Map<String, dynamic>> _recommendedCourses = [];

  String? _apiKey;

  @override
  void initState() {
    super.initState();
    _loadEnv();
    _loadUserData();
    _prepareCoursesData();
    _addInitialBotMessage();
  }

  Future<void> _loadEnv() async {
    try {
      // Directly set the API key for now
      _apiKey = 'AIzaSyDu4hwJ701gyYElEQEKQfEQPct9549RGjY';

      if (_apiKey == null || _apiKey!.isEmpty) {
        print('Warning: GEMINI_API_KEY not found or empty');
      } else {
        print('API key configured successfully');
      }
    } catch (e) {
      print('Error loading environment variables: $e');
    }
  }

  void _prepareCoursesData() {
    // Add the IT electives to the elective courses
    _electiveCourses['IT'] = _itElectives['IT Electives'];

    // Prepare dummy free time slots (will be overwritten by timetable analysis)
    _freeTimeSlots = {
      'Monday': ['8:00-10:00', '13:00-15:00'],
      'Tuesday': ['10:00-12:00', '15:00-17:00'],
      'Wednesday': ['8:00-10:00', '15:00-17:00'],
      'Thursday': ['13:00-15:00'],
      'Friday': ['10:00-12:00', '15:00-17:00'],
    };
  }

  void _addInitialBotMessage() {
    setState(() {
      _messages.add({
        'sender': 'bot',
        'message': 'Hi there! I\'m your **Course Selection Assistant** powered by Gemini AI. I can help you choose elective courses based on your interests, current schedule, and academic history.\n\nYou can:\n• Upload your current timetable\n• Tell me about your interests\n• Ask about available electives\n• Get personalized course recommendations\n• Check for scheduling conflicts\n\n*How can I assist you today?*'
      });
    });
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      // Get current user
      final User? user = _auth.currentUser;
      if (user == null) {
        _addSystemMessage("Error: You need to be logged in to use this feature.");
        return;
      }

      // Get user data from Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data();

        // Load current courses if available
        if (userData != null && userData['currentCourses'] != null) {
          setState(() {
            _currentCourses = List<String>.from(userData['currentCourses']);
          });
        }

        // Load interests if available
        if (userData != null && userData['interests'] != null) {
          setState(() {
            _userInterests = List<String>.from(userData['interests']);
          });
        }
      }
    } catch (e) {
      _addSystemMessage("Error loading user data: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadTimetable() async {
    setState(() => _isUploading = true);

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xls', 'xlsx', 'pdf', 'json', 'txt'],
      );

      if (result != null) {
        PlatformFile file = result.files.first;

        // For demo purposes, we'll simulate processing the file
        setState(() {
          _timetableData = "Timetable uploaded: ${file.name}";
          _messages.add({
            'sender': 'user',
            'message': "I've uploaded my timetable: ${file.name}"
          });
        });

        // Use Gemini API to analyze the timetable
        String response = await _getGeminiResponse(
            "Analyze this student timetable and identify available time slots for elective courses: ${file.name}. "
                "Then recommend 3-5 courses from the available electives that fit these time slots. "
                "Format the response with Markdown. Make free slots and recommendations bold where appropriate."
        );

        _addBotMessage(response);

        // After timetable is processed, generate recommendations
        _generateCourseRecommendations();
      } else {
        _addSystemMessage("Timetable upload cancelled");
      }
    } catch (e) {
      _addSystemMessage("Error uploading timetable: $e");
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _generateCourseRecommendations() {
    // Initialize recommendations list
    _recommendedCourses = [];

    // Combine all electives into a single list for processing
    List<Map<String, dynamic>> allElectives = [];
    _electiveCourses.forEach((department, courses) {
      allElectives.addAll(List<Map<String, dynamic>>.from(courses));
    });

    // Filter courses by available time slots (if timetable is uploaded)
    if (_timetableData != null) {
      allElectives = allElectives.where((course) {
        // If course has schedule info, check if it fits in free slots
        if (course.containsKey('schedule')) {
          List<String> schedule = List<String>.from(course['schedule']);

          for (String slot in schedule) {
            String day = slot.split(' ')[0];
            String time = slot.split(' ')[1];

            // Check if this time conflicts with free slots
            bool fits = false;
            if (_freeTimeSlots.containsKey(day)) {
              for (String freeSlot in _freeTimeSlots[day]!) {
                // Simple check - would need more sophisticated logic in production
                if (freeSlot.contains(time)) {
                  fits = true;
                  break;
                }
              }
              if (!fits) return false;
            } else {
              return false; // Day not free
            }
          }
          return true;
        }
        return true; // Include courses without schedule info
      }).toList();
    }

    // Filter courses by user interests (if any)
    if (_userInterests.isNotEmpty) {
      // Score courses by relevance to interests
      allElectives.forEach((course) {
        int score = 0;

        // Check tags against interests
        if (course.containsKey('tags')) {
          for (String tag in course['tags']) {
            for (String interest in _userInterests) {
              if (tag.toLowerCase().contains(interest.toLowerCase()) ||
                  interest.toLowerCase().contains(tag.toLowerCase())) {
                score += 2;
              }
            }
          }
        }

        // Check name and description for interest keywords
        for (String interest in _userInterests) {
          if (course['name'].toLowerCase().contains(interest.toLowerCase())) {
            score += 3;
          }
          if (course['description'].toLowerCase().contains(interest.toLowerCase())) {
            score += 1;
          }
        }

        course['interestScore'] = score;
      });

      // Sort by score
      allElectives.sort((a, b) => (b['interestScore'] ?? 0).compareTo(a['interestScore'] ?? 0));

      // Take top matches
      _recommendedCourses = allElectives.take(5).toList();
    } else {
      // If no interests specified, just take the first 5 compatible courses
      _recommendedCourses = allElectives.take(5).toList();
    }

    // Display recommendations
    if (_recommendedCourses.isNotEmpty) {
      _showRecommendations();
    }
  }

  void _showRecommendations() {
    StringBuffer message = StringBuffer("**🌟 Based on your timetable and interests, here are your personalized course recommendations:**\n\n");

    for (int i = 0; i < _recommendedCourses.length; i++) {
      var course = _recommendedCourses[i];
      message.write("**${i+1}. ${course['code']} - ${course['name']}**\n");
      message.write("   **Credits:** ${course['credits']}\n");

      if (course.containsKey('schedule')) {
        message.write("   **Schedule:** ${course['schedule'].join(', ')}\n");
      }

      message.write("   **Description:** ${course['description']}\n");

      if (course.containsKey('tags')) {
        message.write("   **Tags:** *${course['tags'].join(', ')}*\n");
      }

      message.write("\n");
    }

    message.write("Would you like more information about any of these courses? Or would you like to specify your interests to get better recommendations?");

    _addBotMessage(message.toString());
  }

  void _addSystemMessage(String message) {
    setState(() {
      _messages.add({'sender': 'system', 'message': message});
    });
    _scrollToBottom();
  }

  void _addBotMessage(String message) {
    setState(() {
      _messages.add({'sender': 'bot', 'message': message});
    });
    _scrollToBottom();
  }

  void _sendMessage() {
    if (_controller.text.isEmpty) return;

    final userMessage = _controller.text;
    setState(() {
      _messages.add({'sender': 'user', 'message': userMessage});
    });
    _controller.clear();
    _scrollToBottom();

    // Process the user message
    _processUserMessage(userMessage);
  }

  Future<void> _processUserMessage(String message) async {
    setState(() => _isLoading = true);

    // First check for local commands
    if (_processLocalCommands(message)) {
      setState(() => _isLoading = false);
      return;
    }

    // Check if user is specifying interests
    if (message.toLowerCase().contains('interest') ||
        message.toLowerCase().contains('like') ||
        message.toLowerCase().contains('prefer')) {
      _extractUserInterests(message);
    }

    try {
      // Use Gemini API for responses
      String response = await _getGeminiResponse(message);
      _addBotMessage(response);
    } catch (e) {
      _addSystemMessage("Error processing your request: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _extractUserInterests(String message) {
    // Send the interests extraction to the API
    _getGeminiResponse(
        "Extract user interests from this message for course recommendation. Return ONLY a comma-separated list of keywords. Message: $message"
    ).then((response) {
      // Process the comma-separated list
      List<String> extractedInterests = response
          .replaceAll('\n', '')
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      if (extractedInterests.isNotEmpty) {
        setState(() {
          _userInterests = extractedInterests;
        });

        // Re-generate recommendations based on new interests
        _generateCourseRecommendations();

        // Confirm to user
        _addBotMessage("I've noted your interests in *${extractedInterests.join(', ')}*. I've updated your course recommendations accordingly!");
      }
    });
  }

  bool _processLocalCommands(String message) {
    message = message.toLowerCase();

    if (message.contains('upload') && message.contains('timetable')) {
      _uploadTimetable();
      return true;
    }

    if (message.contains('show') && message.contains('current')) {
      if (_currentCourses.isEmpty) {
        _addBotMessage("You don't have any current courses in our database. Would you like to add some?");
      } else {
        _addBotMessage("Your current courses are: **${_currentCourses.join(", ")}**");
      }
      return true;
    }

    if (message.contains('list') && (message.contains('electives') || message.contains('courses'))) {
      _listAllElectives();
      return true;
    }

    if (message.contains('recommend') || message.contains('suggestions')) {
      _generateCourseRecommendations();
      return true;
    }

    return false;
  }

  void _listAllElectives() {
    StringBuffer response = StringBuffer("**Available Elective Courses:**\n\n");

    // Add IT electives
    response.write("**IT Electives**\n");
    for (var course in _itElectives['IT Electives']) {
      response.write("• **${course['code']}** - *${course['name']}* (${course['credits']} credits)\n");
    }
    response.write("\n");

    // Add any other electives that might be in the system
    _electiveCourses.forEach((department, courses) {
      if (department != 'IT') {
        response.write("**$department**\n");
        for (var course in courses) {
          response.write("• **${course['code']}** - *${course['name']}* (${course['credits']} credits)\n");
        }
        response.write("\n");
      }
    });

    response.write("Would you like details about any specific course? Or would you like to see course recommendations based on your timetable and interests?");
    _addBotMessage(response.toString());
  }

  Future<String> _getGeminiResponse(String message) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      return "API key not configured. Please set up the Gemini API key to enable AI recommendations.";
    }

    try {
      // Prepare the context for the AI
      Map<String, dynamic> context = {
        "current_courses": _currentCourses,
        "timetable": _timetableData,
        "user_interests": _userInterests,
        "available_electives": _itElectives,
        "message": message,
        "conversation_history": _getConversationHistory()
      };

      // Call the Gemini API with the context
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text": """
                  You are a helpful course selection assistant for a university student.
                  
                  Available elective courses:
                  ${jsonEncode(_itElectives)}
                  
                  User's current courses: ${_currentCourses.isEmpty ? "None registered yet" : _currentCourses.join(", ")}
                  
                  User's timetable: ${_timetableData ?? "Not uploaded yet"}
                  
                  User's interests: ${_userInterests.isEmpty ? "Not specified yet" : _userInterests.join(", ")}
                  
                  User query: $message
                  
                  Provide helpful, personalized guidance about course selection.
                  Format your response with Markdown:
                  - Use **bold** for important information
                  - Use *italics* for emphasis
                  - Use proper lists and structure
                  
                  If recommending courses, explain why they'd be beneficial based on the user's interests.
                  """
                }
              ]
            }
          ],
          "generationConfig": {
            "temperature": 0.2,
            "topK": 40,
            "topP": 0.95,
            "maxOutputTokens": 1024,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Extract the AI's response text
        if (data['candidates'] != null &&
            data['candidates'].isNotEmpty &&
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null &&
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          return data['candidates'][0]['content']['parts'][0]['text'];
        } else {
          return "I received a response from the AI, but couldn't extract the text. Please try again.";
        }
      } else {
        return "Error from Gemini API: ${response.statusCode} ${response.body}. Please try again later.";
      }
    } catch (e) {
      return "Technical error when calling Gemini API: $e. Please try again later.";
    }
  }

  List<Map<String, String>> _getConversationHistory() {
    // Convert the last few message exchanges to a format for context
    List<Map<String, String>> history = [];
    int messageCount = _messages.length;
    int limit = messageCount > 6 ? 6 : messageCount; // Include last 6 messages at most

    for (int i = messageCount - limit; i < messageCount; i++) {
      if (i >= 0) {
        history.add({
          'role': _messages[i]['sender'] == 'user' ? 'user' : 'assistant',
          'text': _messages[i]['message']
        });
      }
    }

    return history;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    final sender = message['sender'];
    final text = message['message'];

    if (sender == 'system') {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    final isUser = sender == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            Padding(
              padding: const EdgeInsets.only(right: 8.0, left: 12.0, top: 6.0),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFF9C7FE2),
                child: Icon(Icons.school, size: 18, color: Colors.white),
              ),
            ),
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                color: isUser ? Color(0xFFE5E0F2) : Colors.white,  // Light purple shade
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: isUser
                  ? Text(
                text,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                ),
              )
                  : MarkdownBody(
                data: text,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                  ),
                  strong: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  em: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
          if (isUser)
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 12.0, top: 6.0),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFF9C7FE2),
                child: Icon(Icons.person, size: 18, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FF),
      appBar: AppBar(
        backgroundColor: Color(0xFF9C7FE2),  // Light purple shade
        title: Row(
          children: [
            Text(
              'Course Selection Assistant',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'AI Powered',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Feature introduction banner
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Color(0xFFFFA000)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Upload your timetable to get AI-powered course recommendations!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _uploadTimetable,
                    child: Text(
                      'Upload',
                      style: TextStyle(
                        color: Color(0xFF9C7FE2),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Interest tags if any
            if (_userInterests.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Interests:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _userInterests.map((interest) {
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Color(0xFFE5E0F2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            interest,
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9C7FE2),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

            // Chat messages
            Expanded(
              child: _isLoading && _messages.isEmpty
                  ? Center(child: CircularProgressIndicator(color: Color(0xFF9C7FE2)))
                  : ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.only(top: 10, bottom: 10),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessage(_messages[index]);
                },
              ),
            ),

            // Loading indicator
            if (_isLoading && _messages.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF9C7FE2),
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Thinking...",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

            // File upload indicator
            if (_isUploading)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF9C7FE2),
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Uploading file...",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

            // Input field
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.attach_file, color: Color(0xFF9C7FE2)),
                    onPressed: _uploadTimetable,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Ask about courses or share your interests...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        fillColor: Color(0xFFF0F2F5),
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF9C7FE2),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }}