import 'dart:io';

import 'package:holomusic/Common/Player/Song.dart';
import 'package:localstore/localstore.dart';

import '../Playlist/PlaylistBase.dart';
import '../Storage/PlaylistStorage.dart';

class OfflineSong extends Song {
  String filePath;

  OfflineSong(String id, String title, String thumbnail, this.filePath,
      {PlaylistBase? playlist})
      : super(id, title, thumbnail) {
    this.playlist = playlist;
  }

  static Future<OfflineSong?> getById(String id,
      {PlaylistBase? playlistBase}) async {
    final db = Localstore.instance;
    const collectionName = "holomusic";
    final element = await db.collection(collectionName).doc(id).get();
    if (element == null) {
      return null;
    }
    return OfflineSong(
        id, element['title'], element['thumbnail'], element['path'],
        playlist: playlistBase);
  }

  @override
  Future<Uri> getAudioUri() async {
    return Uri.file(filePath);
  }

  @override
  Future<Song?> getFirstOfThePlaylist() async {
    if (!isAPlaylist()) {
      return null;
    }
    final videoList = await playlist?.getSongs();
    final firstVideo = videoList?.first;
    if (firstVideo == null) {
      return null;
    }
    final song = await OfflineSong.getById(firstVideo.id);
    song?.playlist = playlist;
    return song;
  }

  @override
  factory OfflineSong.fromJson(Map<String, dynamic> json,
      {PlaylistBase? playlistBase}) {
    return OfflineSong(
        json['id'], json['title'], json['thumbnail'], json['filePath'],
        playlist: playlistBase);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "thumbnail": thumbnail,
      "online": false,
      "filePath": filePath
    };
  }

  @override
  Future<Song?> getNext() async {
    if (!isAPlaylist()) {
      return null;
    }
    final videoList = await playlist?.getSongs();
    if (videoList == null) {
      return null;
    }

    var currentSongIndex = 0;
    while (currentSongIndex < videoList.length &&
        videoList[currentSongIndex].id != id) {
      currentSongIndex++;
    }

    if (currentSongIndex + 1 >= videoList.length) {
      //Not found
      return null;
    } else {
      //Return next
      final next = videoList[currentSongIndex + 1];
      next.playlist = playlist;
      return next;
    }
  }

  @override
  Future deleteSong() async {
    File songPath = File(filePath);
    songPath.deleteSync(recursive: true);
    if (thumbnail != null) {
      File imgPath = File(thumbnail!);
      imgPath.deleteSync(recursive: true);
    }
    await db.collection(collectionName).doc(id).delete();
    await PlaylistStorage.convertSongToOnline(this);
    stateNotifier.value = SongState.online;
  }

  @override
  Future saveSong() async {
    return;
  }
}
