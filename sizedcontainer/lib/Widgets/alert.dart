import 'package:flutter/material.dart';

class AlertWidget extends StatelessWidget {
  const AlertWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alert!!!!'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: ElevatedButton(child: Text('Show Alert'),onPressed: (){
          _showMyDialog(context);
        },),
    ),
    );
  }
}
Future<void> _showMyDialog(BuildContext context)async
{
  return showDialog(context: context,
      builder: (BuildContext){
        return AlertDialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
          // scrollable: true,
          title: Text('Heloooo'),
          content: SingleChildScrollView (
            child: ListBody(
              children: [
                Text('this is a demo'),
                Text('This is Ahmad Latif'),
              ],
            ),
          ),
            actions: [
              TextButton(onPressed: (){ Navigator.of(context).pop();}, child: Text('Approve')),
              TextButton(onPressed: (){ Navigator.of(context).pop();}, child: Text('Cancel')),
          ],
        );
      });
}
