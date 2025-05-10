import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Simple in-memory authentication logic
  bool _authenticate(String email, String password) {
    // Replace with your own logic
    const String hardcodedEmail = 'user@example.com';
    const String hardcodedPassword = 'password123';

    return email == hardcodedEmail && password == hardcodedPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextField(label: 'Email', controller: _emailController),
            SizedBox(height: 16),
            CustomTextField(
              label: 'Password',
              controller: _passwordController,
              obscureText: true,
            ),
            SizedBox(height: 32),
            CustomButton(
              text: 'Login',
              onPressed: () {
                final email = _emailController.text.trim();
                final password = _passwordController.text.trim();

                if (_authenticate(email, password)) {
                  Navigator.pushReplacementNamed(context, '/home');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Invalid email or password'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
              child: Text('Don\'t have an account? Sign up here.'),
            ),
          ],
        ),
      ),
    );
  }
}