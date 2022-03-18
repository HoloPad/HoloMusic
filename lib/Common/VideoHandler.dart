import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as YtExplode;
import 'package:just_audio/just_audio.dart';

class VideoHandler {
  YtExplode.Video video;
  late YtExplode.YoutubeExplode _yt;
  static late AudioPlayer player;
  bool autoStart;

  VideoHandler(this.video, {this.autoStart = false}) {
    _yt = YtExplode.YoutubeExplode();
    _downloadSong().then((value) {
      player.setFilePath(value);
      player.play();
    });
  }

  void play() {
    player.play();
  }

  void pause() {
    player.pause();
  }

  void toggle() {
    if (isPlaying()) {
      pause();
    } else {
      play();
    }
  }

  void dispose() {
    player.dispose();
  }

  void setPosition(Duration duration) {
    player.seek(duration);
  }

  int getPosition() {
    return player.position.inSeconds;
  }

  bool isPlaying() {
    return player.playing;
  }

  Future<String> _downloadSong() async {
    Directory tempDir = await getApplicationDocumentsDirectory();
    var fileName = tempDir.path + "/file" + video.id.value + ".webm";
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
