import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure the context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get current user
      final User? user = _auth.currentUser;

      if (user != null) {
        // Extract roll number from email (email format is rollNumber@iit.com)
        final String rollNumber = user.email!.split('@')[0];
        _userRollNumber = rollNumber;

        // Fetch user data from Firestore
        final DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(rollNumber).get();

        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _userData = data;

            // Extract courses
            if (data.containsKey('courses') && data['courses'] is List) {
              _courses = List<Map<String, dynamic>>.from(data['courses']);
            }

            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'User data not found';
          });
          _showErrorSnackBar('User data not found');
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'User not authenticated';
        });
        _showErrorSnackBar('User not authenticated');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading profile: $e';
      });
      _showErrorSnackBar('Error loading profile: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    // This is now safe because we're using addPostFrameCallback in initState
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
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

      setState(() {
        _isLoading = true;
      });

      try {
        // Add course to local state
        setState(() {
          _courses.add(selectedCourse);
        });

        // Update in Firestore
        await _firestore.collection('users').doc(_userRollNumber).update({
          'courses': _courses,
        });

        setState(() {
          _isLoading = false;
        });

        _showSuccessSnackBar('Course added successfully');
      } catch (e) {
        setState(() {
          _isLoading = false;
          // Remove course from local state if update failed
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
          title: const Text('Remove Course'),
          content: Text('Are you sure you want to remove ${course['name']}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Remove course from local state
      setState(() {
        _courses.removeWhere((c) => c['code'] == course['code']);
      });

      // Update in Firestore
      await _firestore.collection('users').doc(_userRollNumber).update({
        'courses': _courses,
      });

      setState(() {
        _isLoading = false;
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
          title: const Text('Select Course to Add'),
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
                        ),
                      ),
                    ),
                    ...semesterCourses.map((course) {
                      return ListTile(
                        title: Text(course['name']),
                        subtitle: Text('${course['code']} - ${course['creditHours']} Credits'),
                        trailing: Text(course['category']),
                        onTap: () {
                          Navigator.of(context).pop(course);
                        },
                      );
                    }).toList(),
                    const Divider(),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color(0xFF4E5FE8),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              // Navigate to login screen after sign out
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCourse,
        backgroundColor: const Color(0xFF4E5FE8),
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userData == null
          ? const Center(child: Text('No profile data available'))
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF4E5FE8), Color(0xFFE9D7F6)],
                ),
              ),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white70,
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Color(0xFF4E5FE8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${_userData!['firstName']} ${_userData!['lastName']}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _userData!['email'] ?? 'No email',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white30,
                      borderRadius: BorderRadius.circular(20),
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

            // Personal Information
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1E2C),
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildInfoRow('First Name', _userData!['firstName'] ?? 'N/A'),
                    const Divider(),
                    _buildInfoRow('Last Name', _userData!['lastName'] ?? 'N/A'),
                    const Divider(),
                    _buildInfoRow('Roll Number', _userData!['email']?.split('@')[0] ?? 'N/A'),
                    const Divider(),
                    _buildInfoRow('Current Semester', _userData!['semester'] ?? 'N/A'),
                  ],
                ),
              ),
            ),

            // Courses Information
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Enrolled Courses',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1E2C),
                    ),
                  ),
                  Text(
                    'Total: ${_calculateTotalCreditHours()} Credit Hours',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B6B6B),
                    ),
                  ),
                ],
              ),
            ),

            // Course List
            _courses.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.book_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No courses enrolled yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _addCourse,
                      child: const Text('Add Course'),
                    ),
                  ],
                ),
              ),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _courses.length,
              itemBuilder: (context, index) {
                final course = _courses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Text(
                      course['name'] ?? 'Unknown Course',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Course Code: ${course['code'] ?? 'N/A'}'),
                        Text('Credit Hours: ${course['creditHours']?.toString() ?? 'N/A'}'),
                        Text('Type: ${course['type'] ?? 'N/A'}'),
                        Text('Category: ${course['category'] ?? 'N/A'}'),
                      ],
                    ),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(course['category']),
                        borderRadius: BorderRadius.circular(8),
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
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _removeCourse(course),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6B6B6B),
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1A1E2C),
              fontSize: 16,
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