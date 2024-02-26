import 'package:flutter/material.dart';

class SelectedSongView extends StatelessWidget {
  const SelectedSongView({
    required this.title,
    required this.artist,
    this.leadingIcon,
    this.trailingIcon,
    this.onTap,
    super.key,
  });

  final String title;
  final String artist;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(artist),
      leading: leadingIcon ?? const Icon(Icons.music_note),
      trailing: trailingIcon,
      onTap: onTap,
    );
  }
}
