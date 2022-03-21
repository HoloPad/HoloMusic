import 'dart:ui';

import 'package:holomusic/Common/DataFetcher/VideoInfo.dart';

abstract class Playlist {
  late String imageUrl;
  late String name;
  late Color? backgroundColor;

  Playlist(this.name, this.imageUrl, this.backgroundColor);

  Future<List<VideoInfo>> getVideosInfo();
}
