import 'dart:ui';

import 'package:holomusic/Common/DataFetcher/VideoInfo.dart';

abstract class Playlist {
  late String imageUrl;
  late String name;
  late Color? backgroundColor;

  Playlist(this.name, this.imageUrl, this.backgroundColor);

  Future<List<VideoInfo>> getVideosInfo();


  /*
  If the playlist has a reference url, for example a website in which the playlist
  is taken, reimplements this method.
   */
  String? getReferenceUrl(){
    return null;
  }
}
