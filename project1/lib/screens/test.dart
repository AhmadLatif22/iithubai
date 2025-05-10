import 'package:flutter/material.dart';

class TestImageScreen extends StatelessWidget {
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
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.red, size: 50),
                const SizedBox(height: 10),
                const Text('Failed to load image'),
              ],
            );
          },
        ),
      ),
    );
  }
}
