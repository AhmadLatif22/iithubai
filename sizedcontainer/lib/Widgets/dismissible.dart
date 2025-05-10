import 'package:flutter/material.dart';

class DismissibleWidget extends StatefulWidget {
  const DismissibleWidget({Key? key}) : super(key: key);

  @override
  State<DismissibleWidget> createState() => _DismissibleWidgetState();
}

class _DismissibleWidgetState extends State<DismissibleWidget> {
  List<String> languages = ['English', 'Urdu', 'Punjabi', 'French'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dismissible'),
      ),
      body: ListView.builder(
        itemCount: languages.length,
        itemBuilder: (context, index) {
          final language = languages[index];
          return Dismissible(
            key: Key(language),
            onDismissed: (direction) {
              setState(() {
                languages.removeAt(index);
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    direction == DismissDirection.startToEnd
                        ? '$language dismissed to the right'
                        : '$language dismissed to the left',
                  ),
                  backgroundColor: direction == DismissDirection.startToEnd
                      ? Colors.redAccent
                      : Colors.green,
                ),
              );
            },
            background: Container(color: Colors.red),
            secondaryBackground: Container(color: Colors.green),
            child: Card(
              child: ListTile(
                title: Text(language),
              ),
            ),
          );
        },
      ),
    );
  }
}

