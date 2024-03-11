import 'package:flutter/material.dart';

class DeleteWidget extends StatelessWidget {
  const DeleteWidget({
    required this.title,
    this.subtitle,
    this.onConfirm,
    this.onCancel,
    super.key,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 15),
              if (subtitle != null) Text(subtitle!),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => onCancel?.call(),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => onConfirm?.call(),
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}
