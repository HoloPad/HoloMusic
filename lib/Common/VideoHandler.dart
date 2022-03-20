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

  VideoHandler(this.video) {
    _yt = YtExplode.YoutubeExplode();
    _audioSourceFuture = _getSongStream().then((value) {
      final source = AudioSource.uri(value);
      return source;
    });
  }

  Future<AudioSource> getAudioSource() {
    return _audioSourceFuture;
  }

  Future<Uri> _getSongStream() async {
    var manifest = await _yt.videos.streamsClient.getManifest(video.id);
    var streamInfo = manifest.audioOnly.withHighestBitrate();
    return streamInfo.url;
  }
}
