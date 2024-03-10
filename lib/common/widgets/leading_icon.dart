import 'package:flutter/material.dart';

class LeadingIcon extends StatelessWidget {
  const LeadingIcon({required this.icon, this.width, super.key});

  final Widget icon;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width ?? 50.0,
        height: width ?? 50.0,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 163, 200, 230),
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            width: 0.2,
          ),
        ),
        child: icon);
  }
}
