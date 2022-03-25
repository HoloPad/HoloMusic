import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'VideoHandler.dart';

enum RepetitionState { Off, OneItem, AllItems }

class PlayerEngine {
  static late AudioPlayer player;
  static late List<VideoHandler> _mainPlaylist;
  static late List<VideoHandler> _history;
  static VideoHandler? _currentPlaying;
  static final ValueNotifier<VideoHandler?> _currentVideoHandlerListenable =
      ValueNotifier(null);
  static final ValueNotifier<bool> _hasNextStream = ValueNotifier(true);
  static bool _isPlaylistLooping = false;
  static final ValueNotifier<RepetitionState> _repetitionState =
      ValueNotifier(RepetitionState.Off);

  static void initialize() {
    PlayerEngine.player = AudioPlayer();
    PlayerEngine._mainPlaylist = List.empty(growable: true);
    PlayerEngine._history = List.empty(growable: true);
    PlayerEngine.player.playerStateStream.listen((event) {
      switch (event.processingState) {
        case ProcessingState.completed:
          onTrackEnd();
          break;
        default:
          break;
      }
    });
  }

  static void onTrackEnd() async {
    if (_mainPlaylist.isNotEmpty ||
        (_currentPlaying != null && _currentPlaying!.isAPlaylist())) {
      PlayerEngine.playNextSong();
    } else {
      await PlayerEngine.player.pause();
      await PlayerEngine.player.load();
    }
  }

  static Future play(VideoHandler source, {bool play = true}) async {
    final futureAudioSource = await source.getAudioSource();
    final audioSource = AudioSource.uri(futureAudioSource,
        tag: MediaItem(
            id: source.video.id.value,
            title: source.video.title,
            artUri: Uri.parse(source.video.thumbnails.lowResUrl),
            duration: source.video.duration));
    await PlayerEngine.player.pause();
    await PlayerEngine.player.setAudioSource(audioSource);
    _currentVideoHandlerListenable.value = source;
    _history.add(source);
    _currentPlaying = source;
    if (play) await PlayerEngine.player.play();
    _hasNextStream.value = await hasNext();
  }

  static Future playNextSong() async {
    //Check in the queue
    if (_mainPlaylist.isNotEmpty) {
      await play(_mainPlaylist.removeAt(0));
      return;
    }

    //if belong to a playlist
    if (_currentPlaying != null && _currentPlaying!.isAPlaylist()) {
      VideoHandler? nextSong;

      if (await _currentPlaying!.hasNext()) {
        //Get the next song
        nextSong = await _currentPlaying?.getNext();
      } else if (_isPlaylistLooping) {
        //Get the first song
        nextSong = await _currentPlaying?.getFirstOfThePlaylist();
      }
      //Play the song
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

  static ValueNotifier<VideoHandler?> getCurrentVideoHandlerPlaying() {
    return _currentVideoHandlerListenable;
  }

  static void addSongToQueue(VideoHandler source) async {
    _mainPlaylist.add(source);
    _hasNextStream.value = await hasNext();
  }

  static Future<bool> hasNext() async {
    return _mainPlaylist.isNotEmpty ||
        (_currentPlaying != null && await _currentPlaying!.hasNext());
  }

  static ValueNotifier<bool> hasNextStream() {
    return _hasNextStream;
  }

  static void setPlaylistLoop(bool isLoop) {
    _isPlaylistLooping = isLoop;
  }

  static void setRepetitionState(RepetitionState state) {
    _repetitionState.value = state;
    switch (_repetitionState.value) {
      case RepetitionState.Off:
        PlayerEngine.player.setLoopMode(LoopMode.off);
        PlayerEngine.setPlaylistLoop(false);
        break;
      case RepetitionState.OneItem:
        PlayerEngine.player.setLoopMode(LoopMode.one);
        PlayerEngine.setPlaylistLoop(false);
        break;
      case RepetitionState.AllItems:
        PlayerEngine.player.setLoopMode(LoopMode.off);
        PlayerEngine.setPlaylistLoop(true);
        break;
    }
  }

  static ValueNotifier<RepetitionState> getRepetitionStateValueNotifier() {
    return _repetitionState;
  }
}
