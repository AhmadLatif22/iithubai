import 'package:flutter/material.dart';

class ProfitScreen extends StatefulWidget {
  @override
  _ProfitScreenState createState() => _ProfitScreenState();
}

class _ProfitScreenState extends State<ProfitScreen> {
  double _totalIncome = 0.0;
  double _totalExpenses = 0.0;
  double _profit = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Total Income: PKR ${_totalIncome.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 16),
            Text(
              'Total Expenses: PKR ${_totalExpenses.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 16),
            Text(
              'Net Profit: PKR ${_profit.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}