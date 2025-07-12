import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:async';

const String GEMINI_API_KEY = 'AIzaSyDu4hwJ701gyYElEQEKQfEQPct9549RGjY';

// Difficulty enum
enum InterviewDifficulty { easy, medium, hard }
InterviewDifficulty _selectedDifficulty = InterviewDifficulty.medium;
// Extension for difficulty
extension InterviewDifficultyExtension on InterviewDifficulty {
  String get displayName {
    switch (this) {
      case InterviewDifficulty.easy:
        return 'Easy';
      case InterviewDifficulty.medium:
        return 'Medium';
      case InterviewDifficulty.hard:
        return 'Hard';
    }
  }

  String get description {
    switch (this) {
      case InterviewDifficulty.easy:
        return 'Basic questions, perfect for beginners';
      case InterviewDifficulty.medium:
        return 'Intermediate questions with some complexity';
      case InterviewDifficulty.hard:
        return 'Advanced questions, challenging scenarios';
    }
  }

  Color get color {
    switch (this) {
      case InterviewDifficulty.easy:
        return Colors.green;
      case InterviewDifficulty.medium:
        return Colors.orange;
      case InterviewDifficulty.hard:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (this) {
      case InterviewDifficulty.easy:
        return Icons.sentiment_satisfied;
      case InterviewDifficulty.medium:
        return Icons.sentiment_neutral;
      case InterviewDifficulty.hard:
        return Icons.sentiment_very_dissatisfied;
    }
  }
}

// Models
class InterviewQuestion {
  final String question;
  final String userAnswer;
  final int questionNumber;
  final DateTime timestamp;

  InterviewQuestion({
    required this.question,
    required this.userAnswer,
    required this.questionNumber,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'userAnswer': userAnswer,
      'questionNumber': questionNumber,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class InterviewResult {
  final String topic;
  final String jobTitle;
  final InterviewDifficulty difficulty;
  final List<InterviewQuestion> questions;
  final String overallFeedback;
  final double score;
  final DateTime completedAt;
  final Duration duration;

  InterviewResult({
    required this.topic,
    required this.jobTitle,
    required this.difficulty,
    required this.questions,
    required this.overallFeedback,
    required this.score,
    required this.completedAt,
    required this.duration,
  });

  Map<String, dynamic> toMap() {
    return {
      'topic': topic,
      'jobTitle': jobTitle,
      'difficulty': difficulty.name,
      'questions': questions.map((q) => q.toMap()).toList(),
      'overallFeedback': overallFeedback,
      'score': score,
      'completedAt': completedAt.toIso8601String(),
      'duration': duration.inSeconds,
      'totalQuestions': questions.length,
    };
  }
}

// Mock Interview Setup Screen
class MockInterviewSetupScreen extends StatefulWidget {
  const MockInterviewSetupScreen({super.key});

  @override
  _MockInterviewSetupScreenState createState() => _MockInterviewSetupScreenState();
}

class _MockInterviewSetupScreenState extends State<MockInterviewSetupScreen> {
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Mock Interview',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Setup Form
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // AI Interview Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.purple.withOpacity(0.2),
                                Colors.blue.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.purple.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.smart_toy,
                                  size: 40,
                                  color: Colors.purple,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'AI Mock Interview',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Practice interviews with AI-powered questions tailored to your field',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[300],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Topic Input
                        const Text(
                          'Interview Topic',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _topicController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            // hintText: 'e.g., Data Structures, Machine Learning, React.js',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[800],
                            prefixIcon: const Icon(Icons.topic, color: Colors.purple),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Job Title Input
                        const Text(
                          'Job Title',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _jobTitleController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            // hintText: 'e.g., Software Engineer, Data Scientist, Frontend Developer',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[800],
                            prefixIcon: const Icon(Icons.work, color: Colors.blue),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

// Difficulty Selection
                        const Text(
                          'Difficulty Level',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),

// Difficulty Options
                        Column(
                          children: InterviewDifficulty.values.map((difficulty) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: RadioListTile<InterviewDifficulty>(
                                value: difficulty,
                                groupValue: _selectedDifficulty,
                                onChanged: (InterviewDifficulty? value) {
                                  setState(() {
                                    _selectedDifficulty = value!;
                                  });
                                },
                                title: Text(
                                  difficulty.displayName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  difficulty.description,
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                ),
                                activeColor: difficulty.color,
                                fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                                  return difficulty.color;
                                }),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 40),

                        // Features List
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[800]?.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.grey[600]!.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'What to Expect:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildFeatureItem(
                                Icons.mic,
                                'Voice-based interview',
                                'Speak your answers naturally',
                              ),
                              _buildFeatureItem(
                                Icons.psychology,
                                'AI-generated questions',
                                'Dynamic questions based on your topic',
                              ),
                              _buildFeatureItem(
                                Icons.analytics,
                                'Detailed feedback',
                                'Get comprehensive analysis of your performance',
                              ),
                              _buildFeatureItem(
                                Icons.timer,
                                'Flexible duration',
                                'End the interview anytime by saying "end"',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Start Interview Button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _startInterview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6060FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      'Start Interview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.purple, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _startInterview() {
    if (_topicController.text.trim().isEmpty ||
        _jobTitleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in both topic and job title'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Navigate to interview screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MockInterviewScreen(
          topic: _topicController.text.trim(),
          jobTitle: _jobTitleController.text.trim(),
          difficulty: _selectedDifficulty,
        ),
      ),
    ).then((_) {
      setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    _topicController.dispose();
    _jobTitleController.dispose();
    super.dispose();
  }
}

// Mock Interview Screen
class MockInterviewScreen extends StatefulWidget {
  final String topic;
  final String jobTitle;
  final InterviewDifficulty difficulty;

  const MockInterviewScreen({
    super.key,
    required this.topic,
    required this.jobTitle,
    required this.difficulty,
  });

  @override
  _MockInterviewScreenState createState() => _MockInterviewScreenState();
}

class _MockInterviewScreenState extends State<MockInterviewScreen> {
  late GenerativeModel _model;
  late SpeechToText _speechToText;
  late FlutterTts _flutterTts;

  final List<InterviewQuestion> _questions = [];
  String _currentQuestion = '';
  String _currentAnswer = '';
  bool _isListening = false;
  bool _isLoading = false;
  bool _isSpeaking = false;
  bool _interviewStarted = false;
  int _currentQuestionNumber = 1;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    // Initialize Gemini AI
    _model = GenerativeModel(
      model: 'gemini-2.0-flash-exp',
      apiKey: GEMINI_API_KEY,
    );

    // Initialize Speech Recognition
    _speechToText = SpeechToText();
    await _speechToText.initialize();

    // Initialize Text-to-Speech
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(0.8);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() => _isSpeaking = false);
      }
    });

    _startInterview();
  }

  Future<void> _startInterview() async {
    setState(() {
      _isLoading = true;
      _interviewStarted = true;
      _startTime = DateTime.now();
    });

    await _generateFirstQuestion();
  }

  Future<void> _generateFirstQuestion() async {
    try {
      final prompt = '''
You are conducting a mock interview for a ${widget.jobTitle} position focusing on ${widget.topic}.
Difficulty level: ${widget.difficulty.displayName} - ${widget.difficulty.description}
Generate the first interview question that would be appropriate for this role, topic, and difficulty level.
Make the question ${widget.difficulty.displayName.toLowerCase()} level complexity.
Return only the question text, nothing else.
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (mounted) {
        setState(() {
          final responseText = response.text?.trim();
          if (responseText == null || responseText.isEmpty) {
            _currentQuestion = "Tell me about yourself and your experience with ${widget.topic}";
          } else {
            _currentQuestion = responseText;
          }
          _isLoading = false;
        });

        await _speakQuestion();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentQuestion = "Tell me about yourself and your experience with ${widget.topic}";
          _isLoading = false;
        });
        await _speakQuestion();
      }
    }
  }

  Future<void> _speakQuestion() async {
    if (mounted) {
      setState(() => _isSpeaking = true);
      await _flutterTts.speak(_currentQuestion);
    }
  }

  Future<void> _startListening() async {
    if (!_isListening && !_isSpeaking && mounted) {
      setState(() => _isListening = true);

      await _speechToText.listen(
        onResult: (result) {
          if (mounted) {
            setState(() {
              _currentAnswer = result.recognizedWords;
            });

            // Check if user wants to end the interview
            if (_currentAnswer.toLowerCase().contains('end') ||
                _currentAnswer.toLowerCase().contains('finish') ||
                _currentAnswer.toLowerCase().contains('stop')) {
              _endInterview();
            }
          }
        },
        listenFor: const Duration(seconds: 60),
        pauseFor: const Duration(seconds: 5),
      );
    }
  }

  void _stopListening() {
    if (_isListening) {
      _speechToText.stop();
      if (mounted) {
        setState(() => _isListening = false);
      }
    }
  }

  Future<void> _submitAnswer() async {
    if (_currentAnswer.trim().isEmpty) return;

    _stopListening();

    // Save current question and answer
    _questions.add(InterviewQuestion(
      question: _currentQuestion,
      userAnswer: _currentAnswer,
      questionNumber: _currentQuestionNumber,
      timestamp: DateTime.now(),
    ));

    if (mounted) {
      setState(() {
        _isLoading = true;
        _currentQuestionNumber++;
      });

      // Generate next question based on the conversation
      await _generateNextQuestion();
    }
  }

  Future<void> _generateNextQuestion() async {
    try {
      final conversationContext = _questions.map((q) =>
      "Q${q.questionNumber}: ${q.question}\nA${q.questionNumber}: ${q.userAnswer}"
      ).join('\n\n');

      final prompt = '''
You are conducting a mock interview for a ${widget.jobTitle} position focusing on ${widget.topic}.
Difficulty level: ${widget.difficulty.displayName} - ${widget.difficulty.description}
Based on the conversation so far:

$conversationContext

Generate the next appropriate interview question at ${widget.difficulty.displayName.toLowerCase()} difficulty level. Consider:
- The candidate's previous answers
- The job role requirements
- The topic focus
- Make it progressively more challenging
- Keep it relevant and professional

Return only the question text, nothing else.
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (mounted) {
        setState(() {
          _currentQuestion = response.text ?? "Can you elaborate more on your experience with ${widget.topic}?";
          _currentAnswer = '';
          _isLoading = false;
        });

        await _speakQuestion();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentQuestion = "Can you elaborate more on your experience with ${widget.topic}?";
          _currentAnswer = '';
          _isLoading = false;
        });
        await _speakQuestion();
      }
    }
  }

  Future<void> _endInterview() async {
    _stopListening();
    await _flutterTts.stop();

    if (_questions.isEmpty) {
      if (mounted) {
        Navigator.pop(context);
      }
      return;
    }

    if (mounted) {
      setState(() => _isLoading = true);

      // Generate feedback and results
      await _generateFeedbackAndSave();
    }
  }

  Future<void> _generateFeedbackAndSave() async {
    try {
      print('Generating feedback...');
      final conversationContext = _questions.map((q) =>
      "Q${q.questionNumber}: ${q.question}\nA${q.questionNumber}: ${q.userAnswer}"
      ).join('\n\n');

      final prompt = '''
Analyze this mock interview for a ${widget.jobTitle} position focusing on ${widget.topic}:

$conversationContext

Provide detailed feedback in the following format:

SCORE: [number from 0-100]

FEEDBACK:
Technical Knowledge: [Assessment of technical skills demonstrated]
Communication Skills: [Assessment of how well they communicated]
Completeness: [Assessment of how complete their answers were]
Strengths: [Key strengths observed]
Areas for Improvement: [Specific areas to work on]
Overall Assessment: [General summary of performance]

Make sure to provide specific, actionable feedback.
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      print('Feedback response: ${response.text}');

      // Parse the structured response
      String feedbackText = response.text ?? '';
      double score = 75; // Default score
      String feedback = 'Good performance overall. Continue practicing to improve your interview skills.';

      // Extract score
      final scoreMatch = RegExp(r'SCORE:\s*(\d+)').firstMatch(feedbackText);
      if (scoreMatch != null) {
        score = double.tryParse(scoreMatch.group(1)!) ?? 75;
      }

      // Extract feedback
      final feedbackMatch = RegExp(r'FEEDBACK:\s*(.*)', dotAll: true).firstMatch(feedbackText);
      if (feedbackMatch != null) {
        feedback = feedbackMatch.group(1)!.trim();
      }

      print('Parsed score: $score');
      print('Parsed feedback: $feedback');

      final interviewResult = InterviewResult(
        topic: widget.topic,
        jobTitle: widget.jobTitle,
        difficulty: widget.difficulty,
        questions: _questions,
        overallFeedback: feedback,
        score: score,
        completedAt: DateTime.now(),
        duration: DateTime.now().difference(_startTime!),
      );

      // Try to save to Firebase
      try {
        await _saveToFirebase(interviewResult);
      } catch (e) {
        print('Firebase save failed, but continuing: $e');
      }

      // Navigate to results screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => InterviewResultsScreen(result: interviewResult),
          ),
        );
      }
    } catch (e) {
      print('Error generating feedback: $e');

      // Create fallback result
      final fallbackResult = InterviewResult(
        topic: widget.topic,
        jobTitle: widget.jobTitle,
        difficulty: widget.difficulty,
        questions: _questions,
        overallFeedback: 'Interview completed successfully. You answered ${_questions.length} questions. Continue practicing to improve your skills.',
        score: 75,
        completedAt: DateTime.now(),
        duration: DateTime.now().difference(_startTime!),
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => InterviewResultsScreen(result: fallbackResult),
          ),
        );
      }
    }
  }


  Future<void> _saveToFirebase(InterviewResult result) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('mockInterviews')
          .add(result.toMap());

      print('Interview results saved successfully');
    } catch (e) {
      print('Error saving to Firebase: $e');
      // Show user-friendly error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save results: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      rethrow; // Re-throw to handle in calling method
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0A0A),
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => _showEndDialog(),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            widget.jobTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.topic,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Q$_currentQuestionNumber',
                        style: const TextStyle(
                          color: Colors.purple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Question Display
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.grey[900]!.withOpacity(0.9),
                                Colors.grey[800]!.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.purple.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: Colors.purple,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.smart_toy,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'AI Interviewer',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (_isSpeaking)
                                    const Icon(
                                      Icons.volume_up,
                                      color: Colors.purple,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              if (_isLoading)
                                const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.purple,
                                  ),
                                )
                              else
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Text(
                                      _currentQuestion,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Answer Display
                      if (_currentAnswer.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Your Answer:',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _currentAnswer,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 20),

                      // Control Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading || _isSpeaking
                                  ? null
                                  : (_isListening ? _stopListening : _startListening),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isListening
                                    ? Colors.red
                                    : Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 15),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _isListening ? Icons.stop : Icons.mic,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isListening ? 'Stop' : 'Start Answer',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          if (_currentAnswer.isNotEmpty)
                            ElevatedButton(
                              onPressed: _isLoading ? null : _submitAnswer,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6060FF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 15,
                                ),
                              ),
                              child: const Text(
                                'Next',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      // End Interview Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _endInterview,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text(
                            'End Interview',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEndDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('End Interview?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to end the interview? Your progress will be saved.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _endInterview();
            },
            // Complete the showEndDialog method
            child: const Text('End Interview', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _speechToText.cancel();
    _flutterTts.stop();
    super.dispose();
  }
}

// Interview Results Screen
class InterviewResultsScreen extends StatelessWidget {
  final InterviewResult result;

  const InterviewResultsScreen({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0A0A),
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                    ),
                    const Text(
                      'Interview Results',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Score Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getScoreColor(result.score).withOpacity(0.2),
                        _getScoreColor(result.score).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getScoreColor(result.score).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${result.score.toInt()}',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: _getScoreColor(result.score),
                        ),
                      ),
                      Text(
                        'Overall Score',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[300],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _getScoreLabel(result.score),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _getScoreColor(result.score),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Interview Details
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailCard(
                        'Duration',
                        _formatDuration(result.duration),
                        Icons.timer,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildDetailCard(
                        'Questions',
                        '${result.questions.length}',
                        Icons.quiz,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Feedback Section
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[900]?.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.grey[700]!.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Detailed Feedback',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(
                              result.overallFeedback,
                              style: TextStyle(
                                color: Colors.grey[300],
                                fontSize: 16,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _viewDetailedResults(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text(
                          'View Q&A',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6060FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[800]?.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey[600]!.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.purple, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getScoreLabel(double score) {
    if (score >= 90) return 'Excellent';
    if (score >= 80) return 'Good';
    if (score >= 70) return 'Average';
    if (score >= 60) return 'Below Average';
    return 'Needs Improvement';
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  void _viewDetailedResults(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailedResultsScreen(result: result),
      ),
    );
  }
}

// Detailed Results Screen
class DetailedResultsScreen extends StatelessWidget {
  final InterviewResult result;

  const DetailedResultsScreen({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0A0A),
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Questions & Answers',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Q&A List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: result.questions.length,
                  itemBuilder: (context, index) {
                    final question = result.questions[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[900]?.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.grey[700]!.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Question ${question.questionNumber}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            question.question,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            'Your Answer:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            question.userAnswer,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[300],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}