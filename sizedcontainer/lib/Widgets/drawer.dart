import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import added

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Container(
          color: Colors.deepPurple,
          child: ListView(
            children: [
              DrawerHeader(
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(
                            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRpsu8sER1NVEEA5OOsE4tI68CBvOqCemPmAgvziqHuqvn1FruomypSEbRJIb5kzCbdEuA&usqp=CAU'),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Ahmad Latif',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text('al@gmail.com'),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Profile'),
              ),
              ListTile(
                leading: Icon(Icons.folder),
                title: Text('Files'),
              ),
              ListTile(
                leading: Icon(Icons.group),
                title: Text('Shared With Me'),
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Trash'),
              ),
              ListTile(
                leading: Icon(Icons.upload),
                title: Text('Uploads'),
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.share),
                title: Text('Share'),
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple, // Changed to maroon color
        title: Text('Drawer'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                _launchURL('https://flutter.dev');
              },
              child: Container(
                height: 250,
                width: 300,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      color: Colors.black26,
                      spreadRadius: 5.0,
                    ),
                  ],
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: AssetImage('assets/sigma.jpg'),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Show Alert'),
              onPressed: () {
                _showMyDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showMyDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
          title: Text('Heloooo'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('this is a demo'),
                Text('This is Ahmad Latif'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Approved!')),
                );
              },
              child: Text('Approve'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Method to launch URL
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }
  Future<void> _testLaunch() async {
    const testUrl = 'https://linktr.ee/AhmadLatiff';
    final Uri uri = Uri.parse(testUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      print('Could not launch $testUrl');
    }
  }

}
