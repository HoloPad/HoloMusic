import 'package:holomusic/Common/Playlist/Providers/Playlist.dart';

abstract class Song {
  Playlist? playlist;
  String id;
  String title;
  String? thumbnail;

  Song(this.id, this.title, this.thumbnail, {this.playlist});

  Future<Uri> getAudioUri();

  Future<Song?> getNext();

  Future<Song?> getFirstOfThePlaylist();

  bool isOnline();

  bool isAPlaylist() {
    return playlist != null;
  }

  Duration? getDuration() {
    return null;
  }

  Future<bool> hasNext() async {
    if (isAPlaylist()) {
      return await getNext() != null;
    } else {
      return false;
    }
  }

  //If you want to load lazy staff, call this method
  Future preloadStream() async {

  }
  Future downloadStream() async {

  }

  String getThumbnail() {
    return thumbnail ??
        "https://27mi124bz6zg1hqy6n192jkb-wpengine.netdna-ssl.com/wp-content/uploads/2019/10/Our-Top-10-Songs-About-School-768x569.png";
  }
}
