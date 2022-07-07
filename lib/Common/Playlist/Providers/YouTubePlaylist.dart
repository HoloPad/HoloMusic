import 'package:flutter/material.dart';
import 'package:holomusic/Common/Player/OnlineSong.dart';
import 'package:holomusic/Common/Player/Song.dart';
import 'package:holomusic/Common/Storage/Cache.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../PlaylistBase.dart';

class YoutubePlaylist extends PlaylistBase {
  Playlist playlist;
  final yt = YoutubeExplode();
  List<Song>? songsCache;
  String id;

  YoutubePlaylist(this.playlist, this.id) : super(playlist.title, null, null);

  static Future<YoutubePlaylist> createFromUrl(String url) async {
    final playlist = await YoutubeExplode().playlists.get(url);
    return YoutubePlaylist(playlist, playlist.id.value);
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

  @override
  Future<ImageProvider> getImageProvider() async {
    final imgUrl = await Cache.getValueByKey(id);
    if (imgUrl != null) {
      return NetworkImage(imgUrl);
    } else {
      final superProvider = await super.getImageProvider();
      if (superProvider is NetworkImage) {
        final url = superProvider.url;
        Cache.setValueByKey(url, id);
      }
      return superProvider;
    }
  }
}
