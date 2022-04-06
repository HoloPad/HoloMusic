import 'dart:io';

import 'package:holomusic/Common/Playlist/PlaylistBase.dart';
import 'package:localstore/localstore.dart';

import '../Player/OfflineSong.dart';
import '../Player/OnlineSong.dart';
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
    for (var i = 0; i < songs.length; i++) {
      songs[i].playlist = this;
    }
  }

  void addSong(Song song) {
    if (!songs.any((element) => element.id == song.id)) {
      songs.add(song);
    }
  }

  void addInTop(Song song) {
    if (!songs.any((element) => element.id == song.id)) {
      songs.insert(0, song);
    }
  }

  void deleteSong(Song song, {bool save = false}) {
    songs.removeWhere((element) => element.id == song.id);
    if (save) this.save();
  }

  Future save() async {
    id ??= _db.collection(_collectionName).doc().id;
    await updateStates();
    await _db.collection(_collectionName).doc(id).set(toJson());
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
    final ref = _db.collection(_collectionName).doc(id);
    File file = File(ref.path);
    ref.delete();
    if (file.existsSync()) file.deleteSync();
  }

  Future updateStates() async {
    final songs = await getSongs();
    for (int i = 0; i < songs.length; i++) {
      bool songIsStored = await OfflineSong.exists(songs[i].id);
      bool songIsOnline = songs[i].runtimeType == OnlineSong;

      if (songIsOnline && songIsStored) {
        songs[i] =
            (await OfflineSong.getById(songs[i].id, playlistBase: this))!;
      } else if (!songIsOnline && !songIsStored) {
        songs[i] = await OnlineSong.createFromId(songs[i].id, playlist: this);
      }
    }
  }
}
