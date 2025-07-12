import 'package:flutter/material.dart';

class SnackBarWidget extends StatelessWidget {
  const SnackBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Snack Bar'),
      ),
      body: Container(
      child: Center(
        child: ElevatedButton(onPressed: (){
          final snackBar= SnackBar(
            action: SnackBarAction(
              textColor: Colors.purpleAccent,
              label: 'Undo',
              onPressed: (){},
            ),
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(5),
              shape: RoundedRectangleBorder(
                 borderRadius: BorderRadius.circular(20)
              ),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(milliseconds: 3000),
              content: const Text('This is an error!!!!'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        },
          child: const Text('Show Snack Bar'),),
      ),
      ),
    );
  }
}
