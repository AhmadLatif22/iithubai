import 'package:flutter/material.dart';
import 'package:sizedcontainer/Widgets/imagePicker.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blue.shade300,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
          brightness: Brightness.dark,
        ).copyWith(
          secondary: Colors.blue.shade300, // Accent color
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.teal.shade400,
          foregroundColor: Colors.white, // Text color for AppBar
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blue.shade300, // Button background color
          textTheme: ButtonTextTheme.primary, // Text color for buttons
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade300, // ElevatedButton color
            foregroundColor: Colors.white, // Text color for ElevatedButton
          ),
        ),
      ),
      home: const ImagePickerWidget(),
    );
  }
}
