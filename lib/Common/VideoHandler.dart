import 'dart:async';
import 'dart:io';
import 'package:holomusic/Common/PlayerEngine.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as YtExplode;
import 'package:just_audio/just_audio.dart';

enum LoadingState { initialized, loading, loaded }

//Each video has this associated object
class VideoHandler {
  late YtExplode.Video video;
  late YtExplode.YoutubeExplode _yt;
  late Future<AudioSource> _audioSourceFuture;

  final _loadingStreamController = StreamController<LoadingState>();

  VideoHandler(this.video) {
    _yt = YtExplode.YoutubeExplode();
    _loadingStreamController.add(LoadingState.loading);
    _audioSourceFuture = _downloadSong().then((value) {
      final source = AudioSource.uri(Uri.file(value));
      _onSourceLoaded();
      return source;
    });
  }

  void _onSourceLoaded() {
    //Code called when the song is loaded
    _loadingStreamController.add(LoadingState.loaded);
  }

  Stream<LoadingState> getVideoState() {
    return _loadingStreamController.stream;
  }

  Future<AudioSource> getAudioSource() {
    return _audioSourceFuture;
  }

  Future<String> _downloadSong() async {
    Directory tempDir = await getApplicationDocumentsDirectory();
    var folderPath = tempDir.path + Platform.pathSeparator + "holomusic" +
        Platform.pathSeparator;
    await Directory(folderPath).create(recursive: true);
    var fileName = folderPath + video.id.value + ".webm";
    var file = File(fileName);
    if (FileSystemEntity.typeSync(fileName) == FileSystemEntityType.notFound) {
      var manifest = await _yt.videos.streamsClient.getManifest(video.id);
      var streamInfo = manifest.audioOnly.withHighestBitrate();
      var stream = _yt.videos.streamsClient.get(streamInfo);
      print("Saved on " + fileName);
      var fileStream = file.openWrite();
      print("Saveing");
      await stream.pipe(fileStream);
      print("Saved");
      // Close the file.
      await fileStream.flush();
      await fileStream.close();
    } else {
      print("Cache used");
    }
    return fileName;
  }
}
