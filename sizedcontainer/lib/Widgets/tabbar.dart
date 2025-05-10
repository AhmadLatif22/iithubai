import 'package:flutter/material.dart';

class TabBarWidget extends StatelessWidget {
  const TabBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 2,
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.teal,
            title: Text('Whatsapp'),
            bottom: TabBar(
                indicatorColor: Colors.black,
                automaticIndicatorColorAdjustment: true,
                isScrollable: true,
                tabs: [
              Tab(icon: Icon(Icons.chat),text: 'Chats',),
              Tab(icon: Icon(Icons.chat_bubble),text: 'Status',),
              Tab(icon: Icon(Icons.chat),text: 'Community',),
              Tab(icon: Icon(Icons.call),text: 'Calls',),
            ]),
          ),
          body: TabBarView(children: [
            Container(child: Center(child: Text('Chats',style: TextStyle(fontSize: 30),),),),
            Container(child: Center(child: Text('Status',style: TextStyle(fontSize: 30),),),),
            Container(child: Center(child: Text('Community',style: TextStyle(fontSize: 30),),),),
            Container(child: Center(child: Text('Calls',style: TextStyle(fontSize: 30),),),),

          ]),
    ));
  }
}
