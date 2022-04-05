import 'dart:io';

import 'package:holomusic/Common/Player/Song.dart';
import 'package:holomusic/Common/Storage/SongsStorage.dart';
import 'package:localstore/localstore.dart';
import 'package:path_provider/path_provider.dart';

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
    String collectionName = SongsStorage.collectionName;
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
    final song = OfflineSong(
        json['id'], json['title'], json['thumbnail'], json['filePath'],
        playlist: playlistBase);
    song.setSongState(SongState.values.elementAt(json['state']));
    return song;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "thumbnail": thumbnail,
      "online": false,
      "filePath": filePath,
      "state": stateNotifier.value.index
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
    //Delete audio file
    File songPath = File(filePath);
    songPath.deleteSync(recursive: true);

    //Delete image
    if (thumbnail != null) {
      File imgPath = File(thumbnail!);
      imgPath.deleteSync(recursive: true);
    }
    //Delete noSQL content
    final document = db.collection(collectionName).doc(id);

    //Delete json file
    final getDocumentPath = await getApplicationDocumentsDirectory();
    File file = File(getDocumentPath.path+Platform.pathSeparator+document.path);

    await document.delete();
    if(file.existsSync())file.deleteSync();
    await PlaylistStorage.convertSongToOnline(this);
    setSongState(SongState.online);
  }

  @override
  Future saveSong() async {
    return;
  }
}
