import 'package:flutter/material.dart';

class SongListView extends StatelessWidget {
  const SongListView({
    required this.title,
    required this.artist,
    this.leadingIcon,
    this.onTap,
    super.key,
  });

  final String title;
  final String artist;
  final Widget? leadingIcon;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(artist),
      leading: leadingIcon ?? const Icon(Icons.music_note),
      onTap: onTap,
    );
  }
}
