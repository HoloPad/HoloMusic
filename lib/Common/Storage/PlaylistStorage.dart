import 'dart:io';

import 'package:holomusic/Common/Playlist/PlaylistSaved.dart';
import 'package:holomusic/ServerRequests/UserRequest.dart';
import 'package:localstore/localstore.dart';

class PlaylistStorage {
  static final _db = Localstore.instance;
  static final _collectionName = "holomusic" + Platform.pathSeparator + "playlists";

  static Future<List<PlaylistSaved>> getAllPlaylists() async {
    final plist = await _db.collection(_collectionName).get();
    final localPlaylists =
        plist?.values.map((e) => PlaylistSaved.fromJson(e)).toList() ?? List.empty(growable: true);
    for (var value in localPlaylists) {
      value.isOtherUsersPlaylist = false;
    }

    final onlinePlaylistResponse = await UserRequest.getUserOnlinePlaylists();
    if (onlinePlaylistResponse != null) {
      for (var playlist in onlinePlaylistResponse.result) {
        final isNotPresent = !localPlaylists.any((element) => element.id == playlist.id);
        if (playlist.id != null && isNotPresent) {
          localPlaylists.add(playlist);
        }
      }
    }
    return localPlaylists;
  }

  static Future syncUserPlaylist() async {
    print("HERE");
    if (UserRequest.isLogin()) {
      print("LOGGED");

      final onlinePlaylistResponse = await UserRequest.getUserOnlinePlaylists();
      if (onlinePlaylistResponse == null) {
        return;
      }
      print("NOT null");

      final localPlaylist = await PlaylistStorage.getAllPlaylists();
      print("FOUND " + onlinePlaylistResponse.result.length.toString());

      for (var onlinePlaylist in onlinePlaylistResponse.result) {
        final localIds = localPlaylist.map((e) => e.id);
        print(localIds);
        if (!localPlaylist.map((e) => e.id).contains(onlinePlaylist.id)) {
          await onlinePlaylist.save();
        }
      }
    }
    print("NOT LOGGED");
  }
}
