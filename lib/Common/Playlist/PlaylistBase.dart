import 'dart:ui';

import 'package:flutter/material.dart';

import '../Player/Song.dart';

//All playlist must extends the class

abstract class PlaylistBase {
  late ImageProvider imageProvider;
  late String name;
  late Color? backgroundColor;
  bool isOnline=true;

  PlaylistBase(this.name, this.imageProvider, this.backgroundColor);

  Future<List<Song>> getVideosInfo();
  Future<ImageProvider> getImageProvider(){
    return Future.value(imageProvider);
  }
  /*
  If the playlist has a reference url, for example a website in which the playlist
  is taken, override this method.
   */
  String? getReferenceUrl(){
    return null;
  }

  Future delete() async{

  }
}
