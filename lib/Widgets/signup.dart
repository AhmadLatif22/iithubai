import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController rollNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  String? selectedSemester;
  bool isLoading = false;
  bool _obscurePasswordText = true;
  bool _obscureConfirmPasswordText = true;

  // Map of semester courses based on the study scheme
  final Map<String, List<Map<String, dynamic>>> semesterCourses = {
    "1": [
      {"code": "EN-101", "name": "Functional English", "creditHours": 3.0, "type": "Core Course", "category": "Compulsory"},
      {"code": "PS-101", "name": "Introduction to Pakistan Studies", "creditHours": 2.0, "type": "Core Course", "category": "Compulsory"},
      {"code": "CS-101", "name": "Introduction to Computing", "creditHours": 3.0, "type": "Core Course", "category": "Compulsory"},
      {"code": "MA-101", "name": "Calculus and Analytical Geometry-I", "creditHours": 3.0, "type": "Core Course", "category": "Compulsory"},
      {"code": "PH-101", "name": "Introductory Mechanics and Waves", "creditHours": 2.0, "type": "Core Course", "category": "Faculty Elective"},
      {"code": "PH-191", "name": "Introductory Mechanics and Waves Lab", "creditHours": 1.0, "type": "Core Course", "category": "Faculty Elective"},
    ],
    "2": [
      {"code": "EN-102", "name": "Functional English-II", "creditHours": 3.0, "type": "Core Course", "category": "Compulsory"},
      {"code": "IS-101", "name": "Islamic Studies", "creditHours": 2.0, "type": "Core Course", "category": "Compulsory"},
      {"code": "MA-102", "name": "Calculus and Analytical Geometry-II", "creditHours": 3.0, "type": "Core Course", "category": "Compulsory"},
      {"code": "PY-101", "name": "Introduction to Psychology", "creditHours": 3.0, "type": "Core Course", "category": "Compulsory"},
      {"code": "PH-103", "name": "Electricity, Magnetism and Thermal Physics", "creditHours": 2.0, "type": "Core Course", "category": "Faculty Elective"},
      {"code": "PH-193", "name": "Electricity, Magnetism and Thermal Physics Lab", "creditHours": 1.0, "type": "Core Course", "category": "Faculty Elective"},
      {"code": "IT-101", "name": "Fundamentals of Information Technology", "creditHours": 3.0, "type": "Core Course", "category": "Domain Core"},
      {"code": "EN-203", "name": "Functional English III", "creditHours": 3.0, "type": "Core Course", "category": "Compulsory"},
    ],
    "3": [
      {"code": "IT-201", "name": "Computer Programming", "creditHours": 3.0, "type": "Core Course", "category": "Domain Core"},
      {"code": "IT-211", "name": "Discrete Mathematics", "creditHours": 3.0, "type": "Core Course", "category": "Domain Core"},
      {"code": "IT-212", "name": "Engineering Mathematics", "creditHours": 3.0, "type": "Core Course", "category": "Domain Core"},
      {"code": "IT-221", "name": "Digital Logic Design", "creditHours": 3.0, "type": "Core Course", "category": "Domain Core"},
      {"code": "EC-201", "name": "Economics", "creditHours": 3.0, "type": "Core Course", "category": "Faculty Elective"},
    ],
    "4": [
      {"code": "IT-222", "name": "Computer Architecture", "creditHours": 3.0, "type": "Core Course", "category": "Domain Core"},
      {"code": "IT-231", "name": "System Analysis and Design", "creditHours": 3.0, "type": "Core Course", "category": "Domain Core"},
      {"code": "IT-232", "name": "Database Systems", "creditHours": 3.0, "type": "Core Course", "category": "Domain Core"},
      {"code": "ES-101", "name": "Introduction to Geology", "creditHours": 3.0, "type": "Core Course", "category": "Faculty Elective"},
      {"code": "MA-207", "name": "Differential Equations and Linear Algebra", "creditHours": 3.0, "type": "Core Course", "category": "Faculty Elective"},
      {"code": "IT-202", "name": "Data Structures", "creditHours": 3.0, "type": "Core Course", "category": "Domain Core"},
    ],
    "5": [
      {"code": "IT-332", "name": "Web Engineering", "creditHours": 3.0, "type": "Core Course", "category": "Domain Core"},
      {"code": "IT-331", "name": "Operating System", "creditHours": 3.0, "type": "Core Course", "category": "Domain Core"},
      {"code": "IT-321", "name": "Linear Circuit Analysis", "creditHours": 3.0, "type": "Core Course", "category": "Domain Core"},
      {"code": "IT-301", "name": "Object Oriented Programming", "creditHours": 3.0, "type": "Core Course", "category": "Domain Core"},
      {"code": "ST-101", "name": "Probability and Statistics", "creditHours": 3.0, "type": "Core Course", "category": "Faculty Elective"},
      {"code": "IT-341", "name": "Communication Systems", "creditHours": 3.0, "type": "Core Course", "category": "Domain Core"},
    ],
    "6": [
      {"code": "IT-342", "name": "Computer Communication and Networks", "creditHours": 3.0, "type": "Core Course", "category": "Domain Core"},
      {"code": "IT-302", "name": "Analysis of Algorithm", "creditHours": 3.0, "type": "Core Course", "category": "Domain Core"},
      {"code": "IT-322", "name": "Nonlinear Electronics", "creditHours": 3.0, "type": "Core Course", "category": "Domain Core"},
      {"code": "IT-333", "name": "Software Engineering", "creditHours": 3.0, "type": "Core Course", "category": "Domain Core"},
      {"code": "CH-101", "name": "Chemistry-1", "creditHours": 3.0, "type": "Core Course", "category": "Faculty Elective"},
    ],
    "7": [
      {"code": "IT-442", "name": "Network Security & Management", "creditHours": 3.0, "type": "Core Course", "category": "Domain Core"},
      {"code": "IT-411", "name": "Multimedia and Computer Graphics", "creditHours": 3.0, "type": "Core Course", "category": "Domain Core"},
      {"code": "IT-491", "name": "Project I", "creditHours": 3.0, "type": "Core Course", "category": "Domain Core"},
      {"code": "Elective-1", "name": "Elective Course 1", "creditHours": 3.0, "type": "Elective-1", "category": "Elective"},
      {"code": "Elective-2", "name": "Elective Course 2", "creditHours": 3.0, "type": "Elective-2", "category": "Elective"},
    ],
    "8": [
      {"code": "IT-492", "name": "Project-II", "creditHours": 3.0, "type": "Core Course", "category": "Domain Core"},
      {"code": "Elective-3", "name": "Elective Course 3", "creditHours": 3.0, "type": "Elective-3", "category": "Elective"},
      {"code": "Elective-4", "name": "Elective Course 4", "creditHours": 3.0, "type": "Elective-4", "category": "Elective"},
      {"code": "Elective-5", "name": "Elective Course 5", "creditHours": 3.0, "type": "Elective-5", "category": "Elective"},
    ],
  };

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      try {
        // Create the user with FirebaseAuth
        final auth = FirebaseAuth.instance;
        final email = '${rollNumberController.text.trim()}@iit.com'; // Use roll number as email

        UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email,
          password: passwordController.text.trim(),
        );

        final rollNumber = rollNumberController.text.trim();
        final docSnapshot = await FirebaseFirestore.instance.collection('users').doc(rollNumber).get();

        if (docSnapshot.exists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: Roll number already registered')),
          );
          setState(() => isLoading = false);
          return;
        }

        // Get courses for the selected semester
        final courses = semesterCourses[selectedSemester] ?? [];

        // Save user data (excluding password) in Firestore
        await FirebaseFirestore.instance.collection('users').doc(rollNumber).set({
          'firstName': firstNameController.text.trim(),
          'lastName': lastNameController.text.trim(),
          'semester': selectedSemester,
          'email': email,
          'password': passwordController.text.trim(),
          'courses': courses, // Save the courses for the selected semester
          'enrolledAt': FieldValue.serverTimestamp(), // Add enrollment timestamp
        });

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Account created successfully!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const SignInScreen()),
                  );
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4E5FE8), Color(0xFFE9D7F6)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Card(
                  elevation: 0,
                  color: Colors.white.withOpacity(0.9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6778E8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.person_add,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Sign Up Text
                          const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1E2C),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Description Text
                          const Text(
                            'Create a new account to get started',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF6B6B6B),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // First Name TextField
                          TextFormField(
                            controller: firstNameController,
                            decoration: InputDecoration(
                              hintText: 'First Name',
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.all(20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your first name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Last Name TextField
                          TextFormField(
                            controller: lastNameController,
                            decoration: InputDecoration(
                              hintText: 'Last Name',
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.all(20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your last name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Roll Number TextField
                          TextFormField(
                            controller: rollNumberController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Roll Number',
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.all(20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your roll number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Semester Dropdown
                          DropdownButtonFormField<String>(
                            value: selectedSemester,
                            decoration: InputDecoration(
                              hintText: 'Select Semester',
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.all(20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: List.generate(8, (index) {
                              return DropdownMenuItem(
                                value: "${index + 1}",
                                child: Text("Semester ${index + 1}"),
                              );
                            }),
                            onChanged: (value) => setState(() => selectedSemester = value),
                            validator: (value) => value == null ? "Please select a semester" : null,
                          ),
                          const SizedBox(height: 16),

                          // Password TextField
                          TextFormField(
                            controller: passwordController,
                            obscureText: _obscurePasswordText,
                            decoration: InputDecoration(
                              hintText: 'Password',
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.all(20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePasswordText ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePasswordText = !_obscurePasswordText;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password';
                              }
                              if (value.length < 8) {
                                return 'Password must be at least 8 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Confirm Password TextField
                          TextFormField(
                            controller: confirmPasswordController,
                            obscureText: _obscureConfirmPasswordText,
                            decoration: InputDecoration(
                              hintText: 'Confirm Password',
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.all(20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPasswordText ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPasswordText = !_obscureConfirmPasswordText;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),

                          // Sign Up Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _registerUser,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Colors.white,
                                ),
                              )
                                  : const Text(
                                'Create Account',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Login Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Already have an account?",
                                style: TextStyle(
                                  color: Color(0xFF6B6B6B),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => const SignInScreen()),
                                  );
                                },
                                child: const Text(
                                  'Log In',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}