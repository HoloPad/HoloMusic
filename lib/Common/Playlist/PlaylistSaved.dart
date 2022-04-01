import 'dart:io';

import 'package:holomusic/Common/Playlist/PlaylistBase.dart';
import 'package:localstore/localstore.dart';

import '../Player/Song.dart';

class PlaylistSaved extends PlaylistBase {
  final _db = Localstore.instance;
  String _collectionName = "holomusic" + Platform.pathSeparator + "playlists";
  late List<Song> songs;
  String? id;

  PlaylistSaved(name, {this.id, List<Song>? list, String? customCollectionName})
      : super(name, null, null) {
    if (customCollectionName != null) {
      _collectionName = customCollectionName;
    }
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
    //check songs
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
  Future<List<Song>> getSongs() {
    return Future.value(songs);
  }

  @override
  Future delete() async {
    if (id == null) {
      return;
    }
    await _db.collection(_collectionName).doc(id).delete();
  }
}
