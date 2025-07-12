import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io' if (dart.library.html) 'package:file_picker/src/platform_file.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class CourseSelectionScreen extends StatefulWidget {
  const CourseSelectionScreen({super.key});
  @override
  _CourseSelectionScreenState createState() => _CourseSelectionScreenState();
}
class _CourseSelectionScreenState extends State<CourseSelectionScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  bool _isTimetableInputActive = false;
  String? _timetableData;
  List<String> _currentCourses = [];
  List<String> _userInterests = [];
  Map<String, List<String>> _parsedSchedule = {}; // Day -> List of time slots
  List<Map<String, dynamic>> _detailedCourseData = [];
  // Enhanced course data structure
  final Map<String, List<Map<String, dynamic>>> _allCourses = {
    "Core Courses": [],
    "Elective Courses": []
  };
  Map<String, dynamic> _electiveCourses = {};
  List<Map<String, dynamic>> _recommendedCourses = [];
  final String? _apiKey = "AIzaSyDu4hwJ701gyYElEQEKQfEQPct9549RGjY";
  @override
  void initState() {
    super.initState();
    _loadUserData();
    _prepareCoursesData();
    _addInitialBotMessage();
  }
  // Enhanced course data preparation
  void _prepareCoursesData() {
    // Load core courses from all semesters
    for (int i = 1; i <= 8; i++) {
      String semesterPath = 'semesters/semester$i/courses';
      _firestore.collection(semesterPath).get().then((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          List<Map<String, dynamic>> semesterCourses = [];
          for (var doc in snapshot.docs) {
            final courseCode = doc.id;
            Map<String, dynamic> courseData = doc.data();
            final courseMap = {
              'id': courseCode,
              'code': courseCode,
              'name': courseData['name'] ?? 'Unknown',
              'credits': courseData['credits'] ?? 0,
              'description': courseData['description'] ?? 'No description available',
              'semester': i.toString(),
              'type': 'core',
              'prerequisites': courseData['prerequisites'] ?? [],
              'difficulty': courseData['difficulty'] ?? 'medium',
              'workload': courseData['workload'] ?? 'moderate',
            };
            if (courseData.containsKey('schedule')) {
              courseMap['schedule'] = courseData['schedule'];
            }
            if (courseData.containsKey('instructor')) {
              courseMap['instructor'] = courseData['instructor'];
            }
            semesterCourses.add(courseMap);
          }
          setState(() {
            if (_allCourses.containsKey("Core Courses")) {
              _allCourses["Core Courses"]!.addAll(semesterCourses);
            } else {
              _allCourses["Core Courses"] = semesterCourses;
            }
          });
          print('Loaded ${semesterCourses.length} courses for semester $i');
        }
      }).catchError((error) {
        print('Error loading semester $i courses: $error');
      });
    }
    // Load elective courses with enhanced data
    _firestore.collection('semesters/electives/courses').get().then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> electiveCourses = [];
        Map<String, dynamic> electiveMap = {};
        for (var doc in snapshot.docs) {
          final courseCode = doc.id;
          Map<String, dynamic> courseData = doc.data();
          final courseMap = {
            'id': courseCode,
            'code': courseCode,
            'name': courseData['name'] ?? 'Unknown',
            'credits': courseData['credits'] ?? 0,
            'description': courseData['description'] ?? 'No description available',
            'isElective': true,
            'type': 'elective',
            'prerequisites': courseData['prerequisites'] ?? [],
            'difficulty': courseData['difficulty'] ?? 'medium',
            'workload': courseData['workload'] ?? 'moderate',
            'careerRelevance': courseData['careerRelevance'] ?? [],
            'skillsGained': courseData['skillsGained'] ?? [],
          };
          if (courseData.containsKey('schedule')) {
            courseMap['schedule'] = courseData['schedule'];
          }
          if (courseData.containsKey('tags')) {
            courseMap['tags'] = courseData['tags'];
          }
          if (courseData.containsKey('instructor')) {
            courseMap['instructor'] = courseData['instructor'];
          }
          electiveCourses.add(courseMap);
          electiveMap[courseCode] = courseMap;
        }
        setState(() {
          _allCourses["Elective Courses"] = electiveCourses;
          _electiveCourses = electiveMap;
        });
        print('Loaded ${electiveCourses.length} elective courses');
      }
    }).catchError((error) {
      print('Error loading elective courses: $error');
    });
  }
  void _addInitialBotMessage() {
    setState(() {
      _messages.add({
        'sender': 'bot',
        'message': '🎓 **Welcome to your AI Course Selection Assistant!**\n\n'
            'I\'m here to help you make informed decisions about your course selection. Here\'s what I can do:\n\n'
            '**📚 Course Information:**\n'
            '• Show available courses by semester or type\n'
            '• Provide detailed course descriptions and requirements\n'
            '• Explain prerequisites and difficulty levels\n\n'
            '**🗓️ Schedule Analysis:**\n'
            '• Analyze your timetable for conflicts\n'
            '• Suggest optimal course combinations\n'
            '• Identify available time slots\n\n'
            '**💡 Personalized Recommendations:**\n'
            '• Match courses to your interests and career goals\n'
            '• Suggest electives based on your academic focus\n'
            '• Consider workload and difficulty balance\n\n'
            '**🎯 Quick Start Commands:**\n'
            '• "*Upload my timetable*" - to analyze your schedule\n'
            '• "*Show my enrolled courses*" - to see current registration\n'
            '• "*I\'m interested in [topic]*" - for personalized recommendations\n'
            '• "*Show elective courses*" - to browse available electives\n\n'
            'What would you like to explore first?'
      });
    });
  }
  Future<void> _processTimetableText(String timetableText, String additionalContext) async {
    setState(() => _isLoading = true);
    _addBotMessage("🔍 **Analyzing your timetable...** This may take a moment.");
    setState(() {
      _timetableData = timetableText;
      _messages.add({
        'sender': 'user',
        'message': "Here's my timetable data: [Timetable Information Provided]"
      });
    });
    try {
      final semester = await _getCurrentUserSemester();
      final parsePrompt = """
TASK: Parse and analyze the following timetable data to extract structured course information.
TIMETABLE DATA:
$timetableText
ADDITIONAL CONTEXT:
$additionalContext
INSTRUCTIONS:
1. Extract only $semester Semester courses with Course Code, Day(s), Time(s), Duration
2. Convert all times to 24-hour format
4. Identify any irregular scheduling patterns
FORMAT YOUR RESPONSE AS:
**COURSE SCHEDULE ANALYSIS**
**Extracted Courses:**
[List that semester courses]
**Time Conflicts:**
[List any scheduling conflicts found]
**Weekly Schedule Summary:**
[Provide day-by-day breakdown]
**Free Time Slots:**
[Identify available time slots during standard hours 9AM-6PM for $semester courses]
Be precise with times and clearly identify any scheduling issues.
""";
      String scheduleAnalysis = await _getGeminiResponse(parsePrompt);
      _parseScheduleData(scheduleAnalysis);
      _addBotMessage(scheduleAnalysis);
      _addBotMessage("📋 **Schedule analysis complete!** Now, to provide better course recommendations, please tell me about your academic interests and career goals. What subjects or fields excite you most?");
    } catch (e) {
      _addSystemMessage("Error processing timetable: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }
  // Enhanced schedule parsing for internal data structure
  void _parseScheduleData(String analysisText) {
    Map<String, List<String>> schedule = {};
    List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
    for (String day in days) {
      schedule[day] = [];
    }
    setState(() {
      _parsedSchedule = schedule;
    });
  }
  Future<void> _displayCoursesList(String courseType, {String? semester}) async {
    setState(() => _isLoading = true);
    try {
      String collectionPath = '';
      String displayTitle = '';
      if (courseType.toLowerCase() == 'elective') {
        collectionPath = 'semesters/electives/courses';
        displayTitle = 'Elective';
      } else if (semester != null) {
        collectionPath = 'semesters/$semester/courses';
        displayTitle = 'Semester $semester';
      } else {
        _addBotMessage("❓ Please specify which semester courses you'd like to see, or ask for elective courses.");
        setState(() => _isLoading = false);
        return;
      }
      final CollectionReference coursesCollection = _firestore.collection(collectionPath);
      final QuerySnapshot snapshot = await coursesCollection.get();
      if (snapshot.docs.isEmpty) {
        _addBotMessage("❌ No courses found for ${displayTitle.toLowerCase()} in our database.");
        setState(() => _isLoading = false);
        return;
      }
      StringBuffer coursesMessage = StringBuffer();
      coursesMessage.write("📚 **$displayTitle Courses** (${snapshot.docs.length} available)\n\n");
      List<Map<String, dynamic>> coursesList = [];
      for (var doc in snapshot.docs) {
        final courseCode = doc.id;
        Map<String, dynamic> courseData = doc.data() as Map<String, dynamic>;
        final courseName = courseData['name'] ?? 'Unknown Course';
        final courseCredits = courseData['credits'] ?? '?';
        final courseDescription = courseData['description'] ?? 'No description available';
        final difficulty = courseData['difficulty'] ?? 'Medium';
        final prerequisites = courseData['prerequisites'] ?? [];
        coursesList.add({
          'code': courseCode,
          'name': courseName,
          'credits': courseCredits,
          'description': courseDescription,
          'difficulty': difficulty,
          'prerequisites': prerequisites,
          'schedule': courseData['schedule'],
        });
      }
      coursesList.sort((a, b) => a['code'].compareTo(b['code']));
      for (var course in coursesList) {
        coursesMessage.write("**${course['code']} - ${course['name']}**\n");
        coursesMessage.write("   📊 **Credits:** ${course['credits']}\n");
        coursesMessage.write("   🎯 **Difficulty:** ${course['difficulty']}\n");
        if (course['prerequisites'].isNotEmpty) {
          coursesMessage.write("   📋 **Prerequisites:** ${course['prerequisites'].join(', ')}\n");
        }
        if (course['schedule'] != null) {
          coursesMessage.write("   🗓️ **Schedule:** ${course['schedule']}\n");
        }
        coursesMessage.write("   📝 **Description:** ${course['description']}\n\n");
      }
      coursesMessage.write("💡 **Need more details?** Ask me about any specific course code for detailed information and recommendations!");
      _addBotMessage(coursesMessage.toString());
    } catch (e) {
      print('Error in _displayCoursesList: $e');
      _addSystemMessage("Error loading courses: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }
  Future<void> _loadAndDisplayEnrolledCourses() async {
    setState(() => _isLoading = true);
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        _addBotMessage("🔐 Please log in to view your enrolled courses.");
        setState(() => _isLoading = false);
        return;
      }
      DocumentSnapshot userDoc;
      try {
        userDoc = await _firestore.collection('users').doc(user.uid).get();
      } catch (e) {
        userDoc = await _firestore.collection('users').doc(user.phoneNumber?.replaceAll('+', '') ?? '').get();
      }
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>?;
        if (userData != null && userData.containsKey('courses')) {
          List<dynamic> coursesData = userData['courses'];
          if (coursesData.isEmpty) {
            _addBotMessage("📝 **No courses enrolled yet.** Would you like me to recommend some courses based on your interests and career goals?");
            setState(() => _isLoading = false);
            return;
          }
          StringBuffer coursesMessage = StringBuffer();
          coursesMessage.write("🎓 **Your Current Enrollment** (${coursesData.length} courses)\n\n");
          int totalCredits = 0;
          Map<String, int> categoryCount = {};
          for (var course in coursesData) {
            if (course is Map<String, dynamic>) {
              final courseCode = course['code'] ?? 'Unknown';
              final courseName = course['name'] ?? 'Unknown Course';
              final courseCredits = course['creditHours'] ?? 0;
              final courseCategory = course['category'] ?? 'Unknown';
              final courseType = course['type'] ?? '';
              coursesMessage.write("**$courseCode - $courseName**\n");
              coursesMessage.write("   📊 Credits: $courseCredits\n");
              coursesMessage.write("   📂 Category: $courseCategory\n");
              if (courseType.isNotEmpty) {
                coursesMessage.write("   🏷️ Type: $courseType\n");
              }
              coursesMessage.write("\n");
              totalCredits += int.tryParse(courseCredits.toString()) ?? 0;
              categoryCount[courseCategory] = (categoryCount[courseCategory] ?? 0) + 1;
            }
          }
          coursesMessage.write("📈 **Summary:**\n");
          coursesMessage.write("• Total Credit Hours: $totalCredits\n");
          coursesMessage.write("• Course Distribution: ${categoryCount.entries.map((e) => "${e.key}: ${e.value}").join(', ')}\n\n");
          coursesMessage.write("💡 Need help with course planning or want to add more courses? Just ask!");
          _addBotMessage(coursesMessage.toString());
        } else {
          _addBotMessage("📝 **No courses found in your profile.** Let me help you select some courses that match your interests and academic goals!");
        }
      } else {
        _addBotMessage("👤 **Profile not found.** Please ensure you're logged in properly or contact support if the issue persists.");
      }
    } catch (e) {
      print("Error in _loadAndDisplayEnrolledCourses: $e");
      _addSystemMessage("Error loading enrolled courses: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }
  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final User? user = _auth.currentUser;
      if (user == null) return;
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        if (userData != null && userData['currentCourses'] != null) {
          setState(() {
            _currentCourses = List<String>.from(userData['currentCourses']);
          });
        }
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
  void _openTimetableInput() {
    setState(() {
      _isTimetableInputActive = true;
    });

    _addBotMessage("📝 **Timetable Input Mode Activated**\n\n"
        "Please enter your timetable data in the chat. For best results, include:\n"
        "• Course codes \n"
        "• Days and times for each course\n"
        "• Room numbers \n\n"
        "*Example format: CS-101 Monday 9:00-11:00 AM in R1/R2/R3/Hall*\n\n"
        "When you're done, just send the message and I'll analyze it!");
  }
  void _generateCourseRecommendations() {
    if (_userInterests.isEmpty) {
      _addBotMessage("💡 **To provide personalized recommendations, please tell me about your interests first!**\n\n"
          "For example, you could say:\n"
          "• \"I'm interested in cybersecurity and data analysis\"\n"
          "• \"I want to focus on web development and AI\"\n"
          "• \"I'm planning a career in software engineering\"");
      return;
    }

    setState(() => _isLoading = true);

    // Enhanced recommendation prompt
    final recommendationPrompt = """
TASK: Generate personalized course recommendations for a university student.

STUDENT PROFILE:
- Current Interests: ${_userInterests.join(', ')}
- Currently Enrolled: ${_currentCourses.isEmpty ? 'No courses registered' : _currentCourses.join(', ')}
- Schedule Status: ${_timetableData != null ? 'Timetable provided' : 'No timetable data'}

AVAILABLE COURSES:
Core Courses: ${_allCourses["Core Courses"]?.length ?? 0} available
Elective Courses: ${_allCourses["Elective Courses"]?.length ?? 0} available

INSTRUCTIONS:
1. Analyze the student's interests and match them with relevant courses
2. Consider career relevance and skill development
3. Suggest a balanced mix of theoretical and practical courses
4. Explain WHY each course is recommended
5. Consider prerequisite requirements
6. Suggest optimal course combinations

FORMAT YOUR RESPONSE AS:
**🎯 PERSONALIZED COURSE RECOMMENDATIONS**

**Top Recommendations:**
[List 3-5 most relevant courses with detailed explanations]

**Career Alignment:**
[Explain how these courses support career goals]

**Skill Development Path:**
[Describe the learning progression]

**Additional Considerations:**
[Prerequisites, workload, scheduling notes]

Be specific about course codes and provide actionable advice.
""";

    _getGeminiResponse(recommendationPrompt).then((response) {
      _addBotMessage(response);

      // Follow up with scheduling check
      if (_timetableData != null) {
        _addBotMessage("📅 **Next Step:** Would you like me to check if these recommended courses fit your current schedule?");
      } else {
        _addBotMessage("📋 **Pro Tip:** Upload your timetable to get schedule-optimized recommendations!");
      }

      setState(() => _isLoading = false);
    }).catchError((error) {
      _addSystemMessage("Error generating recommendations: $error");
      setState(() => _isLoading = false);
    });
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

    if (_isTimetableInputActive) {
      setState(() {
        _isTimetableInputActive = false;
      });
      _processTimetableText(userMessage, "");
    } else {
      _processUserMessage(userMessage);
    }
  }// Enhanced message processing with better intent recognition
  Future<void> _processUserMessage(String message) async {
    setState(() => _isLoading = true);

    // First check for local commands
    if (_processLocalCommands(message)) {
      setState(() => _isLoading = false);
      return;
    }

    // Enhanced interest extraction
    if (_containsInterestKeywords(message)) {
      _extractUserInterests(message);
      setState(() => _isLoading = false);
      return;
    }

    // Enhanced course-specific queries
    if (_containsCourseQuery(message)) {
      _handleCourseSpecificQuery(message);
      return;
    }

    try {
      // Enhanced general query handling - FIXED: Use _getGeminiResponse instead of _getContextualResponse
      String contextualResponse = await _getGeminiResponse(message);
      _addBotMessage(contextualResponse);
    } catch (e) {
      _addSystemMessage("Error processing your request: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }
  // Enhanced interest detection
  bool _containsInterestKeywords(String message) {
    List<String> interestKeywords = [
      'interest', 'like', 'prefer', 'passionate', 'enjoy', 'focus', 'specialize',
      'career', 'goal', 'future', 'want to', 'planning', 'aspire', 'dream'
    ];

    String lowerMessage = message.toLowerCase();
    return interestKeywords.any((keyword) => lowerMessage.contains(keyword));
  }

  // Enhanced course query detection
  bool _containsCourseQuery(String message) {
    List<String> courseQueryKeywords = [
      'course', 'class', 'subject', 'tell me about', 'information about',
      'details about', 'explain', 'what is', 'how is'
    ];

    String lowerMessage = message.toLowerCase();
    return courseQueryKeywords.any((keyword) => lowerMessage.contains(keyword));
  }

  // Enhanced course-specific query handling
  void _handleCourseSpecificQuery(String message) async {
    setState(() => _isLoading = true);

    final courseQueryPrompt = """
TASK: Handle a course-specific query from a student.

STUDENT QUERY: $message

AVAILABLE COURSE DATA:
- Core Courses: ${_allCourses["Core Courses"]?.length ?? 0} available
- Elective Courses: ${_allCourses["Elective Courses"]?.length ?? 0} available

INSTRUCTIONS:
1. Identify if the query is about a specific course code
2. If asking about course recommendations, provide targeted suggestions
3. If asking about course details, provide comprehensive information
4. If asking about course comparisons, provide detailed analysis
5. Always relate back to the student's academic goals

FORMAT YOUR RESPONSE WITH:
- Clear course information
- Practical advice
- Next steps or follow-up questions
- Relevant recommendations

Be helpful and specific in your response.
""";

    try {
      String response = await _getGeminiResponse(courseQueryPrompt);
      _addBotMessage(response);
    } catch (e) {
      _addSystemMessage("Error handling course query: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Enhanced interest extraction with better parsing
  void _extractUserInterests(String message) {
    _addBotMessage("🎯 **Analyzing your interests...** This will help me find the perfect courses for you!");

    final interestExtractionPrompt = """
TASK: Extract specific academic and career interests from a student's message.

STUDENT MESSAGE: "$message"

INSTRUCTIONS:
1. Identify technical fields, subjects, and career goals mentioned
2. Extract specific interests relevant to IT/Computer Science education
3. Focus on actionable interests that can guide course selection
4. Include both explicit and implicit interests
5. Return 3-7 specific, relevant interest keywords

RETURN FORMAT:
Provide ONLY a comma-separated list of specific interest keywords.
No additional text, explanations, or formatting.

EXAMPLE OUTPUT:
cybersecurity, machine learning, web development, data science, software engineering

STUDENT MESSAGE TO ANALYZE:
$message
""";

    _getGeminiResponse(interestExtractionPrompt).then((response) {
      // Clean and parse the response
      List<String> extractedInterests = response
          .replaceAll('\n', '')
          .replaceAll('*', '')
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty && e.length > 2)
          .toList();

      if (extractedInterests.isNotEmpty) {
        setState(() {
          _userInterests = extractedInterests;
        });

        _addBotMessage("✅ **Great! I've identified your interests:**\n\n"
            "${extractedInterests.map((interest) => "• $interest").join('\n')}\n\n"
            "These interests will help me recommend courses that align with your goals. "
            "Let me generate some personalized recommendations for you!");

        // Generate recommendations after a brief delay
        Future.delayed(const Duration(milliseconds: 1000), () {
          _generateCourseRecommendations();
        });
      } else {
        _addBotMessage("🤔 **I'd love to learn more about your interests!** Could you be more specific about what subjects or career areas excite you?\n\n"
            "For example:\n"
            "• \"I'm interested in cybersecurity and ethical hacking\"\n"
            "• \"I want to work in AI and machine learning\"\n"
            "• \"Web development and mobile apps fascinate me\"");
      }
    }).catchError((error) {
      _addSystemMessage("Error extracting interests: $error");
    });
  }

  // Enhanced local command processing
  bool _processLocalCommands(String message) {
    message = message.toLowerCase();

    // Timetable input commands
    if (_matchesCommand(message, ['enter timetable', 'input timetable', 'upload timetable', 'provide timetable'])) {
      _openTimetableInput();
      return true;
    }

    // Current courses display
    if (_matchesCommand(message, ['show current courses', 'my courses', 'enrolled courses', 'current enrollment'])) {
      _loadAndDisplayEnrolledCourses();
      return true;
    }

    // Elective courses listing
    if (_matchesCommand(message, ['show electives', 'list electives', 'elective courses', 'available electives'])) {
      _displayCoursesList('Elective');
      return true;
    }

    // Semester-specific course listing
    RegExp semesterRegex = RegExp(r'(semester\s*(\d+)|(\d+)(st|nd|rd|th)\s+semester)');
    var semesterMatch = semesterRegex.firstMatch(message);
    if (semesterMatch != null && _matchesCommand(message, ['courses', 'subjects', 'classes'])) {
      String semester = semesterMatch.group(2) ?? semesterMatch.group(3) ?? "";
      _displayCoursesList('Semester', semester: semester);
      return true;
    }

    // Recommendations
    if (_matchesCommand(message, ['recommend', 'suggest', 'recommendations', 'suggestions'])) {
      _generateCourseRecommendations();
      return true;
    }

    // Schedule conflicts
    if (_matchesCommand(message, ['check conflicts', 'schedule conflicts', 'time clashes', 'conflicts'])) {
      _checkForScheduleConflicts();
      return true;
    }

    return false;
  }

  // Helper method for command matching
  bool _matchesCommand(String message, List<String> commands) {
    return commands.any((command) => message.contains(command));
  }

  void _checkForScheduleConflicts() {
    if (_currentCourses.isEmpty) {
      _addBotMessage(
          "You haven't enrolled in any courses yet. Please enroll first to allow me to check for scheduling conflicts.");
      return;
    }

    if (_timetableData == null || _timetableData!.trim().isEmpty) {
      _addBotMessage(
          "Your timetable data is missing. Please upload your schedule file or enter your timetable details to proceed with conflict checking.");
      return;
    }

    final prompt = """
You are a university schedule analysis assistant. A student has enrolled in the following courses: ${_currentCourses.join(', ')}.

Their timetable details are:
${_timetableData!}

Your task is to:
1. Check for any **scheduling conflicts** (courses occurring at overlapping times).
2. Specify clearly:
   - Which courses conflict
   - The exact day(s) and time(s) of the conflict
3. If there are **no conflicts**, explicitly confirm that the schedule is conflict-free.

Respond in **Markdown** format using bullet points or tables for clarity.
Use **bold** for course codes and times. Be concise and helpful.
""";

    _getGeminiResponse(prompt).then((response) {
      _addBotMessage(response);
    });
  }


  void _suggestCoursesForCareer(String message) {
    final prompt = """
You are an academic advisor helping IT students choose electives based on their career goals.

The student has asked: "$message"

Your task is to:
1. Identify the **specific career field or role** mentioned or implied.
2. Recommend **IT elective courses** from the university's catalog that best support this career.
3. For each recommended course, include:
   - **Course code and name**
   - **Why it is relevant** to the chosen career
   - **Key skills or technologies** it teaches (e.g., networking, AI, cybersecurity, UX, etc.)
   - Any industry tools or certifications it aligns with

Guidelines:
- Be precise and supportive in your recommendations.
- Use **Markdown** formatting:
  - Bold course codes and keywords
  - Use bullet points or numbered lists for clarity
- Personalize your answer based on the student's query.
- Avoid generic advice—make each recommendation clearly tied to the career goal.
""";

    _getGeminiResponse(prompt).then((response) {
      _addBotMessage(response);
    });
  }


  Future<String> _getGeminiResponse(String message) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      return "API key not configured. Please set up the Gemini API key to enable AI recommendations.";
    }

    try {
      // Prepare the context for the AI with more detailed information
      // Removed free time slots from contextData
      final contextData = {
        "role": "You are a knowledgeable university course selection assistant. Your goal is to help students choose courses that match their interests, fit their schedule, and fulfill their degree requirements.",
        "current_courses": _currentCourses,
        "timetable_status": _timetableData != null ? "Provided" : "Not provided",
        "user_interests": _userInterests,
        "specific_instructions": "Always provide specific, actionable advice. Highlight course codes in bold. If recommending courses, explain why they match the student's interests or schedule."
      };

      // Call the Gemini API with the enhanced context
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
                
                User's current courses: ${_currentCourses.isEmpty ? "None registered yet" : _currentCourses.join(", ")}
                
                User's timetable status: ${_timetableData ?? "Not provided yet"}
                
                User's interests: ${_userInterests.isEmpty ? "Not specified yet" : _userInterests.join(", ")}
                
                User query: $message
                
                Your task is to provide intelligent, helpful guidance on course selection.
                Be specific, engaging, and supportive. Focus on actionable advice.
                
                When discussing specific courses, always mention:
                1. Course code and full name
                2. Credit hours
                3. Why it matches the student's interests or schedule
                4. Potential career relevance
                
                For timetable analysis, prioritize identifying:
                1. Course conflicts/clashes
                2. Which specific electives could fit the student's interests
                
                Format your response with Markdown:
                - Use **bold** for course codes and important information
                - Use *italics* for emphasis
                - Use proper lists and structure for readability
                
                Personalize your responses based on the student's stated interests.
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
          duration: const Duration(milliseconds: 300),
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
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: const TextStyle(
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
            const Padding(
              padding: EdgeInsets.only(right: 8.0, left: 12.0, top: 6.0),
              child: CircleAvatar(
                radius: 16,
                backgroundColor:Color(0xFF16213E),
                child: Icon(Icons.school, size: 18, color: Colors.white),
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFF16213E) : const Color(0xFF16213E),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isUser
                  ? Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              )
                  : MarkdownBody(
                data: text,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                  strong: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  em: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  ),
                  h1: const TextStyle(color: Colors.white),
                  h2: const TextStyle(color: Colors.white),
                  h3: const TextStyle(color: Colors.white),
                  h4: const TextStyle(color: Colors.white),
                  h5: const TextStyle(color: Colors.white),
                  h6: const TextStyle(color: Colors.white),
                  code: const TextStyle(color: Colors.white),
                  blockquote: const TextStyle(color: Colors.white),
                  listBullet: const TextStyle(color: Colors.white),
                  tableHead: const TextStyle(color: Colors.white),
                  tableBody: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          if (isUser)
            const Padding(
              padding: EdgeInsets.only(left: 8.0, right: 12.0, top: 6.0),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFF16213E),
                child: Icon(Icons.person, size: 18, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String welcomeTitle =  'Course Selection Assistant';
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
              // Interest tags if any
              if (_userInterests.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.black.withOpacity(0.3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Interests:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[300],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _userInterests.map((interest) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF16213E),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              interest,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

              Expanded(
                child: _isLoading && _messages.isEmpty
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF9C7FE2)))
                    : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
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
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Thinking...",
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),

              // Timetable input mode indicator
              if (_isTimetableInputActive)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          border: Border.all(color: Colors.cyan, width: 1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit_note, size: 16, color: Colors.cyan),
                            SizedBox(width: 6),
                            Text(
                              "Timetable Input Mode Active",
                              style: TextStyle(
                                color: Colors.cyan,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Input area
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                color: Colors.black.withOpacity(0.2),
                child: Row(
                  children: [
                    // Upload file button
                    IconButton(
                      icon: const Icon(Icons.attach_file, color: Colors.white),
                      onPressed: _isLoading ? null : () => _pickTimetableFile(),
                      tooltip: 'Upload timetable file',
                    ),
                    // Text input field
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        enabled: !_isLoading,
                        decoration: InputDecoration(
                          hintText: _isTimetableInputActive
                              ? 'Enter your timetable data here...'
                              : 'Ask a question about courses...',
                          hintStyle: const TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) => _sendMessage(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Send button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _sendMessage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16213E),
                        foregroundColor: Colors.white,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(12),
                      ),
                      child: const Icon(Icons.send, size: 20),
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

  // Method to handle file picking and processing
  Future<void> _pickTimetableFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'csv', 'pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() => _isLoading = true);

        final file = result.files.first;
        String fileContent;

        // Handle PDF files specifically
        if (file.extension?.toLowerCase() == 'pdf') {

          // Prepare PDF data for the API
          String base64Data;
          if (file.bytes != null) {
            // Web platform - file is available as bytes
            base64Data = base64Encode(file.bytes!);
          } else if (file.path != null) {
            // Mobile/desktop platform - file is available as path
            final fileBytes = await File(file.path!).readAsBytes();
            base64Data = base64Encode(fileBytes);
          } else {
            throw Exception("Unable to read PDF file content");
          }
          // Process the PDF directly through the API
          String pdfAnalysis = await _processPDF(base64Data, file.name);

          // Store the analysis result as timetable data
          setState(() {
            _timetableData = pdfAnalysis;
            _isLoading = false;

            // Add the file upload message to chat history
            _messages.add({
              'sender': 'user',
              'message': "I've uploaded my timetable PDF: ${file.name}"
            });
          });
          // Display the analysis result
          _addBotMessage("I've analyzed your timetable PDF. Here's what I found:\n\n$pdfAnalysis");
          return;
        } else {
          // Handle regular text files (txt, csv)
          if (file.bytes != null) {
            // Web platform - file is available as bytes
            fileContent = utf8.decode(file.bytes!);
          } else if (file.path != null) {
            // Mobile/desktop - file is available as path
            final fileBytes = await File(file.path!).readAsBytes();
            fileContent = utf8.decode(fileBytes);
          } else {
            throw Exception("Unable to read file content");
          }
        }

        // Add context prompt for the user
        _addBotMessage("I've successfully extracted the timetable data. Is there anything specific about this timetable you'd like me to focus on? For example, any scheduling preferences or concerns?");

        // Wait for user response before proceeding
        setState(() {
          _timetableData = fileContent;
          _isLoading = false;
          // Add the file upload message to chat history
          _messages.add({
            'sender': 'user',
            'message': "I've uploaded my timetable file: ${file.name}"
          });
        });
      }
    } catch (e) {
      _addSystemMessage("Error processing timetable file: $e");
      setState(() => _isLoading = false);
    }
  }
  // Method to get current user's semester from Firestore
  Future<String> _getCurrentUserSemester() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception("User not authenticated");
      }

      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        return userData?['semester']?.toString() ?? 'current';
      } else {
        return 'current';
      }
    } catch (e) {
      print('Error fetching user semester: $e');
      return 'current';
    }
  }
  // Enhanced method to process PDF with Gemini API including semester context
  Future<String> _processPDF(String base64Data, String fileName) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception("API key not configured.");
    }
    try {
      // Get the current user's semester from Firestore
      final semester = await _getCurrentUserSemester();

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
                You are a specialized AI assistant for parsing and analyzing university timetables.
                
                The user has uploaded a PDF file containing their university timetable or course schedule.
                The user is currently in semester $semester.
                
                Please analyze this PDF and extract the following information:
                
                1. The full course names and course codes
                2. Focus on courses that are relevant to semester $semester
                3. The scheduled times for each course (days and specific hours)
                4. Any location information for the classes (room numbers, building names)
                5. Any additional relevant details about the courses (instructor names, course types)
                
                After extracting this information, please:
                - Format it in a clear, structured way
                - Identify any potential time conflicts between courses
                - Identify free time slots during standard university hours (8AM-6PM) for each day
                - Group courses by days of the week
                - Highlight any courses that specifically mention semester $semester
                
                Present this information in a well-organized format that makes it easy to understand the schedule.
                If you cannot find specific semester information in the PDF, extract all visible course information.
                """
                },
                {
                  "inlineData": {
                    "mimeType": "application/pdf",
                    "data": base64Data
                  }
                }
              ]
            }
          ],
          "generationConfig": {
            "temperature": 0.2,
            "topK": 40,
            "topP": 0.95,
            "maxOutputTokens": 2048,
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
          return "I processed the PDF but couldn't extract meaningful timetable data. Please try uploading a clearer PDF or enter the information manually.";
        }
      } else {
        return "Error processing PDF with Gemini API: ${response.statusCode} ${response.body}. Please try again later or enter your timetable manually.";
      }
    } catch (e) {
      return "Technical error when processing PDF: $e. Please try again later or enter your timetable manually.";
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}