import 'package:flutter/material.dart';

class LeftMenuDrawer extends StatelessWidget {
  const LeftMenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 100,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Drawer Header',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: const Text('Option 1'),
            onTap: () {
              // Handle option 1 tap
              Navigator.pop(context); // Close the Drawer
            },
          ),
          ListTile(
            title: const Text('Option 2'),
            onTap: () {
              // Handle option 2 tap
              Navigator.pop(context); // Close the Drawer
            },
          ),
          // Add more ListTiles for additional options
        ],
      ),
    );
  }
}
