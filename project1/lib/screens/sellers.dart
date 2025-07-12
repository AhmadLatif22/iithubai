import 'package:flutter/material.dart';
import '../models/seller.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class SellersScreen extends StatefulWidget {
  const SellersScreen({super.key});

  @override
  _SellersScreenState createState() => _SellersScreenState();
}

class _SellersScreenState extends State<SellersScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _rentRateController = TextEditingController();
  final TextEditingController _numberOfTrolleysController = TextEditingController();
  final List<Seller> _sellers = [];

  void _addSeller() {
    final seller = Seller(
      name: _nameController.text.trim(),
      area: _areaController.text.trim(),
      phone: _phoneController.text.trim(),
      rentRate: double.tryParse(_rentRateController.text.trim()) ?? 0.0,
      numberOfTrolleys: int.tryParse(_numberOfTrolleysController.text.trim()) ?? 0,
    );
    setState(() {
      _sellers.add(seller);
    });
    _clearFields();
  }

  void _clearFields() {
    _nameController.clear();
    _areaController.clear();
    _phoneController.clear();
    _rentRateController.clear();
    _numberOfTrolleysController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sellers'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _sellers.length,
                itemBuilder: (context, index) {
                  final seller = _sellers[index];
                  return ListTile(
                    title: Text(seller.name),
                    subtitle: Text(seller.area),
                    trailing: Text('PKR ${seller.rentRate.toStringAsFixed(2)}'),
                  );
                },
              ),
            ),
            CustomTextField(label: 'Name', controller: _nameController),
            CustomTextField(label: 'Area', controller: _areaController),
            CustomTextField(label: 'Phone', controller: _phoneController),
            CustomTextField(label: 'Rent Rate', controller: _rentRateController),
            CustomTextField(label: 'Number of Trolleys', controller: _numberOfTrolleysController),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Add Seller',
              onPressed: _addSeller,
            ),
          ],
        ),
      ),
    );
  }
}