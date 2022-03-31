import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:holomusic/Common/Playlist/PlaylistBase.dart';
import 'package:localstore/localstore.dart';

import '../Player/Song.dart';

class PlaylistSaved extends PlaylistBase {
  static final _db = Localstore.instance;
  static final _collectionName =
      "holomusic" + Platform.pathSeparator + "playlists";
  late List<Song> songs;
  String? id;

  PlaylistSaved(name, {this.id, List<Song>? list})
      : super(
            name, const AssetImage("resources/png/fake_thumbnail.png"), null) {
    songs = list ?? List.empty(growable: true);
  }

  void addSong(Song song) {
    if (!songs.any((element) => element.id == song.id)) {
      songs.add(song);
    }
  }

  void deleteSong(Song song, {bool save = false}) {
    songs.removeWhere((element) => element.id == song.id);
    if (save) this.save();
  }

  void save() {
    if (id == null) {
      // If Is it the first save
      id = _db.collection(_collectionName).doc().id;
      _db.collection(_collectionName).doc(id).set(toJson());
    }
    _db.collection(_collectionName).doc(id).set(toJson());
  }

  Future<bool> exists() async {
    if (id == null) {
      return false;
    }
    return (await _db.collection(_collectionName).doc(id).get()) != null;
  }

  Map<String, dynamic> toJson() {
    return {"name": name, "songs": songs, "id": id!};
  }

  factory PlaylistSaved.fromJson(Map<String, dynamic> map) {
    List<dynamic> a = List.from(map['songs']);
    List<Song> aSongs = a.map((e) => Song.fromJson(e)).toList(growable: true);
    return PlaylistSaved(map['name'], id: map['id'], list: aSongs);
  }

  @override
  Future<List<Song>> getVideosInfo() {
    return Future.value(songs);
  }

  @override
  Future<ImageProvider> getImageProvider() async {
    final videos = await getVideosInfo();
    if (videos.isNotEmpty) {
      return videos.first.getThumbnailImageAsset();
    } else {
      return const AssetImage("resources/png/fake_thumbnail.png");
    }
  }

  @override
  Future delete() async {
    if (id == null) {
      return;
    }
    await _db.collection(_collectionName).doc(id).delete();
  }
}
