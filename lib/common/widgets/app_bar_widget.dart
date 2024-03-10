import 'package:flutter/material.dart';

class AppBarWidget extends StatelessWidget {
  const AppBarWidget({
    required this.title,
    required this.leadingPress,
    required this.leadingIcon,
    this.subtitle,
    super.key,
  });

  final String title;
  final VoidCallback leadingPress;
  final Widget leadingIcon;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: leadingPress,
        ),
        ListTile(
          contentPadding: const EdgeInsets.all(10),
          leading: Container(
            width: 60,
            height: 60,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              shape: BoxShape.rectangle,
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Center(child: leadingIcon),
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          subtitle: subtitle != null ? Text(subtitle!) : null,
        ),
      ],
    );
  }
}
