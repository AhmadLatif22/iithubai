import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class EmployeesScreen extends StatefulWidget {
  @override
  _EmployeesScreenState createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _attendanceController = TextEditingController();
  List<Employee> _employees = [];

  void _addEmployee() {
    final employee = Employee(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      designation: _designationController.text.trim(),
      salary: double.parse(_salaryController.text.trim()),
      attendance: int.parse(_attendanceController.text.trim()),
    );
    setState(() {
      _employees.add(employee);
    });
    _clearFields();
  }

  void _clearFields() {
    _nameController.clear();
    _phoneController.clear();
    _designationController.clear();
    _salaryController.clear();
    _attendanceController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employees'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _employees.length,
                itemBuilder: (context, index) {
                  final employee = _employees[index];
                  return ListTile(
                    title: Text(employee.name),
                    subtitle: Text(employee.designation),
                    trailing: Text('PKR ${employee.salary.toStringAsFixed(2)}'),
                  );
                },
              ),
            ),
            CustomTextField(
              label: 'Name',
              controller: _nameController,
            ),
            CustomTextField(
              label: 'Phone',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
            ),
            CustomTextField(
              label: 'Designation',
              controller: _designationController,
            ),
            CustomTextField(
              label: 'Salary',
              controller: _salaryController,
              keyboardType: TextInputType.number,
            ),
            CustomTextField(
              label: 'Attendance',
              controller: _attendanceController,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            CustomButton(
              text: 'Add Employee',
              onPressed: _addEmployee,
            ),
          ],
        ),
      ),
    );
  }
}