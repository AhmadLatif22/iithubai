import 'package:flutter/material.dart';
import 'package:sizedcontainer/Widgets/alert.dart';
import 'package:sizedcontainer/Widgets/bottomSheet.dart';
import 'package:sizedcontainer/Widgets/button.dart';
import 'package:sizedcontainer/Widgets/dismissible.dart';
import 'package:sizedcontainer/Widgets/drawer.dart';
import 'package:sizedcontainer/Widgets/imageWidget.dart';
import 'package:sizedcontainer/Widgets/list_grid.dart';
import 'package:sizedcontainer/Widgets/rowscols.dart';
import 'package:sizedcontainer/Widgets/snackBar.dart';
// import 'Widgets/container_sized.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue.shade300, // AppBar background color
          foregroundColor: Colors.black, // AppBar text color
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.black), // Default text color
          headlineMedium: TextStyle(color: Colors.black), // Header text color
          // Add other text styles as needed
        ),
      ),
      home: const BottomsheetWidget(),
    );
  }
}
