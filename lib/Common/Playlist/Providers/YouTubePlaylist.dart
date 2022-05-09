import 'package:holomusic/Common/Player/OnlineSong.dart';
import 'package:holomusic/Common/Player/Song.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../PlaylistBase.dart';

class YoutubePlaylist extends PlaylistBase {
  Playlist playlist;
  final yt = YoutubeExplode();
  List<Song>? songsCache;

  YoutubePlaylist(this.playlist) : super(playlist.title, null, null);

  static Future<YoutubePlaylist> createFromUrl(String url) async {
    final playlist = await YoutubeExplode().playlists.get(url);
    return YoutubePlaylist(playlist);
  }

  @override
  Future<List<Song>> getSongs() async {
    if (songsCache != null) {
      return songsCache!;
    }

    songsCache = List.empty(growable: true);
    await for (var video in yt.playlists.getVideos(playlist.id)) {
      songsCache?.add(OnlineSong(video, playlist: this));
    }
    return songsCache!;
  }
}
