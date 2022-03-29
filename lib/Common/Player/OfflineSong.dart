import 'package:holomusic/Common/Offline/OfflineStorage.dart';
import 'package:holomusic/Common/Player/Song.dart';

class OfflineSong extends Song {
  String filePath;

  OfflineSong(String id, String title, String thumbnail, this.filePath)
      : super(id, title, thumbnail);

  @override
  Future<Uri> getAudioUri() async {
    return Uri.file(filePath);
  }

  @override
  Future<Song?> getFirstOfThePlaylist() async {
    if (!isAPlaylist()) {
      return null;
    }
    final videoList = await playlist?.getVideosInfo();
    final firstVideo = videoList?.first;
    if (firstVideo == null) {
      return null;
    }
    final song = await OfflineStorage.getSongById(firstVideo.id);
    song?.playlist = playlist;
    return song;
  }

  @override
  Future<Song?> getNext() async {
    if (!isAPlaylist()) {
      return null;
    }
    final videoList = await playlist?.getVideosInfo();
    if (videoList == null) {
      return null;
    }

    var currentSongIndex = 0;
    while (currentSongIndex < videoList.length &&
        videoList[currentSongIndex].id != id) {
      currentSongIndex++;
    }

    if (currentSongIndex + 1 >= videoList.length) {
      //Not found
      return null;
    } else {
      //Return next
      final next = videoList[currentSongIndex + 1];
      next.playlist=playlist;
      return next;
    }
  }

  @override
  bool isOnline() {
    return false;
  }
}
