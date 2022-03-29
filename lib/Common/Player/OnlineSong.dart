import 'dart:async';
import 'dart:io';

import 'package:holomusic/Common/Player/Song.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as YtExplode;

import '../Playlist/Providers/Playlist.dart';

enum LoadingState { initialized, loading, loaded }

//Each video has this associated object
class OnlineSong extends Song {
  YtExplode.Video? video;

  late YtExplode.YoutubeExplode _yt;
  Future<Uri>? _onlineStream;
  Future<Uri>? _offlineStream;
  bool _offlineCompleted = false;
  Future<OnlineSong?>? _nextSongFuture;

  OnlineSong(YtExplode.Video video, {bool preload = false, Playlist? playlist})
      : super(video.id.value, video.title, video.thumbnails.highResUrl) {
    _yt = YtExplode.YoutubeExplode();

    this.video = video;
    this.playlist = playlist;

    //preloadStream();
    if (preload) {
      downloadStream();
    }
  }

  OnlineSong.lazy(String id, String title, String? thumbnail,
      {bool preload = false, Playlist? playlist})
      : super(id, title, thumbnail) {
    _yt = YtExplode.YoutubeExplode();
    this.playlist = playlist;

    if (preload) {
      downloadStream();
    }
  }

  static Future<OnlineSong> createFromId(String id,
      {Playlist? playlist}) async {
    final instance = YtExplode.YoutubeExplode();
    final video = await instance.videos.get(YtExplode.VideoId(id));
    return OnlineSong(video, playlist: playlist);
  }

  static Future<OnlineSong> createFromUrl(String url,
      {Playlist? playlist}) async {
    final instance = YtExplode.YoutubeExplode();
    final video = await instance.videos.get(url);
    return OnlineSong(video, playlist: playlist);
  }

  Future<YtExplode.Video> getVideo() async {
    video ??= await _yt.videos.get(id);
    return video!;
  }

  //Call this method when you really need the track.
  //If the track was download, it returns the offline Uri, otherwise the online Uri
  //Obviously the behaviours of this function depends by the preload parameter of the constructor.
  @override
  Future<Uri> getAudioUri() {
    if (_offlineCompleted && _offlineStream != null) {
      return _offlineStream!;
    } else {
      return _getOnlineStream();
      //return _onlineStream!;
    }
  }

  Future<Uri> _getOnlineStream() async {
    final _video = await getVideo();
    var manifest = await _yt.videos.streamsClient.getManifest(_video.id);
    var streamInfo = manifest.audioOnly.withHighestBitrate();
    return streamInfo.url;
  }

  Future<Uri> _getOfflineStream() async {
    final _video = await getVideo();
    //Create directory
    Directory tempDir = await getTemporaryDirectory();
    var folderPath = tempDir.path +
        Platform.pathSeparator +
        "holomusic" +
        Platform.pathSeparator;
    print("Preloading");
    await Directory(folderPath).create(recursive: true);
    var fileName = folderPath + _video.id.value + ".webm";
    var file = File(fileName);
    print(file.path);
    //Downloading
    var manifest = await _yt.videos.streamsClient.getManifest(_video.id);
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
    final _video = await getVideo();
    final listVideos = await playlist?.getVideosInfo();
    return listVideos?.indexWhere((element) => element.id == _video.id.value) ??
        -1;
  }

  @override
  Future preloadStream() async {
    _onlineStream = _getOnlineStream();
  }

  @override
  Future downloadStream() async {
    _onlineStream ??= _getOnlineStream();
    _onlineStream?.whenComplete(() {
      _offlineStream = _getOfflineStream();
      _offlineStream?.whenComplete(() => _offlineCompleted = true);
    });
  }

  @override
  Future<OnlineSong?> getNext() async {
    if (_nextSongFuture != null) {
      return _nextSongFuture!;
    }
    final currentIndex = await getCurrentIndexInsideAPlaylist();
    final listVideos = await playlist?.getVideosInfo();
    if (listVideos != null && currentIndex + 1 < listVideos.length) {
      //there is a next element
      final nextVideo = listVideos.elementAt(currentIndex + 1);
      _nextSongFuture =
          OnlineSong.createFromId(nextVideo.id, playlist: playlist);
      return _nextSongFuture;
    }
    return null;
  }

  @override
  Future<OnlineSong?> getFirstOfThePlaylist() async {
    if (isAPlaylist()) {
      final videoList = await playlist?.getVideosInfo();
      final firstVideo = videoList?.first;
      if (firstVideo != null) {
        return await OnlineSong.createFromId(firstVideo.id, playlist: playlist);
      }
    }
    return null;
  }

  @override
  bool isOnline() {
    return true;
  }
}