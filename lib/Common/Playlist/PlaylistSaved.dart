import 'dart:io';

import 'package:holomusic/Common/Playlist/PlaylistBase.dart';
import 'package:localstore/localstore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Player/OfflineSong.dart';
import '../Player/OnlineSong.dart';
import '../Player/Song.dart';

class PlaylistSaved extends PlaylistBase {
  final _db = Localstore.instance;
  String _collectionName = "holomusic" + Platform.pathSeparator + "playlists";
  late List<Song> songs;
  String? ownerId;

  String? id;
  DateTime lastUpdate = DateTime.now();

  PlaylistSaved(name,
      {this.id,
      List<Song>? list,
      bool? online,
      String? customCollectionName,
      this.ownerId})
      : super(name, null, null) {
    super.isOnServer = false;

    if (online != null) {
      super.isOnServer = online;
    }
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

  Future deleteSong(Song song, {bool save = false}) async {
    songs.removeWhere((element) => element.id == song.id);
    if (save) await this.save();
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
    late List<Map<String, dynamic>> jsonSongs = [];
    for (var i = 0; i < songs.length; i++) {
      jsonSongs.add(songs[i].toJson());
    }
    return {
      "name": name,
      "songs": jsonSongs,
      "id": id!,
      "datetime": DateTime.now().toIso8601String(),
      "onServer": super.isOnServer
    };
  }

  factory PlaylistSaved.fromJson(Map<String, dynamic> map) {
    List<dynamic> a = List.from(map['songs']);
    List<Song> aSongs = a.map((e) => Song.fromJson(e)).toList(growable: true);
    final playlist =
        PlaylistSaved(map['name'], online: map['onServer'], id: map['id'], list: aSongs);
    playlist.lastUpdate = DateTime.parse(map['datetime']);
    playlist.ownerId = map['creator'];
    return playlist;
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
        songs[i] = (await OfflineSong.getById(songs[i].id, playlistBase: this))! as Song;
      } else if (!songIsOnline && !songIsStored) {
        songs[i] = (await OnlineSong.createFromId(songs[i].id, playlist: this)) as Song;
      }
    }
  }
}
