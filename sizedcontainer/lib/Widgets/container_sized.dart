import 'package:flutter/material.dart';

class ContainerSized extends StatelessWidget {
  const ContainerSized({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('Container and SizedBox'),
      ),
      body: Center(
          child: Container(margin
              : const EdgeInsets.all(10),height: 70 ,width: 100,
          decoration: const BoxDecoration(color: Colors.lightBlue,
              //shape: BoxShape.circle
              //borderRadius: BorderRadius.circular(2),
              borderRadius: BorderRadius.only(topLeft:  Radius.circular(12), bottomRight: Radius.circular(12)),
              boxShadow: [
                BoxShadow(blurRadius: 20,spreadRadius: 10,color: Colors.white)
              ]
          ),
          child: Center(child: Container(margin:const EdgeInsets.all(10),color: Colors.redAccent,)
         // Text('Ahmad' , style: TextStyle(fontSize: 19))
          ))),
      //Center( child: SizedBox( height: 50, width: 50, child: Text('Hello'),),),
    );
  }
}
