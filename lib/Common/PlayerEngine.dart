import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:holomusic/Common/VideoHandler.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class PlayerEngine {
  static late AudioPlayer player;
  static late List<VideoHandler> _mainPlaylist;
  static late List<VideoHandler> _history;
  static VideoHandler? _currentPlaying;
  static final ValueNotifier<Video?> _valueListenable = ValueNotifier(null);

  static void initialize() {
    PlayerEngine.player = AudioPlayer();
    PlayerEngine._mainPlaylist = List.empty(growable: true);
    PlayerEngine._history = List.empty(growable: true);
    PlayerEngine.player.playerStateStream.listen((event) {
      if(event.processingState==ProcessingState.completed){
        _currentPlaying=null;
        playNextSong();
      }
    });
  }

  static void play(VideoHandler source) async {
    final audioSource = await source.getAudioSource();
    await PlayerEngine.player.stop();
    await PlayerEngine.player.setAudioSource(audioSource);
    _valueListenable.value=source.video;
    _history.add(source);
    _currentPlaying = source;
    await PlayerEngine.player.play();
  }



  static void playNextSong()  {
    if(_mainPlaylist.isNotEmpty){
      play(_mainPlaylist.removeLast());
    }
  }

  static void playPreviousSong()  {
    if(_history.isEmpty) {
      return;
    }
    final previousSong = _history.lastWhere((element) => element!=_currentPlaying);
    PlayerEngine.play(previousSong);
  }

  static ValueNotifier<Video?> getCurrentVideoPlaying(){
    return _valueListenable;
  }

  static void addSongToQueue(VideoHandler source) async {
    _mainPlaylist.add(source);
  }

}
