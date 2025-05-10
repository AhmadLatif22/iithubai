import 'package:flutter/material.dart';

class ListGrid extends StatefulWidget {
  const ListGrid({super.key});

  @override
  State<ListGrid> createState() => _ListGridState();
}

class _ListGridState extends State<ListGrid> {
  List<String> fruits=['Orange','Apple','Banana','Mango'];
  Map fruits_person={
    'fruits':['Orange','Apple','Banana','Mango'],
    'names':['Ahmad','Abdullah','Muzamil','Ali'],
  };
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List and Grid'),
        backgroundColor: Colors.redAccent,
        elevation: 6,
      ),
      body: Container(
        // child: ListView.builder(
        //     itemCount: fruits.length,
        //     itemBuilder:(context, index){
        //       return Card(child: ListTile(
        //         onTap: (){
        //           print((fruits_person['fruits'][index]));
        //         },
        //         hoverColor: Colors.blue,
        //         leading: Icon(Icons.person),
        //         title: Text(fruits_person['fruits'][index]),
        //         subtitle: Text(fruits_person['names'][index]),
        //       )
        //
        //         ,);
        //     }
        // ),
        // child: GridView(
        //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3,
        //       crossAxisSpacing: 20,
        //       mainAxisSpacing: 20,
        //       childAspectRatio: 2/3,
        //   ),
        //   children: [
        //     Card (
        //       child: Center(child: Text('Orange')),
        //     ),
        //     Card (
        //       child: Center(child: Text('Apple')),
        //     ),
        //     Card (
        //       child: Center(child: Text('Banana')),
        //     ),
        //     Card (
        //       child: Center(child: Text('Strawberry ')),
        //     )
        //   ],
        // ),
        child: GridView.builder(
            itemCount: fruits.length,
            gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            itemBuilder: (Context,index){
              return Card(
              child: Center(child: Text(fruits[index]),
            ),
          );
        },
      ),
      )
    );
  }
}
