import 'package:flutter/material.dart';
import '../models/buyer.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class BuyersScreen extends StatefulWidget {
  @override
  _BuyersScreenState createState() => _BuyersScreenState();
}

class _BuyersScreenState extends State<BuyersScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberOfCartonsController = TextEditingController();
  final TextEditingController _pricePerCartonController = TextEditingController();
  final TextEditingController _pricePerContainerController = TextEditingController();
  final TextEditingController _numberOfContainersController = TextEditingController();
  List<Buyer> _buyers = [];

  void _addBuyer() {
    final buyer = Buyer(
      name: _nameController.text.trim(),
      numberOfCartons: int.parse(_numberOfCartonsController.text.trim()),
      pricePerCarton: double.parse(_pricePerCartonController.text.trim()),
      pricePerContainer: double.parse(_pricePerContainerController.text.trim()),
      numberOfContainers: int.parse(_numberOfContainersController.text.trim()),
    );
    setState(() {
      _buyers.add(buyer);
    });
    _clearFields();
  }

  void _clearFields() {
    _nameController.clear();
    _numberOfCartonsController.clear();
    _pricePerCartonController.clear();
    _pricePerContainerController.clear();
    _numberOfContainersController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buyers'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _buyers.length,
                itemBuilder: (context, index) {
                  final buyer = _buyers[index];
                  return ListTile(
                    title: Text(buyer.name),
                    subtitle: Text('Cartons: ${buyer.numberOfCartons}'),
                    trailing: Text(
                        'PKR ${buyer.pricePerCarton.toStringAsFixed(2)}'),
                  );
                },
              ),
            ),
            CustomTextField(label: 'Name', controller: _nameController),
            CustomTextField(label: 'Number of Cartons',
                controller: _numberOfCartonsController),
            CustomTextField(label: 'Price per Carton',
                controller: _pricePerCartonController),
            CustomTextField(label: 'Price per Container',
                controller: _pricePerContainerController),
            CustomTextField(label: 'Number of Containers',
                controller: _numberOfContainersController),
            SizedBox(height: 16),
            CustomButton(
              text: 'Add Buyer',
              onPressed: _addBuyer,
            ),
          ],
        ),
      ),
    );
  }
}