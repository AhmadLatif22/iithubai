import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class ExpensesScreen extends StatefulWidget {
  @override
  _ExpensesScreenState createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final TextEditingController _electricityController = TextEditingController();
  final TextEditingController _cargoController = TextEditingController();
  final TextEditingController _laborController = TextEditingController();
  double _totalExpenses = 0.0;

  void _calculateExpenses() {
    final double electricity = double.tryParse(_electricityController.text) ?? 0.0;
    final double cargo = double.tryParse(_cargoController.text) ?? 0.0;
    final double labor = double.tryParse(_laborController.text) ?? 0.0;
    setState(() {
      _totalExpenses = electricity + cargo + labor;
    });
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Expenses calculated successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expenses'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomTextField(
              label: 'Electricity Bill',
              controller: _electricityController,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            CustomTextField(
              label: 'Cargo Expenses',
              controller: _cargoController,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            CustomTextField(
              label: 'Labor Expenses',
              controller: _laborController,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            CustomButton(
              text: 'Calculate Expenses',
              onPressed: _calculateExpenses,
            ),
            SizedBox(height: 16),
            Text(
              'Total Expenses: PKR ${_totalExpenses.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 16),
            CustomButton(
              text: 'Save Expenses',
              onPressed: _showSuccessMessage,
            ),
          ],
        ),
      ),
    );
  }
}