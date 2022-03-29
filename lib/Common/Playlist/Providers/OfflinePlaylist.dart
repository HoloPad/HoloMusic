import 'package:holomusic/Common/Offline/OfflineStorage.dart';
import 'package:holomusic/Common/Playlist/Providers/Playlist.dart';

import '../../Player/Song.dart';

class OfflinePlaylist extends Playlist {
  OfflinePlaylist()
      : super(
            "I tuoi salvataggi",
            "https://27mi124bz6zg1hqy6n192jkb-wpengine.netdna-ssl.com/wp-content/uploads/2019/10/Our-Top-10-Songs-About-School-768x569.png",
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
