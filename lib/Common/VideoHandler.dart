import 'dart:async';
import 'dart:io';
import 'package:holomusic/Common/PlayerEngine.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as YtExplode;
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;

enum LoadingState { initialized, loading, loaded }

//Each video has this associated object
class VideoHandler {
  late YtExplode.Video video;
  late YtExplode.YoutubeExplode _yt;
  late Future<Uri> _onlineStream;
  Future<Uri>? _offlineStream;
  bool _offlineCompleted = false;

  VideoHandler(this.video, {bool preload = false}) {
    _yt = YtExplode.YoutubeExplode();
    _onlineStream = _getOnlineStream();
    print("Video preload " + preload.toString());
    if (preload) {
      _onlineStream.whenComplete(() {
        _offlineStream = _getOfflineStream();
        _offlineStream?.whenComplete(() => _offlineCompleted = true);
      });
    }
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
}
