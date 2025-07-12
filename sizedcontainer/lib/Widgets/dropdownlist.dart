import 'package:flutter/material.dart';

class DropDownWidget extends StatefulWidget {
  const DropDownWidget({super.key});

  @override
  State<DropDownWidget> createState() => _DropDownWidgetState();
}

class _DropDownWidgetState extends State<DropDownWidget> {
  String selectedValue = 'Orange'; // Initial selected value

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drop Down List'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.all(160),
            height: 70,
            width: MediaQuery.of(context).size.width,
            color: Theme.of(context).primaryColor,
            child: Center(
              child: DropdownButton<String>(
                dropdownColor: Colors.grey,
                isExpanded: true,
                icon: const Icon(Icons.arrow_circle_down_outlined),
                value: selectedValue, // Display the selected value
                items: <String>[
                  'Orange',
                  'Apple',
                  'Banana',
                  'Mango',
                  'Grapes'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value), // Display each item's value
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedValue = newValue!; // Update the selected value
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
