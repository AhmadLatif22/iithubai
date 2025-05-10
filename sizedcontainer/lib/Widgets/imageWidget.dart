import 'package:flutter/material.dart';

class ImageWidget extends StatefulWidget {
  const ImageWidget({super.key});

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red.shade900,
        title: Text('Image Widget'),

      ),
      body: Center(
        child: Container(
          height: 250,
          width: 300,

          // decoration: BoxDecoration(
          //   boxShadow: [
          //     BoxShadow(
          //       blurRadius: 10,
          //       color: Colors.black26,
          //       spreadRadius: 5.0,
          //     )
          //   ],
          //   color: Colors.white, // Moved to BoxDecoration
          //   borderRadius: BorderRadius.circular(10),
          //   image: DecorationImage(
          //     image: AssetImage(
          //         'assets/sigma.jpg'),
          //     fit: BoxFit.fill, // Correct usage of fit
          //   ),
          // ),
        ),
      ),
    );
  }
}
