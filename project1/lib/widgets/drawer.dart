import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(
              'Al-Qamar Citrus',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.orange,
            ),
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text('Employees'),
            onTap: () {
              Navigator.pushNamed(context, '/employees');
            },
          ),
          ListTile(
            leading: Icon(Icons.local_florist),
            title: Text('Sellers'),
            onTap: () {
              Navigator.pushNamed(context, '/sellers');
            },
          ),
          ListTile(
            leading: Icon(Icons.shopping_cart),
            title: Text('Buyers'),
            onTap: () {
              Navigator.pushNamed(context, '/buyers');
            },
          ),
          ListTile(
            leading: Icon(Icons.attach_money),
            title: Text('Expenses'),
            onTap: () {
              Navigator.pushNamed(context, '/expenses');
            },
          ),
          ListTile(
            leading: Icon(Icons.monetization_on),
            title: Text('Profit'),
            onTap: () {
              Navigator.pushNamed(context, '/profit');
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
