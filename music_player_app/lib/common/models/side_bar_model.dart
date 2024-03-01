import 'package:flutter/material.dart';

enum SideBar {
  allSongs,
  likedSong;

  String getFieldName() {
    final key = switch (this) {
      SideBar.allSongs => "All Songs",
      SideBar.likedSong => "Liked",
    };

    return key;
  }

  Widget getIcon() {
    final icon = switch (this) {
      SideBar.allSongs => const Icon(Icons.music_note),
      SideBar.likedSong => const Icon(Icons.heart_broken),
    };

    return icon;
  }
}
