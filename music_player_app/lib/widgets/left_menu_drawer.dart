import 'package:flutter/material.dart';

import '../common/models/side_bar_model.dart';

class LeftMenuDrawer extends StatelessWidget {
  const LeftMenuDrawer({
    required this.onTap,
    super.key,
  });

  final void Function(SideBar) onTap;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 200,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Player',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          for (SideBar item in SideBar.values)
            ListTile(
              title: Text(item.getFieldName()),
              leading: item.getIcon(),
              onTap: () {
                // Handle option 2 tap
                onTap(item);
                Navigator.pop(context); // Close the Drawer
              },
            ),
          // Add more ListTiles for additional options
        ],
      ),
    );
  }
}
