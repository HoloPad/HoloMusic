import 'dart:async';
import 'dart:io';

import 'package:holomusic/Common/Notifications/DownloadNotification.dart';
import 'package:holomusic/Common/Player/OfflineSong.dart';
import 'package:holomusic/Common/Player/OnlineSong.dart';
import 'package:holomusic/Common/Playlist/PlaylistBase.dart' as MyPlaylist;
import 'package:holomusic/Common/Storage/PlaylistStorage.dart';
import 'package:http/http.dart' as http;
import 'package:localstore/localstore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

//Library used
//https://pub.dev/packages/localstore

class SongsStorage {
  static final _db = Localstore.instance;
  static const _collectionName = "holomusic";
  static late List<DownloadNotification> _currentElementsState;
  static late StreamController<List<DownloadNotification>> _stateStream;
  static bool _canDownload = true;

  static void init() async {
    _currentElementsState = await SongsStorage.getCurrentState();
    _stateStream = StreamController.broadcast();
  }

  static Future<OfflineSong?> saveSong(OnlineSong song) async {
    if (await SongsStorage.isSongStoredById(song.id)) {
      return SongsStorage.getSongById(song.id);
    }
    SongsStorage.updateState(song.id, DownloadState.downloading);
    try {
      print("downloading");
      final docDirectory = await getApplicationDocumentsDirectory();
      final path = docDirectory.path +
          Platform.pathSeparator +
          "holomusic" +
          Platform.pathSeparator +
          "offline";
      final offlineDirectory = Directory(path);
      offlineDirectory.createSync(recursive: true);

      final _video = await song.getVideo();

      final imageResponse =
          await http.get(Uri.parse(_video.thumbnails.highResUrl));
      final imageFile = File(offlineDirectory.path +
          Platform.pathSeparator +
          _video.id.value +
          ".jpg");
      imageFile.writeAsBytes(imageResponse.bodyBytes, flush: true);

      final _yt = YoutubeExplode();
      var songFile = File(offlineDirectory.path +
          Platform.pathSeparator +
          _video.id.value +
          ".webm");
      final manifest = await _yt.videos.streamsClient.getManifest(song.id);
      final streamInfo = manifest.audioOnly.withHighestBitrate();
      final stream = _yt.videos.streamsClient.get(streamInfo);
      var fileStream = songFile.openWrite();
      await stream.pipe(fileStream);
      // Close the file.
      await fileStream.flush();
      await fileStream.close();

      await _db.collection(_collectionName).doc(_video.id.value).set({
        "title": song.title,
        "thumbnail": imageFile.path,
        "path": songFile.path
      });
      SongsStorage.updateState(song.id, DownloadState.downloaded);
      final offline = await SongsStorage.getSongById(song.id);
      if (offline != null) {
        PlaylistStorage.convertOnlineSongToOffline(song, offline);
      }
      return offline;
    } catch (_) {
      SongsStorage.updateState(song.id, DownloadState.error);
      return null;
    }
  }

  static void stopDownload() {
    SongsStorage._canDownload = false;
  }

  static Future<List<OfflineSong>> getOfflineSongs() async {
    final document = _db.collection(_collectionName);

    final elements = (await document.get())?.entries;
    if (elements == null) {
      return List.empty();
    }

    List<OfflineSong> list = List.empty(growable: true);

    for (var key in elements) {
      String fullKey = key.key;
      String id =
          fullKey.substring(fullKey.lastIndexOf(Platform.pathSeparator) + 1);

      final title = key.value['title'];
      final thumbnail = key.value['thumbnail'];
      final path = key.value['path'];
      final video = OfflineSong(id, title, thumbnail, path);
      list.add(video);
    }
    return list;
  }

  static Future deleteSongById(String id) async {
    final song = await getSongById(id);
    if (song != null) {
      SongsStorage.deleteSong(song);
    }
  }

  static Future deleteSong(OfflineSong offlineSong) async {
    File songPath = File(offlineSong.filePath);
    songPath.deleteSync(recursive: true);
    if (offlineSong.thumbnail != null) {
      File imgPath = File(offlineSong.thumbnail!);
      imgPath.deleteSync(recursive: true);
    }
    await _db.collection(_collectionName).doc(offlineSong.id).delete();
    SongsStorage.updateState(offlineSong.id, DownloadState.nope);
    await PlaylistStorage.convertSongToOnline(offlineSong);
  }

  static Future<OfflineSong?> getSongById(String id) async {
    final element = await _db.collection(_collectionName).doc(id).get();
    if (element == null) {
      return null;
    }
    return OfflineSong(
        id, element['title'], element['thumbnail'], element['path']);
  }

  static Future<bool> isSongStoredById(String id) async {
    final element = await _db.collection(_collectionName).doc(id).get();
    return element != null;
  }

  static Future savePlaylist(MyPlaylist.PlaylistBase playlist) async {
    SongsStorage._canDownload = true;
    final songs = await playlist.getVideosInfo();

    for (var e in songs) {
      if (!(await SongsStorage.isSongStoredById(e.id))) {
        SongsStorage.updateState(e.id, DownloadState.waiting);
      }
    }

    for (var e in songs) {
      if (!(await SongsStorage.isSongStoredById(e.id))) {
        final onlineSong =
            await OnlineSong.createFromId(e.id, playlist: playlist);
        await SongsStorage.saveSong(onlineSong);
      }
      if (!SongsStorage._canDownload) {
        break;
      }
    }
  }

  static Future<bool> isAtLeastOneSaved(
      MyPlaylist.PlaylistBase playlist) async {
    final list = await playlist.getVideosInfo();
    final saved = await SongsStorage.getOfflineSongs();
    return list.any((e0) => saved.any((e1) => e1.id == e0.id));
  }

  static Future<bool> isAllSaved(MyPlaylist.PlaylistBase playlist) async {
    final list = await playlist.getVideosInfo();
    final saved = await SongsStorage.getOfflineSongs();
    return list.every((e0) => saved.any((e1) => e1.id == e0.id));
  }

  static Future deletePlaylist(MyPlaylist.PlaylistBase playlist) async {
    final songs = await playlist.getVideosInfo();
    for (var e in songs) {
      final offlineSong = await SongsStorage.getSongById(e.id);
      if (offlineSong != null) await SongsStorage.deleteSong(offlineSong);
    }
  }

  static updateState(String id, DownloadState state) {
    //Scan the current list
    bool found = false;
    for (var e in _currentElementsState) {
      if (e.id == id) {
        e.state = state;
        found = true;
      }
    }
    if (!found) {
      //If not found, add it
      _currentElementsState.add(DownloadNotification(id, state));
    }
    _stateStream.add(_currentElementsState);
  }

  static Future<List<DownloadNotification>> getCurrentState() async {
    return (await SongsStorage.getOfflineSongs())
        .map((e) => DownloadNotification(e.id, DownloadState.downloaded))
        .toList(growable: true);
  }

  static Stream<List<DownloadNotification>> getDownloadStream() {
    return _stateStream.stream;
  }
}
