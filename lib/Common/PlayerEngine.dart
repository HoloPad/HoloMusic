import 'package:holomusic/Common/VideoHandler.dart';
import 'package:just_audio/just_audio.dart';

class PlayerEngine {
  static late AudioPlayer player;

  static void initialize() {
    PlayerEngine.player = AudioPlayer();
  }

  static void addSongAndPlay(AudioSource source) async {
    await PlayerEngine.player.stop();
    await PlayerEngine.player.setAudioSource(source);
    await PlayerEngine.player.play();
  }
}
