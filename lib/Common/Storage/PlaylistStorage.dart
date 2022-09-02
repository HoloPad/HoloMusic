import 'dart:io';

import 'package:holomusic/Common/Playlist/PlaylistSaved.dart';
import 'package:localstore/localstore.dart';

class PlaylistStorage {
  static final _db = Localstore.instance;
  static final _collectionName = "holomusic" + Platform.pathSeparator + "playlists";

  static Future<List<PlaylistSaved>> getAllPlaylists() async {
    final plist = await _db.collection(_collectionName).get();
    final plistList = plist?.values.map((e) => PlaylistSaved.fromJson(e)).toList() ?? List.empty();
    for (var value in plistList) {
      value.isOtherUsersPlaylist = false;
    }
    return plistList;
  }
}
