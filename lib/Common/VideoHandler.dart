import 'dart:async';
import 'dart:io';

import 'package:holomusic/Common/DataFetcher/Providers/Playlist.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as YtExplode;

enum LoadingState { initialized, loading, loaded }

//Each video has this associated object
class VideoHandler {
  late YtExplode.Video video;
  late YtExplode.YoutubeExplode _yt;
  late Future<Uri> _onlineStream;
  Future<Uri>? _offlineStream;
  bool _offlineCompleted = false;
  Playlist? playlist;
  Future<VideoHandler?>? _nextSongFuture;

  VideoHandler(this.video, {bool preload = false, this.playlist}) {
    _yt = YtExplode.YoutubeExplode();
    _onlineStream = _getOnlineStream();
    if (preload) {
      _onlineStream.whenComplete(() {
        _offlineStream = _getOfflineStream();
        _offlineStream?.whenComplete(() => _offlineCompleted = true);
      });
    }
    _nextSongFuture = getNext();
  }

  static Future<VideoHandler> createFromUrl(String url,
      {Playlist? playlist}) async {
    final instance = YtExplode.YoutubeExplode();
    final video = await instance.videos.get(url);
    return VideoHandler(video, playlist: playlist);
  }

  //Call this method when you really need the track.
  //If the track was download, it returns the offline Uri, otherwise the online Uri
  //Obviously the behaviours of this function depends by the preload parameter of the constructor.
  Future<Uri> getAudioSource() {
    if (_offlineCompleted && _offlineStream != null) {
      return _offlineStream!;
    } else {
      return _onlineStream;
    }
  }

  Future<Uri> _getOnlineStream() async {
    var manifest = await _yt.videos.streamsClient.getManifest(video.id);
    var streamInfo = manifest.audioOnly.withHighestBitrate();
    return streamInfo.url;
  }

  Future<Uri> _getOfflineStream() async {
    //Create directory
    Directory tempDir = await getTemporaryDirectory();
    var folderPath = tempDir.path +
        Platform.pathSeparator +
        "holomusic" +
        Platform.pathSeparator;
    print("Preloading");
    await Directory(folderPath).create(recursive: true);
    var fileName = folderPath + video.id.value + ".webm";
    var file = File(fileName);
    print(file.path);
    //Downloading
    var manifest = await _yt.videos.streamsClient.getManifest(video.id);
    var streamInfo = manifest.audioOnly.withHighestBitrate();
    var stream = _yt.videos.streamsClient.get(streamInfo);
    var fileStream = file.openWrite();
    await stream.pipe(fileStream);
    // Close the file.
    await fileStream.flush();
    await fileStream.close();
    print("Preloading completed");

    return file.uri;
  }

  //Returns -1 if not found
  Future<int> getCurrentIndexInsideAPlaylist() async {
    final listVideos = await playlist?.getVideosInfo();
    return listVideos?.indexWhere((element) => element.url == video.url) ?? -1;
  }

  bool isAPlaylist() {
    return playlist != null;
  }

  Future<VideoHandler?> getNext() async {
    if (_nextSongFuture != null) {
      return _nextSongFuture!;
    }
    final currentIndex = await getCurrentIndexInsideAPlaylist();
    final listVideos = await playlist?.getVideosInfo();
    if (listVideos != null && currentIndex + 1 < listVideos.length) {
      //there is a next element
      final nextVideo = listVideos.elementAt(currentIndex + 1);
      final nextVideoHandler =
          VideoHandler.createFromUrl(nextVideo.url, playlist: playlist);
      return nextVideoHandler;
    }
    return null;
  }

  Future<bool> hasNext() async {
    if (isAPlaylist()) {
      return await getNext() != null;
    } else {
      return false;
    }
  }

  Future<VideoHandler?> getFirstOfThePlaylist() async {
    if (isAPlaylist()) {
      final videoList = await playlist?.getVideosInfo();
      final firstVideo = videoList?.first;
      if (firstVideo != null) {
        return await VideoHandler.createFromUrl(firstVideo.url, playlist: playlist);
      }
    }
    return null;
  }
}
