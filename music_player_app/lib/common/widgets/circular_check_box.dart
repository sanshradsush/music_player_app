import 'package:flutter/material.dart';

class CircularCheckbox extends StatelessWidget {
  const CircularCheckbox({
    required this.value,
    super.key,
  });

  final bool value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24.0,
      height: 24.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: value ? Colors.blue : Colors.transparent,
        border: Border.all(
          width: 2.0,
        ),
      ),
      child: value
          ? const Icon(
              Icons.check,
              size: 16.0,
              color: Colors.white,
            )
          : null,
    );
  }
}
