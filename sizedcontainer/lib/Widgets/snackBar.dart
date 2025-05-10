import 'package:flutter/material.dart';

class SnackBarWidget extends StatelessWidget {
  const SnackBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Snack Bar'),
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
              padding: EdgeInsets.all(5),
              shape: RoundedRectangleBorder(
                 borderRadius: BorderRadius.circular(20)
              ),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(milliseconds: 3000),
              content: Text('This is an error!!!!'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        },
          child: Text('Show Snack Bar'),),
      ),
      ),
    );
  }
}
