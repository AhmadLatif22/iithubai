import 'package:flutter/material.dart';

class TestImageScreen extends StatelessWidget {
  const TestImageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Image'),
      ),
      body: Center(
        child: Image.network(
          'https://images.app.goo.gl/LdH3hVvexs7DYoSL9', // Replace with your image URL
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.red, size: 50),
                SizedBox(height: 10),
                Text('Failed to load image'),
              ],
            );
          },
        ),
      ),
    );
  }
}
