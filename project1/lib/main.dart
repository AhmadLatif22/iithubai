import 'package:flutter/material.dart';
import 'screens/login.dart';
import 'screens/signup.dart';
import 'screens/home.dart';
import 'screens/employees.dart'; // Ensure this import is correct
import 'screens/sellers.dart';
import 'screens/buyers.dart';
import 'screens/expenses.dart';
import 'screens/profit.dart';
import 'theme/theme.dart';

void main() {
  runApp(AlQamarCitrusApp());
}

class AlQamarCitrusApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Al-Qamar Citrus',
      theme: citrusTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(), // Default to LoginScreen
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/home': (context) => HomeScreen(),
        '/employees': (context) => EmployeesScreen(),
        '/sellers': (context) => SellersScreen(),
        '/buyers': (context) => BuyersScreen(),
        '/expenses': (context) => ExpensesScreen(),
        '/profit': (context) => ProfitScreen(),
      },
    );
  }
}