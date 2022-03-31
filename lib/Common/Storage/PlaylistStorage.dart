import 'dart:io';

import 'package:holomusic/Common/Player/OnlineSong.dart';
import 'package:holomusic/Common/Playlist/PlaylistSaved.dart';
import 'package:localstore/localstore.dart';

import '../Player/Song.dart';

class PlaylistStorage {
  static final _db = Localstore.instance;
  static final _collectionName =
      "holomusic" + Platform.pathSeparator + "playlists";

  static Future<List<PlaylistSaved>> getAllPlaylists() async {
    final plist = await _db.collection(_collectionName).get();
    return plist?.values.map((e) => PlaylistSaved.fromJson(e)).toList() ??
        List.empty();
  }

  static Future convertSongToOffline(Song song) async {
    final plist = await _db.collection(_collectionName).get();
    if(plist==null)return;
    for(var plt in plist.values){
      final playlist = PlaylistSaved.fromJson(plt);
      for (var s in playlist.songs){
        if(s.isOnline() && s.id==song.id) {
          song=await OnlineSong.createFromId(song.id);
        }
      }
    }
  }
}
