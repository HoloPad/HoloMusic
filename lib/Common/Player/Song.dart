import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:holomusic/Common/Player/OfflineSong.dart';
import 'package:holomusic/Common/Player/OnlineSong.dart';
import 'package:holomusic/Common/Playlist/PlaylistBase.dart';
import 'package:localstore/localstore.dart';

enum SongState { online, offline, downloading, errorOnDownloading }

abstract class Song {
  PlaylistBase? playlist;
  String id;
  String title;
  String? thumbnail;
  final db = Localstore.instance;
  final collectionName = "holomusic";

  ValueNotifier<SongState> stateNotifier=ValueNotifier(SongState.online);

  Song(this.id, this.title, this.thumbnail, {this.playlist}) {
    isOnline().then((res) {
      stateNotifier.value = res ? SongState.online : SongState.offline;
    });

  }

  Future<Uri> getAudioUri();

  Future<Song?> getNext();

  Future<Song?> getFirstOfThePlaylist();

  Future saveSong();

  Future deleteSong();

  factory Song.fromJson(Map<String, dynamic> json, {PlaylistBase? playlistBase}) {
    if (json['online'] == true) {
      return OnlineSong.fromJson(json,playlist: playlistBase);
    } else {
      return OfflineSong.fromJson(json,playlistBase: playlistBase);
    }
  }

  Map<String, dynamic> toJson();

  bool isAPlaylist() {
    return playlist != null;
  }


  Future<bool> hasNext() async {
    if (isAPlaylist()) {
      final next = await getNext();
      return next != null;
    } else {
      return false;
    }
  }

  //If you want to load lazy staff, call this method
  Future preloadStream() async {}

  Future downloadStream() async {}

  Uri? getThumbnailUri() {
    if (thumbnail != null) {
      if (thumbnail?.contains("http") ?? false) {
        return Uri.tryParse(thumbnail!);
      } else {
        File file = File(thumbnail!);
        return file.uri;
      }
    }
    return null;
  }

  ImageProvider getThumbnailImageAsset() {
    if (thumbnail != null) {
      bool isUrl = Uri.tryParse(thumbnail!)?.host.isNotEmpty ?? false;
      if (isUrl) {
        return NetworkImage(thumbnail!);
      } else {
        final file = File(thumbnail!);
        return FileImage(file);
      }
    } else {
      return const AssetImage("resources/png/fake_thumbnail.png");
    }
  }

  Future<bool> isOnline() async {
    final element = await db.collection(collectionName).doc(id).get();
    return element == null;
  }

  ValueNotifier<SongState> getStateNotifier() {
    return stateNotifier;
  }
}
