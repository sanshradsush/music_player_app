import 'package:flutter/material.dart';

enum SideBar {
  allSongs,
  likedSong,
  playlist,
  folder,
  album,
  artist;

  String getFieldName() {
    final key = switch (this) {
      SideBar.allSongs => "Songs",
      SideBar.likedSong => "Liked",
      SideBar.playlist => "Playlist",
      SideBar.folder => "Folders",
      SideBar.album => "Albums",
      SideBar.artist => "Artists",
    };

    return key;
  }

  Widget getIcon() {
    final icon = switch (this) {
      SideBar.allSongs => const Icon(Icons.music_note),
      SideBar.likedSong => const Icon(Icons.heart_broken),
      _ => const Icon(Icons.folder),
    };

    return icon;
  }
}
