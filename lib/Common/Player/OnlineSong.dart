import 'dart:async';
import 'dart:io';

import 'package:holomusic/Common/Player/OfflineSong.dart';
import 'package:holomusic/Common/Player/Song.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as YtExplode;

import '../Playlist/PlaylistBase.dart';
import '../Storage/PlaylistStorage.dart';

enum LoadingState { initialized, loading, loaded }

//Each video has this associated object
class OnlineSong extends Song {
  YtExplode.Video? video;

  late YtExplode.YoutubeExplode _yt;
  Future<Uri>? _onlineStream;
  Future<Uri>? _offlineStream;
  bool _offlineCompleted = false;
  OnlineSong? _nextSong;

  OnlineSong(YtExplode.Video video,
      {bool preload = false, PlaylistBase? playlist})
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
      {bool preload = false, PlaylistBase? playlist})
      : super(id, title, thumbnail) {
    _yt = YtExplode.YoutubeExplode();
    this.playlist = playlist;

    if (preload) {
      downloadStream();
    }
  }

  @override
  factory OnlineSong.fromJson(Map<String, dynamic> json,{PlaylistBase? playlist}) {
    final onlineSong = OnlineSong.lazy(json['id'], json['title'], json['thumbnail'], playlist: playlist);
    onlineSong.setSongState(SongState.values.elementAt(json['state']));
    return onlineSong;
  }

  @override
  Map<String, dynamic> toJson() {
    return {"id": id,
      "title": title,
      "thumbnail": thumbnail,
      "online": true,
      "state":stateNotifier.value.index
    };
  }

  static Future<OnlineSong> createFromId(String id,
      {PlaylistBase? playlist}) async {
    final instance = YtExplode.YoutubeExplode();
    final video = await instance.videos.get(YtExplode.VideoId(id));
    return OnlineSong(video, playlist: playlist);
  }

  static Future<OnlineSong> createFromUrl(String url,
      {PlaylistBase? playlist}) async {
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
    final listVideos = await playlist?.getSongs();
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
    if (_nextSong != null) {
      return _nextSong!;
    }
    final currentIndex = await getCurrentIndexInsideAPlaylist();
    final listVideos = await playlist?.getSongs();
    if (listVideos != null && currentIndex + 1 < listVideos.length) {
      //there is a next element
      final nextVideo = listVideos.elementAt(currentIndex + 1);
      _nextSong = await
          OnlineSong.createFromId(nextVideo.id, playlist: playlist);
      _nextSong?.preloadStream();
      return _nextSong;
    }
    return null;
  }

  @override
  Future<OnlineSong?> getFirstOfThePlaylist() async {
    if (isAPlaylist()) {
      final videoList = await playlist?.getSongs();
      final firstVideo = videoList?.first;
      if (firstVideo != null) {
        return await OnlineSong.createFromId(firstVideo.id, playlist: playlist);
      }
    }
    return null;
  }

  @override
  Future saveSong() async {
    if (!await isOnline()) {
      return;
    }
    try {
      setSongState(SongState.downloading);
      final docDirectory = await getApplicationDocumentsDirectory();
      final path = docDirectory.path +
          Platform.pathSeparator +
          "holomusic" +
          Platform.pathSeparator +
          "offline";
      final offlineDirectory = Directory(path);
      offlineDirectory.createSync(recursive: true);

      final _video = await getVideo();

      final imageResponse =
          await http.get(Uri.parse(_video.thumbnails.highResUrl));
      final imageFile = File(offlineDirectory.path +
          Platform.pathSeparator +
          _video.id.value +
          ".jpg");
      imageFile.writeAsBytes(imageResponse.bodyBytes, flush: true);

      var songFile = File(offlineDirectory.path +
          Platform.pathSeparator +
          _video.id.value +
          ".webm");
      final manifest = await _yt.videos.streamsClient.getManifest(id);
      final streamInfo = manifest.audioOnly.withHighestBitrate();
      final stream = _yt.videos.streamsClient.get(streamInfo);
      var fileStream = songFile.openWrite();
      await stream.pipe(fileStream);
      // Close the file.
      await fileStream.flush();
      await fileStream.close();

      await db.collection(collectionName).doc(_video.id.value).set(
          {"title": title, "thumbnail": imageFile.path, "path": songFile.path});

      final offline = await OfflineSong.getById(id);
      if (offline != null) {
        PlaylistStorage.convertOnlineSongToOffline(this, offline);
      }
      setSongState(SongState.offline);
    } catch (_) {
      setSongState(SongState.errorOnDownloading);
    }
  }

  @override
  Future deleteSong() async {
    if (await isOnline()) {
      return;
    }
    final offlineSong = await OfflineSong.getById(id);
    await offlineSong?.deleteSong();
    setSongState(SongState.online);
  }
}
