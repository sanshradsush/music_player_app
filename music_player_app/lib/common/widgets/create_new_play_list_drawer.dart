import 'package:flutter/material.dart';

class CreatePlayListDrawer extends StatelessWidget {
  const CreatePlayListDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        border: Border.all(
          color: Colors.grey,
        ),
        boxShadow: const [
          BoxShadow(
            spreadRadius: 2,
            blurRadius: 1,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Center(
              child: Text(
                'Create New Playlist',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
