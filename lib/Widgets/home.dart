import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/Widgets/profile.dart';
import 'package:project/modules/Courseselection.dart';
import 'package:project/modules/aitutor.dart';
import 'package:project/modules/mockinterviews.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String _userName = '';
  bool _isLoading = true;

  // Todo list variables
  List<TodoItem> _todos = [];
  final TextEditingController _todoController = TextEditingController();

  // Debug information
  String _debugMessage = '';

  Future<void> logout() async {
    try {
      // Sign out from Firebase Auth
      await _auth.signOut();

      // Clear only isLoggedIn flag but keep the roll number
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);

      // Navigate back to login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SignInScreen()),
      );
    } catch (e) {
      _showDebugMessage('Error during logout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }

  // Debug message display method
  void _showDebugMessage(String message) {
    setState(() {
      _debugMessage = message;
    });
  }

  // Load user data from Firestore
  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      // Get current user
      final User? user = _auth.currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Verify email format and extract roll number
      if (user.email == null || !user.email!.contains('@')) {
        _showDebugMessage('Invalid email format');
        setState(() => _isLoading = false);
        return;
      }

      final String rollNumber = user.email!.split('@')[0];

      // Attempt to fetch user document
      final userDoc = await _firestore.collection('users').doc(rollNumber).get();

      if (userDoc.exists) {
        final userData = userDoc.data() ?? {};

        setState(() {
          // Combine first and last name
          String firstName = userData['firstName'] ?? '';
          String lastName = userData['lastName'] ?? '';

          _userName = ('$firstName $lastName').trim().isNotEmpty
              ? '$firstName $lastName'
              : 'Student';
        });

        // Load todos for this user
        await _loadTodos(rollNumber);
      } else {
        setState(() {
          _userName = 'Student';
        });
      }
    } catch (e) {
      _showDebugMessage('Error loading user data: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading user data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Load todos from Firestore
  Future<void> _loadTodos(String rollNumber) async {
    try {
      // Query todos collection for this user
      final todosSnapshot = await _firestore
          .collection('users')
          .doc(rollNumber)
          .collection('todos')
          .get();

      // Convert snapshot to TodoItem objects
      final loadedTodos = todosSnapshot.docs.map((doc) {
        final data = doc.data();
        return TodoItem(
          id: doc.id,
          title: data['title'] ?? '',
          isCompleted: data['isCompleted'] ?? false,
          priority: _convertToPriority(data['priority'] ?? 'medium'),
        );
      }).toList();

      setState(() {
        _todos = loadedTodos;
      });
    } catch (e) {
      _showDebugMessage('Error loading todos: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load tasks: $e')),
      );
    }
  }

  // Convert string to TodoPriority
  TodoPriority _convertToPriority(String priorityString) {
    switch (priorityString.toLowerCase()) {
      case 'high':
        return TodoPriority.high;
      case 'low':
        return TodoPriority.low;
      default:
        return TodoPriority.medium;
    }
  }

  // Add a new todo and save to Firestore
  void _addTodo() async {
    if (_todoController.text.isEmpty) return;

    try {
      // Get current user's roll number
      final User? user = _auth.currentUser;
      if (user == null) return;

      final rollNumber = user.email!.split('@')[0];

      final newTodo = TodoItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _todoController.text,
        isCompleted: false,
        priority: TodoPriority.medium,
      );

      // Save to Firestore
      await _firestore
          .collection('users')
          .doc(rollNumber)
          .collection('todos')
          .doc(newTodo.id)
          .set({
        'title': newTodo.title,
        'isCompleted': newTodo.isCompleted,
        'priority': newTodo.priority.toString().split('.').last,
      });

      setState(() {
        _todos.add(newTodo);
        _todoController.clear();
      });
    } catch (e) {
      _showDebugMessage('Error adding todo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add task: $e')),
      );
    }
  }

  // Toggle todo completion and update in Firestore
  void _toggleTodoCompletion(String id) async {
    try {
      // Get current user's roll number
      final User? user = _auth.currentUser;
      if (user == null) return;

      final rollNumber = user.email!.split('@')[0];

      // Find the todo in the local list
      final todoIndex = _todos.indexWhere((todo) => todo.id == id);
      if (todoIndex == -1) return;

      // Toggle completion
      final updatedTodo = _todos[todoIndex].copyWith(
        isCompleted: !_todos[todoIndex].isCompleted,
      );

      // Update in Firestore
      await _firestore
          .collection('users')
          .doc(rollNumber)
          .collection('todos')
          .doc(id)
          .update({
        'isCompleted': updatedTodo.isCompleted,
      });

      // Update local state
      setState(() {
        _todos[todoIndex] = updatedTodo;
      });
    } catch (e) {
      _showDebugMessage('Error toggling todo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update task: $e')),
      );
    }
  }

  // Update todo priority and save to Firestore
  void _updatePriority(String id, TodoPriority priority) async {
    try {
      // Get current user's roll number
      final User? user = _auth.currentUser;
      if (user == null) return;

      final rollNumber = user.email!.split('@')[0];

      // Find the todo in the local list
      final todoIndex = _todos.indexWhere((todo) => todo.id == id);
      if (todoIndex == -1) return;

      // Update todo with new priority
      final updatedTodo = _todos[todoIndex].copyWith(priority: priority);

      // Update in Firestore
      await _firestore
          .collection('users')
          .doc(rollNumber)
          .collection('todos')
          .doc(id)
          .update({
        'priority': priority.toString().split('.').last,
      });

      // Update local state
      setState(() {
        _todos[todoIndex] = updatedTodo;
      });
    } catch (e) {
      _showDebugMessage('Error updating todo priority: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update task priority: $e')),
      );
    }
  }

  // Delete a todo from Firestore
  void _deleteTodo(String id) async {
    try {
      // Get current user's roll number
      final User? user = _auth.currentUser;
      if (user == null) return;

      final rollNumber = user.email!.split('@')[0];

      // Delete from Firestore
      await _firestore
          .collection('users')
          .doc(rollNumber)
          .collection('todos')
          .doc(id)
          .delete();

      // Remove from local list
      setState(() {
        _todos.removeWhere((todo) => todo.id == id);
      });
    } catch (e) {
      _showDebugMessage('Error deleting todo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete task: $e')),
      );
    }
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
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.cyan.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.cyan.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    iconBgColor,
                    iconBgColor.withOpacity(0.6),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: iconBgColor.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Icon(icon, color: Colors.white, size: 28),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[300],
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.cyan.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.cyan,
                size: 16,
              ),
            ),
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
                    color: Colors.white,
                  ),
                ),
                Text(
                  "${_todos.where((todo) => todo.isCompleted).length}/${_todos.length} Done",
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.grey[600]),

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
              separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[600]),
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
                            : Colors.white,
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
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Add a new task...",
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[700],
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
      body: Container(
        // Add the gradient background here
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
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
          child: Column(
            children: [
              if (_debugMessage.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  color: Colors.red[100],
                  child: Text(
                    _debugMessage,
                    style: TextStyle(color: Colors.red[900]),
                    textAlign: TextAlign.center,
                  ),
                ),
              // Top Bar with Profile
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile image
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ProfileScreen()),
                        );
                      },
                      child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xCC9C27B0), // Purple with 0.8 opacity
                            Color(0xCC2196F3),  // Dark navy
                          ],
                        ),
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    ),
                    const SizedBox(width: 16),
                    // Greeting text - Wrapped in Expanded to handle overflow
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hi, ${_userName.isNotEmpty ? _userName : "Student"}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 1.2,
                              shadows: [
                                Shadow(
                                  color: Colors.cyan,
                                  blurRadius: 3,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Ready to learn today?',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[300],
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Logout"),
                            content: const Text("Are you sure you want to logout?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("No"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context); // Close the dialog first
                                  logout(); // Call the logout method
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

                      const SizedBox(height: 24),

                      // Learning Tools Section
                      const Text(
                        "Learning Tools",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),

                      const SizedBox(height: 16),

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
                              builder: (context) => const CourseSelectionScreen(),
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
                            MaterialPageRoute(builder: (context) => const AITutorChat()),
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
                            MaterialPageRoute(builder: (context) => const MockInterviewSetupScreen()),
                          );
                        },
                      ),

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
                                  MaterialPageRoute(builder: (context) => const AITutorChat()),
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
            ],
          ),
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