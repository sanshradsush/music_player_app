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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,),
        subtitle: Text(artist),
        leading: leadingIcon,
        onTap: onTap,
      ),
    );
  }
}
