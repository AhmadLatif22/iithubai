import 'package:flutter/material.dart';

class StackWidget extends StatelessWidget {
  const StackWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stack'),
      ),
      body: Stack(children: [
        Positioned(
            child: Container(
              height: 300,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                image: DecorationImage(image: AssetImage('assets/sigma.jpg'),
                fit: BoxFit.cover,
                )
              ) ,
        ),
        ),
        Positioned(
            left: 20,
            top: 30,
            child: Container(
              height: 50,
              width: 50,
              color: Colors.deepPurple.shade200,
        ),),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 50,
            width: 50,
            color: Colors.deepPurple.shade200,
          ),
        )
      ],)

      // body: Container(
      //   color: Colors.white,
      //   child: Stack(
      //     children: [
      //       // First positioned widget at bottom-left
      //       Positioned(
      //         left: 20,
      //         bottom: 20,
      //         child: Container(
      //           height: 350,
      //           width: 350,
      //           color: Colors.deepPurple.shade300,
      //         ),
      //       ),
      //       // Second positioned widget at bottom-left (with some offset)
      //       Positioned(
      //         left: 160,
      //         bottom: 160,
      //         child: Container(
      //           height: 250,
      //           width: 250,
      //           color: Colors.deepPurple.shade200,
      //         ),
      //       ),
      //       // Third positioned widget with more offset
      //       Positioned(
      //         right: 20,
      //         bottom: 295,
      //         child: Container(
      //           height: 150,
      //           width: 150,
      //           color: Colors.deepPurple.shade100,
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}
