import 'dart:ui';

import 'package:flutter/material.dart';

import '../Player/Song.dart';

//All playlist must extends the class

abstract class PlaylistBase {
  late ImageProvider? imageProvider;
  late String name;
  late Color? backgroundColor;
  bool isOnline = true;
  bool isOnServer = false;
  bool _canDownload = true;
  ValueNotifier<bool> isDownloading = ValueNotifier(false);

  PlaylistBase(this.name, this.imageProvider, this.backgroundColor);

  Future<List<Song>> getSongs();

  Future<ImageProvider> getImageProvider() async {
    if (imageProvider != null) {
      return Future.value(imageProvider);
    }
    final videos = await getSongs();
    if (videos.isNotEmpty) {
      return videos.first.getThumbnailImageAsset();
    } else {
      return const AssetImage("resources/png/fake_thumbnail.png");
    }
  }

  /*
  If the playlist has a reference url, for example a website in which the playlist
  is taken, override this method.
   */
  String? getReferenceUrl() {
    return null;
  }

  Future delete() async {}

  Future downloadAllSongs() async {
    _canDownload = true;
    final songs = await getSongs();

    for (var e in songs) {
      await e.saveSong();
      if (!_canDownload) break;
    }
  }

  Future deleteAllSongs() async {
    final songs = await getSongs();
    for (var e in songs) {
      await e.deleteSong();
    }
  }

  Future<bool> areAllSongsSaved() async {
    final list = await getSongs();
    bool allSaved = true;
    for (var element in list) {
      if (await element.isOnline()) {
        allSaved = false;
        break;
      }
    }
    return allSaved;
  }

  Future<bool> isAtLeastOneSaved() async {
    final list = await getSongs();
    bool oneSaved = false;

    for (var element in list) {
      if (!await element.isOnline()) {
        oneSaved = true;
        break;
      }
    }
    return oneSaved;
  }

  void stopDownload() {
    _canDownload = false;
  }

  void setIsDownloading(bool isDownloading) {
    this.isDownloading.value = isDownloading;
  }

  Future<bool> containsSong(Song song) async {
    final songs = await getSongs();
    return songs.any((element) => element.id == song.id);
  }
}
