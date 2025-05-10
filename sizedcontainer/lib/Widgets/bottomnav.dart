import 'package:flutter/material.dart';
import 'package:sizedcontainer/Widgets/alert.dart';
import 'package:sizedcontainer/Widgets/dismissible.dart';
import 'package:sizedcontainer/Widgets/drawer.dart';
import 'package:sizedcontainer/Widgets/snackBar.dart';


class BottomNavWidget extends StatefulWidget {
  const BottomNavWidget({super.key});

  @override
  State<BottomNavWidget> createState() => _BottomNavWidgetState();
}

class _BottomNavWidgetState extends State<BottomNavWidget> {
int selectedIndex= 0;
PageController pageController = PageController();
// List<Widget>widgets =[
// Text('Home'),
// Text('Search'),
// Text('Add'),
// Text('Profile'),
//
// ];
  void ontapped(int index){
    setState((){
      selectedIndex =index;
});
    pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Bottom Nav'),
      // ),
     // body: Center(child: widgets.elementAt(selectedIndex),),
      body: PageView(
        controller: pageController,
        children: [
          AlertWidget(),
          DismissibleWidget(),
          DrawerWidget(),
          SnackBarWidget(),
        ],
      ),
     bottomNavigationBar: BottomNavigationBar(items: const<BottomNavigationBarItem>[
       BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
       BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
       BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add'),
       BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    ],
    currentIndex: selectedIndex ,
    selectedItemColor: Colors.green,
    unselectedItemColor: Colors.grey,
    onTap: ontapped,
     ),
    );
  }
}
