import 'dart:io';

import 'package:holomusic/Common/Playlist/PlaylistSaved.dart';
import 'package:localstore/localstore.dart';

class PlaylistStorage {
  static final _db = Localstore.instance;
  static final _collectionName =
      "holomusic" + Platform.pathSeparator + "playlists";

  static Future<List<PlaylistSaved>> getAllPlaylists() async {
    final plist = await _db.collection(_collectionName).get();
    return plist?.values.map((e) => PlaylistSaved.fromJson(e)).toList() ??
        List.empty();
  }
}
