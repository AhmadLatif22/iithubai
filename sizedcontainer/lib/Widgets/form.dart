import 'package:flutter/material.dart';

class FormsWidget extends StatefulWidget {
  const FormsWidget({super.key});

  @override
  State<FormsWidget> createState() => _FormWidgetState();
}

class _FormWidgetState extends State<FormsWidget> {
  final _formKey = GlobalKey<FormState>();
  String firstName = '';
  String lastName = '';
  String email = '';
  String password = '';

  //Functions
  trySubmit() {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
      submitForm();
    } else {
      print('Error');
    }
  }

  submitForm() {
    print(firstName);
    print(lastName);
    print(email);
    print(password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Create an Account',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      labelStyle: const TextStyle(color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.person, color: Colors.black),
                    ),
                    style: const TextStyle(color: Colors.black),
                    key: const ValueKey('firstName'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'First Name should not be empty';
                      } else {
                        return null;
                      }
                    },
                    onSaved: (value) {
                      firstName = value!;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      labelStyle: const TextStyle(color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon:
                      const Icon(Icons.person_outline, color: Colors.black),
                    ),
                    style: const TextStyle(color: Colors.black),
                    key: const ValueKey('lastName'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Last Name should not be empty';
                      } else {
                        return null;
                      }
                    },
                    onSaved: (value) {
                      lastName = value!;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.email, color: Colors.black),
                    ),
                    style: const TextStyle(color: Colors.black),
                    key: const ValueKey('email'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Email should not be empty';
                      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Enter a valid email address';
                      } else {
                        return null;
                      }
                    },
                    onSaved: (value) {
                      email = value!;
                    },
                  ),
                Row(
                  children: [
                    // Country Code Dropdown
                    Container(
                      width: 100, // Adjust the width as needed
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButton<String>(
                        dropdownColor: Colors.grey.shade200,
                        value: '+92', // Default value (Pakistan country code)
                        items: const [
                          DropdownMenuItem(
                            value: '+1',
                            child: Text('+1', style: TextStyle(color: Colors.black)),
                          ),
                          DropdownMenuItem(
                            value: '+44',
                            child: Text('+44', style: TextStyle(color: Colors.black)),
                          ),
                          DropdownMenuItem(
                            value: '+92',
                            child: Text('+92', style: TextStyle(color: Colors.black)),
                          ),
                          // Add more country codes as needed
                        ],
                        onChanged: (value) {
                          setState(() {
                            // Handle country code selection
                            // countryCode = value!;
                          });
                        },
                        underline: const SizedBox(), // To remove the default underline
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                      ),
                    ),
                    const SizedBox(width: 10), // Spacing between dropdown and text field
                    // Phone Number Input Field
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          labelStyle: const TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Phone number should not be empty';
                          } else if (!RegExp(r'^\d{10,15}$').hasMatch(value)) {
                            return 'Enter a valid phone number';
                          } else {
                            return null;
                          }
                        },
                        onSaved: (value) {
                          // Save the phone number here
                        },
                      ),
                    ),
                  ],
                ),
                  const SizedBox(height: 15),
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.lock, color: Colors.black),
                    ),
                    style: const TextStyle(color: Colors.black),
                    key: const ValueKey('password'),
                    validator: (value) {
                      if (value!.length <= 7) {
                        return 'Password must be at least 8 characters';
                      } else {
                        return null;
                      }
                    },
                    onSaved: (value) {
                      password = value!;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      trySubmit();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
