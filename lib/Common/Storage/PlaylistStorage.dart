import 'dart:io';

import 'package:holomusic/Common/Player/OfflineSong.dart';
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

  static Future convertSongToOnline(Song song) async {
    final plist = await _db.collection(_collectionName).get();
    if (plist == null) return;
    for (var plt in plist.values) {
      final playlist = PlaylistSaved.fromJson(plt);
      bool found = false;
      for (var index = 0; index < playlist.songs.length; index++) {
        if (!await playlist.songs[index].isOnline() &&
            playlist.songs[index].id == song.id) {
          playlist.songs[index] = await OnlineSong.createFromId(song.id);
          found = true;
        }
      }
      if (found) {
        playlist.save();
      }
    }
  }

  static Future convertOnlineSongToOffline(
      OnlineSong onlineSong, OfflineSong offlineSong) async {
    final plist = await _db.collection(_collectionName).get();
    if (plist == null) return;
    for (var plt in plist.values) {
      final playlist = PlaylistSaved.fromJson(plt);
      bool found = false;
      for (var index = 0; index < playlist.songs.length; index++) {
        if (await playlist.songs[index].isOnline() &&
            playlist.songs[index].id == onlineSong.id) {
          playlist.songs[index] = offlineSong;
          found = true;
        }
      }
      if (found) {
        playlist.save();
      }
    }
  }
}
