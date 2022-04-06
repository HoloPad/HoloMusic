import 'dart:convert';

import 'package:android_long_task/android_long_task.dart';

import '../Player/Song.dart';

class SharedDownloadData extends ServiceData {
  List<String> songs = List.empty();
  int processingIndex = 0;
  SongState currentProcessingState = SongState.online;

  @override
  String get notificationTitle => "Playlist download";

  @override
  String get notificationDescription =>
      "Download " +
      (processingIndex + 1).toString() +
      "/" +
      songs.length.toString();

  String toJson() {
    var map = {
      'progress': processingIndex,
      "songs": songs,
      "currState": currentProcessingState.index
    };
    return jsonEncode(map);
  }

  static SharedDownloadData fromJson(Map<String, dynamic> json) {
    SharedDownloadData obj = SharedDownloadData();
    obj.processingIndex = json['progress'] as int;
    obj.songs = List.from(json['songs']);
    obj.currentProcessingState =
        SongState.values.elementAt(json['currState'] as int);
    return obj;
  }

  String getProcessingId() {
    return songs.elementAt(processingIndex);
  }
}
