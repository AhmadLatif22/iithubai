import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' show min;

import 'package:project/Widgets/login.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  List<Map<String, dynamic>> _courses = [];
  String? _errorMessage;
  String? _userRollNumber;

  Future<void> logout() async {
    try {
      // Sign out from Firebase Auth
      await _auth.signOut();

      // Clear only isLoggedIn flag but keep the roll number
      // This way user credentials are preserved but they're technically logged out
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);

      // Navigate back to login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SignInScreen()),
      );
    } catch (e) {
      print('Error during logout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    // Add auth state listener to reload data when auth state changes
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        debugPrint('Auth state changed: User logged in - ${user.email}');
        // Small delay to ensure auth is fully initialized
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _loadUserData();
        });
      } else {
        debugPrint('Auth state changed: User logged out');
      }
    });

    // Initial load
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Increase the delay to ensure Firebase Auth is fully initialized
      await Future.delayed(const Duration(milliseconds: 1000));

      // Get current user
      final User? user = _auth.currentUser;

      // Add debug output to help diagnose the issue
      debugPrint('Current user: ${user?.uid}, Email: ${user?.email}');

      if (user != null && user.email != null) {
        // Extract roll number from email (email format is rollNumber@iit.com)
        final String rollNumber = user.email!.split('@')[0];
        _userRollNumber = rollNumber;

        // Log for debugging
        debugPrint('Loading data for user: $rollNumber');

        // Fetch user data from Firestore
        final DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(rollNumber).get();

        if (mounted) {  // Check if widget is still mounted before updating state
          if (userDoc.exists) {
            final data = userDoc.data() as Map<String, dynamic>;
            debugPrint('User data loaded successfully: ${data.toString().substring(0, min(100, data.toString().length))}');

            setState(() {
              _userData = data;

              // Extract courses
              if (data.containsKey('courses') && data['courses'] is List) {
                _courses = List<Map<String, dynamic>>.from(data['courses']);
              }

              _isLoading = false;
            });
          } else {
            debugPrint('User document does not exist for: $rollNumber');
            setState(() {
              _isLoading = false;
              _errorMessage = 'User data not found';
            });
            _showErrorSnackBar('User document not found for roll number: $rollNumber');
          }
        }
      } else {
        debugPrint('No user is currently signed in or email is null');
        if (mounted) {  // Check if widget is still mounted
          setState(() {
            _isLoading = false;
            _errorMessage = 'User not authenticated';
          });
          _showErrorSnackBar('User not authenticated. Please sign out and sign in again.');
        }
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      if (mounted) {  // Check if widget is still mounted
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error loading profile: $e';
        });
        _showErrorSnackBar('Error loading profile: $e');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.purple[700],
      ),
    );
  }

  double _calculateTotalCreditHours() {
    double total = 0.0;
    for (var course in _courses) {
      total += (course['creditHours'] as double? ?? 0.0);
    }
    return total;
  }

  // Function to add a course
  Future<void> _addCourse() async {
    if (_userRollNumber == null) return;

    // Show course selection dialog
    final selectedCourse = await _showCourseSelectionDialog();

    if (selectedCourse != null) {
      // Check if course is already added
      bool courseExists = _courses.any((course) =>
      course['code'] == selectedCourse['code']);

      if (courseExists) {
        _showErrorSnackBar('Course already added to your profile');
        return;
      }

      // Remove loading state for adding courses
      try {
        // Add course to local state
        setState(() {
          _courses.add(selectedCourse);
        });

        // Update in Firestore
        await _firestore.collection('users').doc(_userRollNumber).update({
          'courses': _courses,
        });

        _showSuccessSnackBar('Course added successfully');
      } catch (e) {
        // Remove course from local state if update failed
        setState(() {
          _courses.removeWhere((course) => course['code'] == selectedCourse['code']);
        });
        _showErrorSnackBar('Failed to add course: $e');
      }
    }
  }

  // Function to remove a course
  Future<void> _removeCourse(Map<String, dynamic> course) async {
    if (_userRollNumber == null) return;

    // Show confirmation dialog
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: const Text('Remove Course', style: TextStyle(color: Colors.white)),
          content: Text(
            'Are you sure you want to remove ${course['name']}?',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Remove', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    // Remove loading state for removing courses
    try {
      // Remove course from local state
      setState(() {
        _courses.removeWhere((c) => c['code'] == course['code']);
      });

      // Update in Firestore
      await _firestore.collection('users').doc(_userRollNumber).update({
        'courses': _courses,
      });

      _showSuccessSnackBar('Course removed successfully');
    } catch (e) {
      // Reload data to restore state
      _loadUserData();
      _showErrorSnackBar('Failed to remove course: $e');
    }
  }

  // All available courses from the curriculum
  final List<Map<String, dynamic>> _allCourses = [
    {'name': 'Functional English', 'code': 'EN-101', 'creditHours': 3.0, 'type': 'Core Course', 'category': 'Compulsory', 'semester': 1},
    {'name': 'Introduction to Pakistan Studies', 'code': 'PS-101', 'creditHours': 2.0, 'type': 'Core Course', 'category': 'Compulsory', 'semester': 1},
    {'name': 'Introduction to Computing', 'code': 'CS-101', 'creditHours': 3.0, 'type': 'Core Course', 'category': 'Compulsory', 'semester': 1},
    {'name': 'Calculus and Analytical Geometry-I', 'code': 'MA-101', 'creditHours': 3.0, 'type': 'Core Course', 'category': 'Compulsory', 'semester': 1},
    {'name': 'Introductory Mechanics and Waves', 'code': 'PH-101', 'creditHours': 2.0, 'type': 'Core Course', 'category': 'Faculty Elective', 'semester': 1},
    {'name': 'Introductory Mechanics and Waves Lab', 'code': 'PH-191', 'creditHours': 1.0, 'type': 'Core Course', 'category': 'Faculty Elective', 'semester': 1},

    {'name': 'Functional English-II', 'code': 'EN-102', 'creditHours': 3.0, 'type': 'Core Course', 'category': 'Compulsory', 'semester': 2},
    {'name': 'Islamic Studies', 'code': 'IS-101', 'creditHours': 2.0, 'type': 'Core Course', 'category': 'Compulsory', 'semester': 2},
    {'name': 'Calculus and Analytical Geometry-II', 'code': 'MA-102', 'creditHours': 3.0, 'type': 'Core Course', 'category': 'Compulsory', 'semester': 2},
    {'name': 'Introduction to Psychology', 'code': 'PY-101', 'creditHours': 3.0, 'type': 'Core Course', 'category': 'Compulsory', 'semester': 2},
    {'name': 'Electricity, Magnetism and Thermal Physics', 'code': 'PH-103', 'creditHours': 2.0, 'type': 'Core Course', 'category': 'Faculty Elective', 'semester': 2},
    {'name': 'Electricity, Magnetism and Thermal Physics Lab', 'code': 'PH-193', 'creditHours': 1.0, 'type': 'Core Course', 'category': 'Faculty Elective', 'semester': 2},
    {'name': 'Fundamentals of Information Technology', 'code': 'IT-101', 'creditHours': 3.0, 'type': 'Core Course', 'category': 'Domain Core', 'semester': 2},
    {'name': 'Functional English III', 'code': 'EN-203', 'creditHours': 3.0, 'type': 'Core Course', 'category': 'Compulsory', 'semester': 2},

    {'name': 'Computer Programming', 'code': 'IT-201', 'creditHours': 3.0, 'type': 'Core Course', 'category': 'Domain Core', 'semester': 3},
    {'name': 'Discrete Mathematics', 'code': 'IT-211', 'creditHours': 3.0, 'type': 'Core Course', 'category': 'Domain Core', 'semester': 3},
    {'name': 'Engineering Mathematics', 'code': 'IT-212', 'creditHours': 3.0, 'type': 'Core Course', 'category': 'Domain Core', 'semester': 3},
    {'name': 'Digital Logic Design', 'code': 'IT-221', 'creditHours': 3.0, 'type': 'Core Course', 'category': 'Domain Core', 'semester': 3},
    {'name': 'Economics', 'code': 'EC-201', 'creditHours': 3.0, 'type': 'Core Course', 'category': 'Faculty Elective', 'semester': 3},

    {'name': 'Computer Architecture', 'code': 'IT-222', 'creditHours': 3.0, 'type': 'Core Course', 'category': 'Domain Core', 'semester': 4},
    {'name': 'System Analysis and Design', 'code': 'IT-231', 'creditHours': 3.0, 'type': 'Core Course', 'category': 'Domain Core', 'semester': 4},
    {'name': 'Database Systems', 'code': 'IT-232', 'creditHours': 3.0, 'type': 'Core Course', 'category': 'Domain Core', 'semester': 4},
    {'name': 'Introduction to Geology', 'code': 'ES-101', 'creditHours': 3.0, 'type': 'Core Course', 'category': 'Faculty Elective', 'semester': 4},
    {'name': 'Differential Equations and Linear Algebra', 'code': 'MA-207', 'creditHours': 3.0, 'type': 'Core Course', 'category': 'Faculty Elective', 'semester': 4},
    {'name': 'Data Structures', 'code': 'IT-202', 'creditHours': 3.0, 'type': 'Core Course', 'category': 'Domain Core', 'semester': 4},

    {'name': 'Web Engineering', 'code': 'IT-332', 'creditHours': 3.0, 'type': 'Core Course', 'category': 'Domain Core', 'semester': 5},
    {'name': 'Operating System', 'code': 'IT-331', 'creditHours': 3.0, 'type': 'Core Course', 'category': 'Domain Core', 'semester': 5},
    {'name': 'Linear Circuit Analysis', 'code': 'IT-321', 'creditHours': 3.0, 'type': 'Core Course', 'category': 'Domain Core', 'semester': 5},
    {'name': 'Object Oriented Programming', 'code': 'IT-301', 'creditHours': 3.0, 'type': 'Core Course', 'category': 'Domain Core', 'semester': 5},
    {'name': 'Probability and Statistics', 'code': 'ST-101', 'creditHours': 3.0, 'type': 'Core Course', 'category': 'Faculty Elective', 'semester': 5},
    {'name': 'Communication Systems', 'code': 'IT-341', 'creditHours': 3.0, 'type': 'Core Course', 'category': 'Domain Core', 'semester': 5},

    {'name': 'Computer Communication and Networks', 'code': 'IT-342', 'creditHours': 3.0, 'type': 'Core Course', 'category': 'Domain Core', 'semester': 6},
    {'name': 'Analysis of Algorithm', 'code': 'IT-302', 'creditHours': 3.0, 'type': 'Core Course', 'category': 'Domain Core', 'semester': 6},
    {'name': 'Nonlinear Electronics', 'code': 'IT-322', 'creditHours': 3.0, 'type': 'Core Course', 'category': 'Domain Core', 'semester': 6},
    {'name': 'Software Engineering', 'code': 'IT-333', 'creditHours': 3.0, 'type': 'Core Course', 'category': 'Domain Core', 'semester': 6},
    {'name': 'Chemistry-1', 'code': 'CH-101', 'creditHours': 3.0, 'type': 'Core Course', 'category': 'Faculty Elective', 'semester': 6},

    {'name': 'Network Security & Management', 'code': 'IT-442', 'creditHours': 3.0, 'type': 'Core Course', 'category': 'Domain Core', 'semester': 7},
    {'name': 'Multimedia and Computer Graphics', 'code': 'IT-411', 'creditHours': 3.0, 'type': 'Core Course', 'category': 'Domain Core', 'semester': 7},
    {'name': 'Project I', 'code': 'IT-491', 'creditHours': 3.0, 'type': 'Core Course', 'category': 'Domain Core', 'semester': 7},

    {'name': 'Project-II', 'code': 'IT-492', 'creditHours': 3.0, 'type': 'Core Course', 'category': 'Domain Core', 'semester': 8},

    // Electives
    {'name': 'Theory of Automata', 'code': 'IT-412', 'creditHours': 3.0, 'type': 'Core Course', 'category': 'Elective', 'semester': null},
    {'name': 'Visual Programming', 'code': 'IT-402', 'creditHours': 3.0, 'type': 'Core Course', 'category': 'Elective', 'semester': null},
    {'name': 'Software Requirement Engineering', 'code': 'IT-434', 'creditHours': 3.0, 'type': 'Core Course', 'category': 'Elective', 'semester': null},
    {'name': 'Component Based Software Engineering', 'code': 'IT-435', 'creditHours': 3.0, 'type': 'Core Course', 'category': 'Elective', 'semester': null},
    {'name': 'Software Quality Assurance', 'code': 'IT-436', 'creditHours': 3.0, 'type': 'Core Course', 'category': 'Elective', 'semester': null},
    {'name': 'Mobile Computing', 'code': 'IT-441', 'creditHours': 3.0, 'type': 'Core Course', 'category': 'Elective', 'semester': null},
    {'name': 'Rapid Application Development', 'code': 'IT-401', 'creditHours': 3.0, 'type': 'Core Course', 'category': 'Elective', 'semester': null},
    {'name': 'Information System', 'code': 'IT-431', 'creditHours': 3.0, 'type': 'Core Course', 'category': 'Elective', 'semester': null},
    {'name': 'Advanced Database Systems', 'code': 'IT-432', 'creditHours': 3.0, 'type': 'Core Course', 'category': 'Elective', 'semester': null},
    {'name': 'Software Project Management', 'code': 'IT-433', 'creditHours': 3.0, 'type': 'Core Course', 'category': 'Elective', 'semester': null},
    {'name': 'Microcontroller and Interfacing', 'code': 'IT-421', 'creditHours': 3.0, 'type': 'Core Course', 'category': 'Elective', 'semester': null},
    {'name': 'Digital Image Processing', 'code': 'IT-442', 'creditHours': 3.0, 'type': 'Core Course', 'category': 'Elective', 'semester': null},
    {'name': 'Introduction to Machine Learning', 'code': 'IT-451', 'creditHours': 3.0, 'type': 'Core Course', 'category': 'Elective', 'semester': null},
    {'name': 'Organizational Behaviour', 'code': 'IT-461', 'creditHours': 3.0, 'type': 'Core Course', 'category': 'Elective', 'semester': null},
  ];

  // Function to show course selection dialog
  Future<Map<String, dynamic>?> _showCourseSelectionDialog() async {
    // Get courses that are not already added
    final availableCourses = _allCourses.where((course) {
      return !_courses.any((userCourse) => userCourse['code'] == course['code']);
    }).toList();

    // Group courses by semester for easier selection
    final groupedCourses = <int?, List<Map<String, dynamic>>>{};

    for (var course in availableCourses) {
      final semester = course['semester'];
      if (!groupedCourses.containsKey(semester)) {
        groupedCourses[semester] = [];
      }
      groupedCourses[semester]!.add(course);
    }

    // Sort the semester keys
    final sortedSemesters = groupedCourses.keys.toList()
      ..sort((a, b) {
        if (a == null) return 1;
        if (b == null) return -1;
        return a.compareTo(b);
      });

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: const Text('Select Course to Add', style: TextStyle(color: Colors.white)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: sortedSemesters.length,
              itemBuilder: (context, semesterIndex) {
                final semester = sortedSemesters[semesterIndex];
                final semesterCourses = groupedCourses[semester]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        semester == null
                            ? 'Electives'
                            : 'Semester $semester',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    ...semesterCourses.map((course) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[700],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          title: Text(
                            course['name'],
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            '${course['code']} - ${course['creditHours']} Credits',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(course['category']),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              course['category'],
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).pop(course);
                          },
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Add the gradient background
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.purple))
            : _userData == null
            ? const Center(child: Text('No profile data available', style: TextStyle(color: Colors.white)))
            : SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar with Back Button and Logout
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Text(
                        'My Profile',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: Colors.grey[800],
                              title: const Text("Logout", style: TextStyle(color: Colors.white)),
                              content: const Text("Are you sure you want to logout?", style: TextStyle(color: Colors.white70)),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("No", style: TextStyle(color: Colors.grey))
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Close the dialog first
                                    logout(); // Call the logout method
                                  },
                                  child: const Text("Yes", style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.3),
                            ),
                          ),
                          child: const Icon(
                            Icons.logout,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Profile Header
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey[900]!.withOpacity(0.9),
                        Colors.grey[800]!.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.purple.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.2),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Profile Avatar
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.purple.withOpacity(0.8),
                              Colors.blue.withOpacity(0.8),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.3),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${_userData!['firstName']} ${_userData!['lastName']}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.purple,
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        (_userData!['email'] ?? 'No email').split('@')[0],
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[300],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.purple.withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          'Semester ${_userData!['semester']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Personal Information
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey[900]!.withOpacity(0.9),
                        Colors.grey[800]!.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.purple.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.2),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('First Name', _userData!['firstName'] ?? 'N/A'),
                      const SizedBox(height: 12),
                      _buildInfoRow('Last Name', _userData!['lastName'] ?? 'N/A'),
                      const SizedBox(height: 12),
                      _buildInfoRow('Roll Number', _userData!['email']?.split('@')[0] ?? 'N/A'),
                      const SizedBox(height: 12),
                      _buildInfoRow('Current Semester', _userData!['semester']?.toString() ?? 'N/A'),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Courses Information
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey[900]!.withOpacity(0.9),
                        Colors.grey[800]!.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.purple.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.2),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Enrolled Courses',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Total: ${_calculateTotalCreditHours()} Credits',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[300],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Course List
                      _courses.isEmpty
                          ? Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            Icon(
                              Icons.book_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No courses enrolled yet',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: _addCourse,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.purple.withOpacity(0.5),
                                  ),
                                ),
                                child: const Text(
                                  'Add Course',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                          : Column(
                        children: [
                          ..._courses.map((course) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[700],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey[600]!,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Course Icon
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: _getCategoryColor(course['category']),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        (course['code'] ?? 'XX').substring(0, 2),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Course Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          course['name'] ?? 'Unknown Course',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${course['code']} • ${course['creditHours']} Credits',
                                          style: TextStyle(
                                            color: Colors.grey[300],
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: _getCategoryColor(course['category']).withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            course['category'] ?? 'N/A',
                                            style: TextStyle(
                                              color: _getCategoryColor(course['category']),
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Delete Button
                                  GestureDetector(
                                    onTap: () => _removeCourse(course),
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 16),
                          // Add Course Button
                          GestureDetector(
                            onTap: _addCourse,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.purple.withOpacity(0.5),
                                ),
                              ),
                              child: const Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.add, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'Add Course',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[700],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'Compulsory':
        return Colors.blue;
      case 'Domain Core':
        return Colors.green;
      case 'Faculty Elective':
        return Colors.purple;
      case 'Elective':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}