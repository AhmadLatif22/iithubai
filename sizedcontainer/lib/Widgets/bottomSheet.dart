import 'package:flutter/material.dart';

class BottomsheetWidget extends StatelessWidget {
  const BottomsheetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bottom Sheet',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'sans-serif',
          ),
        ),
        // backgroundColor: Colors.purple.shade900,
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            // backgroundColor: Colors.purple, // Button color
            foregroundColor: Colors.black,  // Text color
          ),
          child: const Text(
            'Bottom Sheet',
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'sans-serif',
            ),
          ),
          onPressed: () {
            showModalBottomSheet(
              elevation: 0,
              isDismissible: false,
              enableDrag: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10))
              ),
                backgroundColor: Theme.of(context).primaryColor,
                context: context , builder: (context){
                  return const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    ListTile(title: Text('Hey Ahmad!!!!'),subtitle: Text('Welcome Here'),),
                    ListTile(title: Text('Hey Muzamil!!!'),subtitle: Text('Welcome Here'),),
                    ListTile(title: Text('Hey Abdullah!!!!'),subtitle: Text('Welcome Here'),),
                    ListTile(title: Text('Hey Ali!!!!'),subtitle: Text('Welcome Here'),),
                    ListTile(title: Text('Hey Faran!!!!'),subtitle: Text('Welcome Here'),),

                  ],);
            });
          },
        ),
      ),
    );
  }
}
