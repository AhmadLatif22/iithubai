import 'package:flutter/material.dart';

class RowsCols extends StatelessWidget {
  const RowsCols({super.key});

  @override
  Widget build(BuildContext context) {
    var w=MediaQuery.of(context).size.width;
    var h=MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('rows and columns '),
      ),
      body: Container(
        height: h,
        width: w,
        color: Colors.white38 ,
        child: Column(
          // direction: Axis.vertical,
          // alignment: WrapAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.end,
          children:[
        //     Text('AHMAD'),
        //
          Container(height: 60,width: 60,color: Colors.lime,),
          Container(height: 60,width: 60,color: Colors.greenAccent,),
          Container(height: 60,width: 60,color: Colors.purpleAccent,),
          Container(height: 60,width: 60,color: Colors.orangeAccent,),
          Container(height: 60,width: 60,color: Colors.purpleAccent,),

        ])
        //Center(child: Container(height: 60,width: 60,color: Colors.blue,),),

      ),
    );
  }
}
