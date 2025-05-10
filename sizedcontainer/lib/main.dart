import 'package:flutter/material.dart';
import 'package:sizedcontainer/Widgets/alert.dart';
import 'package:sizedcontainer/Widgets/animated_text.dart';
import 'package:sizedcontainer/Widgets/bottomSheet.dart';
import 'package:sizedcontainer/Widgets/bottomnav.dart';
import 'package:sizedcontainer/Widgets/button.dart';
import 'package:sizedcontainer/Widgets/dismissible.dart';
import 'package:sizedcontainer/Widgets/drawer.dart';
import 'package:sizedcontainer/Widgets/dropdownlist.dart';
import 'package:sizedcontainer/Widgets/form.dart';
import 'package:sizedcontainer/Widgets/forms.dart';
import 'package:sizedcontainer/Widgets/imagePicker.dart';
import 'package:sizedcontainer/Widgets/imageWidget.dart';
import 'package:sizedcontainer/Widgets/list_grid.dart';
import 'package:sizedcontainer/Widgets/rowscols.dart';
import 'package:sizedcontainer/Widgets/snackBar.dart';
import 'package:sizedcontainer/Widgets/stack.dart';
import 'package:sizedcontainer/Widgets/tabbar.dart';
import 'Widgets/container_sized.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

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
