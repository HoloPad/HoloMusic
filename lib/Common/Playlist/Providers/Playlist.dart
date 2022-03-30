import 'dart:ui';

import 'package:flutter/material.dart';

import '../../Player/Song.dart';


abstract class Playlist {
  late ImageProvider imageUrl;
  late String name;
  late Color? backgroundColor;
  bool isOnline=true;

  Playlist(this.name, this.imageUrl, this.backgroundColor);

  Future<List<Song>> getVideosInfo();


  /*
  If the playlist has a reference url, for example a website in which the playlist
  is taken, override this method.
   */
  String? getReferenceUrl(){
    return null;
  }
}
