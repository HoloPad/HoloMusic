import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:holomusic/Common/DataFetcher/Providers/Playlist.dart'
    as MyPlaylist;
import 'package:holomusic/Common/VideoHandler.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class PlayerEngine {
  static late AudioPlayer player;
  static late List<VideoHandler> _mainPlaylist;
  static late List<VideoHandler> _history;
  static VideoHandler? _currentPlaying;
  static final ValueNotifier<Video?> _valueListenable = ValueNotifier(null);
  static MyPlaylist.Playlist? _currentPlaylist;

  static void initialize() {
    PlayerEngine.player = AudioPlayer();
    PlayerEngine._mainPlaylist = List.empty(growable: true);
    PlayerEngine._history = List.empty(growable: true);
    PlayerEngine.player.playerStateStream.listen((event) {
      switch (event.processingState) {
        case ProcessingState.completed:
          onTrackEnd();
          break;
      }
    });
  }

  static void setCurrentPlaylist(MyPlaylist.Playlist playlist) {
    PlayerEngine._currentPlaylist = playlist;
  }

  static void dismissPlaylist() {
    PlayerEngine._currentPlaylist = null;
  }

  static void onTrackEnd() async {
    if (_mainPlaylist.isNotEmpty || (_currentPlaying != null && _currentPlaying!.isAPlaylist()) ) {
      PlayerEngine.playNextSong();
    } else {
      await PlayerEngine.player.pause();
      await PlayerEngine.player.load();
    }
  }

  static Future play(VideoHandler source, {bool play = true}) async {
    final futureAudioSource = await source.getAudioSource();
    final audioSource = AudioSource.uri(futureAudioSource);
    await PlayerEngine.player.pause();
    await PlayerEngine.player.setAudioSource(audioSource);
    _valueListenable.value = source.video;
    _history.add(source);
    _currentPlaying = source;
    if (play) await PlayerEngine.player.play();
  }

  static Future playNextSong() async {
    //Check in the queue
    if (_mainPlaylist.isNotEmpty) {
      await play(_mainPlaylist.removeAt(0));
      return;
    }

    //if belong to a playlist
    if (_currentPlaying != null && _currentPlaying!.isAPlaylist()) {
      //Get the next song
      final nextSong = await _currentPlaying?.getNext();
      if (nextSong != null) {
        await PlayerEngine.play(nextSong);
      }
    }
  }

  static void toggle() {
    if (PlayerEngine.player.playing) {
      PlayerEngine.player.pause();
    } else {
      PlayerEngine.player.play();
    }
  }

  static void playPreviousSong() {
    if (_history.isEmpty) {
      return;
    }
    final previousSong =
        _history.lastWhere((element) => element != _currentPlaying);
    PlayerEngine.play(previousSong);
  }

  static ValueNotifier<Video?> getCurrentVideoPlaying() {
    return _valueListenable;
  }

  static void addSongToQueue(VideoHandler source) async {
    _mainPlaylist.add(source);
  }
}
