import 'dart:io';

import 'package:holomusic/Common/Playlist/PlaylistSaved.dart';
import 'package:localstore/localstore.dart';

import '../Player/Song.dart';

//Custom playlist used for the search history
class PlaylistSearchHistory extends PlaylistSaved {
  static const maxHistoryLength = 20;

  PlaylistSearchHistory(
      String name, String? id, List<Song>? list, String? customCollectionName)
      : super(name,
            id: id, list: list, customCollectionName: customCollectionName);

  static PlaylistSearchHistory instance() {
    final collection = "holomusic" + Platform.pathSeparator + "history";
    const id = "history";
    return PlaylistSearchHistory(id, id, null, collection);
  }

  @override
  Future<List<Song>> getSongs() async {
    if (songs.isNotEmpty) {
      return songs;
    }

    final collection = "holomusic" + Platform.pathSeparator + "history";
    const id = "history";
    final map = await Localstore.instance.collection(collection).doc(id).get();
    if (map != null) {
      if (map['songs'].runtimeType == List<dynamic>) {
        songs = List.from(map['songs']).map((e) => Song.fromJson(e)).toList();
      } else {
        songs = List.from(map['songs']);
      }
    } else {
      songs = List.empty(growable: true);
    }
    for (var i = 0; i < songs.length; i++) {
      songs[i].playlist = this;
    }
    return songs;
  }

  @override
  Future addSong(Song song) async {
    final songs = await getSongs();
    if (songs.length >= maxHistoryLength) {
      deleteSong(songs.last);
    }

    // If already inserted, remove and re-insert to show the song on the top
    int index = songs.indexWhere((element) => element.id == song.id);
    if (index > 0) {
      songs.removeAt(index);
    }

    super.addInTop(song);
    super.save();
  }
}
