import 'package:flutter/cupertino.dart';
import 'package:holomusic/Common/Offline/OfflineStorage.dart';
import 'package:holomusic/Common/Playlist/Providers/Playlist.dart';

import '../../Player/Song.dart';

class OfflinePlaylist extends Playlist {
  OfflinePlaylist()
      : super(
            "I tuoi salvataggi",
            const AssetImage("resources/png/fake_thumbnail.png"),
            null){
    isOnline=false;
  }

  @override
  Future<List<Song>> getVideosInfo() async {
    final list = await OfflineStorage.getOfflineSongs();
    for (var element in list) {
      element.playlist = this;
    }
    return list;
  }
}
