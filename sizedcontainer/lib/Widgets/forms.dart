import 'package:flutter/material.dart';

class FormWidget extends StatefulWidget {
  const FormWidget({super.key});

  @override
  State<FormWidget> createState() => _FormWidgetState();
}

class _FormWidgetState extends State<FormWidget> {
  final _formKey = GlobalKey<FormState>();
  String firstName = '';
  String lastName = '';
  String email = '';
  String password = '';

  //Functions
   trySubmit(){
     final isValid =_formKey.currentState!.validate();
     if(isValid){
       _formKey.currentState!.save();
       submitForm();
     }
     else{
       print('Error');
     }
   }

   submitForm(){
     print(firstName);
     print(lastName);
     print(email);
     print(password);
   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forms'),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(10),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'First Name',
                  ),
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
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Last Name',
                  ),
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
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: ' Email',
                  ),
                  key: const ValueKey('email'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Email should not be empty';
                    } else {
                      return null;
                    }
                  },
                  onSaved: (value) {
                    email = value!;
                  },
                ),
                TextFormField(
                  obscureText:  true,
                  decoration: const InputDecoration(
                    hintText: 'Password',
                  ),
                  key: const ValueKey('password'),
                  validator: (value) {
                    if (value!.length<=7) {
                      return 'Min Length 8';
                    } else {
                      return null;
                    }
                  },
                  onSaved: (value) {
                    password = value!;
                  },
                ),
                TextButton(onPressed: (){trySubmit();}, child: const Text('Submit'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
