import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:holomusic/Common/Playlist/Providers/Playlist.dart';

abstract class Song {
  Playlist? playlist;
  String id;
  String title;
  String? thumbnail;

  Song(this.id, this.title, this.thumbnail, {this.playlist});

  Future<Uri> getAudioUri();

  Future<Song?> getNext();

  Future<Song?> getFirstOfThePlaylist();

  bool isOnline();

  bool isAPlaylist() {
    return playlist != null;
  }

  Duration? getDuration() {
    return null;
  }

  Future<bool> hasNext() async {
    if (isAPlaylist()) {
      final next = await getNext();
      return next != null;
    } else {
      return false;
    }
  }

  //If you want to load lazy staff, call this method
  Future preloadStream() async {}

  Future downloadStream() async {}

  Uri? getThumbnailUri() {
    if (thumbnail != null) {
      return Uri.tryParse(thumbnail!);
    }
    return null;
  }

  ImageProvider getThumbnailImageAsset() {
    if (thumbnail != null) {
      bool isUrl = Uri.tryParse(thumbnail!)?.host.isNotEmpty ?? false;
      if (isUrl) {
        return NetworkImage(thumbnail!);
      } else {
        final file = File(thumbnail!);
        return FileImage(file);
      }
    } else {
      return const AssetImage("resources/png/fake_thumbnail.png");
    }
  }
}
