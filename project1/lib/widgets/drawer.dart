import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.orange,
            ),
            child: Text(
              'Al-Qamar Citrus',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Employees'),
            onTap: () {
              Navigator.pushNamed(context, '/employees');
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_florist),
            title: const Text('Sellers'),
            onTap: () {
              Navigator.pushNamed(context, '/sellers');
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('Buyers'),
            onTap: () {
              Navigator.pushNamed(context, '/buyers');
            },
          ),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Expenses'),
            onTap: () {
              Navigator.pushNamed(context, '/expenses');
            },
          ),
          ListTile(
            leading: const Icon(Icons.monetization_on),
            title: const Text('Profit'),
            onTap: () {
              Navigator.pushNamed(context, '/profit');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
