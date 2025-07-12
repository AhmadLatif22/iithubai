import 'package:flutter/material.dart';
import '../widgets/drawer.dart';

class HomeScreen extends StatelessWidget {
  // Example values for income and expenses
  final double monthlyIncome = 1000000.0; // Replace with actual income source
  final double monthlyExpenses = 500000.0;

  const HomeScreen({super.key}); // Replace with actual expenses source

  // Profit calculation logic
  double calculateProfit() {
    return monthlyIncome - monthlyExpenses;
  }

  @override
  Widget build(BuildContext context) {
    final double profit = calculateProfit();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Al-Qamar Citrus'),
      ),
      drawer: const AppDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the orange.jpeg image
            Image.asset(
              'resources/orange.jpeg',
              width: 200, // Adjust the width as needed
              height: 200, // Adjust the height as needed
              fit: BoxFit.cover, // Adjust the fit as needed
            ),
            const SizedBox(height: 20),
            Text(
              'Monthly Profit:',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 20),
            Text(
              'PKR ${profit.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 40),
            // Additional financial breakdown
            Text(
              'Income: PKR ${monthlyIncome.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              'Expenses: PKR ${monthlyExpenses.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import '../widgets/drawer.dart';
// import '../widgets/custom_textfield.dart';
// import '../widgets/custom_button.dart';
//
// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   final TextEditingController _incomeController = TextEditingController();
//   final TextEditingController _expensesController = TextEditingController();
//   double _profit = 0.0;
//
//   void _calculateProfit() {
//     final double income = double.tryParse(_incomeController.text) ?? 0.0;
//     final double expenses = double.tryParse(_expensesController.text) ?? 0.0;
//     setState(() {
//       _profit = income - expenses;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Al-Qamar Citrus'),
//       ),
//       drawer: AppDrawer(),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CustomTextField(
//               label: 'Monthly Income',
//               controller: _incomeController,
//               keyboardType: TextInputType.number,
//             ),
//             SizedBox(height: 16),
//             CustomTextField(
//               label: 'Monthly Expenses',
//               controller: _expensesController,
//               keyboardType: TextInputType.number,
//             ),
//             SizedBox(height: 16),
//             CustomButton(
//               text: 'Calculate Profit',
//               onPressed: _calculateProfit,
//             ),
//             SizedBox(height: 40),
//             Text(
//               'Monthly Profit:',
//               style: Theme.of(context).textTheme.headlineLarge,
//             ),
//             SizedBox(height: 20),
//             Text(
//               'PKR ${_profit.toStringAsFixed(2)}',
//               style: Theme.of(context).textTheme.headlineLarge,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }