import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/Widgets/profile.dart';
import 'package:project/modules/Courseselection.dart';
import 'package:project/modules/aitutor.dart';
import 'package:project/modules/mockinterviews.dart';
import 'login.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // User data variables
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _studentId = '';
  String _currentSemester = '';
  String _userName = '';  // Default empty string
  bool _isLoading = true;

  // Todo list variables
  final List<TodoItem> _todos = [];
  final TextEditingController _todoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadTodos();
  }

  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      // Get current user
      final User? user = _auth.currentUser;
      if (user == null) {
        // Handle not logged in state
        return;
      }

      // IMPORTANT: In the signup, roll number is used as the document ID
      // but email is used for authentication. We need to get the document ID from the email.
      final String rollNumber = user.email!.split('@')[0]; // Extract roll number from email

      // Get user data from Firestore
      final userDoc = await _firestore.collection('users').doc(rollNumber).get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        setState(() {
          _studentId = rollNumber;
          // Match field names with what's actually stored in Firestore during signup
          _currentSemester = userData?['semester'] ?? '';
          // Combine first and last name for display
          String firstName = userData?['firstName'] ?? '';
          String lastName = userData?['lastName'] ?? '';

          // Set the user name
          if (firstName.isNotEmpty || lastName.isNotEmpty) {
            _userName = "$firstName $lastName".trim();
          } else {
            _userName = 'Student'; // Fallback if both names are empty
          }
        });
      } else {
        // Document doesn't exist, set default value
        setState(() {
          _userName = 'Student';
        });
      }
    } catch (e) {
      // Handle error and set default name
      setState(() {
        _userName = 'Student';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading user data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Load todo items
  Future<void> _loadTodos() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return;

      // In a real app, load todos from Firestore
      // For demo, we'll use placeholder data
      setState(() {
        _todos.addAll([
          // You can add some default todos here if needed
        ]);
      });
    } catch (e) {
      print('Error loading todos: $e');
    }
  }

  // Add a new todo
  void _addTodo() {
    if (_todoController.text.isEmpty) return;

    final newTodo = TodoItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _todoController.text,
      isCompleted: false,
      priority: TodoPriority.medium, // default priority
    );

    setState(() {
      _todos.add(newTodo);
      _todoController.clear();
    });

    // In a real app, also save to Firestore
  }

  // Toggle todo completion
  void _toggleTodoCompletion(String id) {
    setState(() {
      final todoIndex = _todos.indexWhere((todo) => todo.id == id);
      if (todoIndex != -1) {
        _todos[todoIndex] = _todos[todoIndex].copyWith(
          isCompleted: !_todos[todoIndex].isCompleted,
        );
      }
    });

    // In a real app, also update Firestore
  }

  // Update todo priority
  void _updatePriority(String id, TodoPriority priority) {
    setState(() {
      final todoIndex = _todos.indexWhere((todo) => todo.id == id);
      if (todoIndex != -1) {
        _todos[todoIndex] = _todos[todoIndex].copyWith(priority: priority);
      }
    });

    // In a real app, also update Firestore
  }

  // Delete a todo
  void _deleteTodo(String id) {
    setState(() {
      _todos.removeWhere((todo) => todo.id == id);
    });

    // In a real app, also delete from Firestore
  }

  // Feature card widget
  Widget _buildFeatureCard({
    required String title,
    required String description,
    required IconData icon,
    required Color iconBgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconBgColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(icon, color: iconBgColor, size: 24),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.bookmark_border, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // Todo list widget
  Widget _buildTodoList() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "My Tasks",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${_todos.where((todo) => todo.isCompleted).length}/${_todos.length} Done",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Todo items
          if (_todos.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(
                child: Text(
                  "No tasks yet. Add one below!",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _todos.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final todo = _todos[index];
                return Dismissible(
                  key: Key(todo.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) => _deleteTodo(todo.id),
                  child: ListTile(
                    leading: Checkbox(
                      value: todo.isCompleted,
                      activeColor: const Color(0xFF6060FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (_) => _toggleTodoCompletion(todo.id),
                    ),
                    title: Text(
                      todo.title,
                      style: TextStyle(
                        decoration: todo.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: todo.isCompleted
                            ? Colors.grey
                            : Colors.black,
                      ),
                    ),
                    trailing: PopupMenuButton<TodoPriority>(
                      initialValue: todo.priority,
                      icon: Icon(
                        Icons.flag,
                        color: _getPriorityColor(todo.priority),
                      ),
                      onSelected: (priority) => _updatePriority(todo.id, priority),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: TodoPriority.high,
                          child: Row(
                            children: [
                              Icon(Icons.flag, color: Colors.red),
                              SizedBox(width: 8),
                              Text("High Priority"),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: TodoPriority.medium,
                          child: Row(
                            children: [
                              Icon(Icons.flag, color: Colors.orange),
                              SizedBox(width: 8),
                              Text("Medium Priority"),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: TodoPriority.low,
                          child: Row(
                            children: [
                              Icon(Icons.flag, color: Colors.blue),
                              SizedBox(width: 8),
                              Text("Low Priority"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

          // Add new todo
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _todoController,
                    decoration: InputDecoration(
                      hintText: "Add a new task...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _addTodo(),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _addTodo,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFF6060FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.high:
        return Colors.red;
      case TodoPriority.medium:
        return Colors.orange;
      case TodoPriority.low:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Column(
          children: [
            // Top Bar with Profile
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Profile image
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfileScreen()),
                      );
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: const DecorationImage(
                          image: AssetImage('assets/icons/logo.png'),
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Greeting text
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi, ${_userName.isNotEmpty ? _userName : "Student"}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Logout button
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Logout"),
                          content: const Text("Are you sure you want to logout?"),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("No")
                            ),
                            TextButton(
                              onPressed: () async {
                                await _auth.signOut();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => SignInScreen()),
                                );
                              },
                              child: const Text("Yes"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Todo List
                    _buildTodoList(),

                    // Learning Tools Section
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16, top: 8),
                      child: Text(
                        "Learning Tools",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // Feature cards
                    _buildFeatureCard(
                      title: "AI Course Selection",
                      description: "Get personalized course recommendations",
                      icon: Icons.school_outlined,
                      iconBgColor: Colors.blue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CourseSelectionScreen(),
                          ),
                        );
                      },
                    ),
                    _buildFeatureCard(
                      title: "AI Tutor",
                      description: "Learn with AI assistance",
                      icon: Icons.auto_stories_outlined,
                      iconBgColor: Colors.purple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AITutorChat()),
                        );
                      },
                    ),
                    _buildFeatureCard(
                      title: "Mock Interviews",
                      description: "Practice interview skills",
                      icon: Icons.mic_none_outlined,
                      iconBgColor: Colors.orange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MockInterviewChat()),
                        );
                      },
                    ),

                    // Welcome section (like Sokka)
                    Container(
                      margin: const EdgeInsets.only(top: 24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.withOpacity(0.1)),
                      ),
                      child: Column(
                        children: [
                          // Logo
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6060FF),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.smart_toy_outlined,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Title
                          const Text(
                            "Welcome to IIT Hub.AI",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Description
                          Text(
                            "Say hello to a world where every learning experience feels natural, engaging, and smarter. Always ready to elevate your academic journey!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Create chat button
                          TextButton(
                            onPressed: () {
                              // Navigate to AI Tutor as a default action
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => AITutorChat()),
                              );
                            },
                            child: const Text(
                              "Create a new Chat",
                              style: TextStyle(
                                color: Color(0xFF6060FF),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: Color(0xFF6060FF),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom navigation bar
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfileScreen()),
                      );
                    },
                    child: const Icon(Icons.person, color: Colors.black),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Open AITutorChat when plus button is pressed
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AITutorChat()),
                      );
                    },
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: Color(0xFF6060FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  const Icon(Icons.history, color: Colors.grey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Todo item model
enum TodoPriority { high, medium, low }

class TodoItem {
  final String id;
  final String title;
  final bool isCompleted;
  final TodoPriority priority;

  TodoItem({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.priority,
  });

  TodoItem copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    TodoPriority? priority,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
    );
  }
}