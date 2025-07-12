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
  runApp(const AlQamarCitrusApp());
}

class AlQamarCitrusApp extends StatelessWidget {
  const AlQamarCitrusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Al-Qamar Citrus',
      theme: citrusTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(), // Default to LoginScreen
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/employees': (context) => const EmployeesScreen(),
        '/sellers': (context) => const SellersScreen(),
        '/buyers': (context) => const BuyersScreen(),
        '/expenses': (context) => const ExpensesScreen(),
        '/profit': (context) => const ProfitScreen(),
      },
    );
  }
}