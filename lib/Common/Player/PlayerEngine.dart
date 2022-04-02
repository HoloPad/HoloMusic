import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'Song.dart';

enum RepetitionState { Off, OneItem, AllItems }

class PlayerEngine {
  static late AudioPlayer player;
  static late List<Song> _mainPlaylist;
  static late List<Song> _history;
  static Song? _currentPlaying;
  static final ValueNotifier<Song?> _currentVideoHandlerListenable =
      ValueNotifier(null);
  static final ValueNotifier<bool> _hasNextStream = ValueNotifier(true);
  static final ValueNotifier<bool> _isShuffleEnable = ValueNotifier(false);
  static bool _isPlaylistLooping = false;
  static final ValueNotifier<RepetitionState> _repetitionState =
      ValueNotifier(RepetitionState.Off);
  static bool canSkip = true;

  static void initialize() {
    PlayerEngine.player = AudioPlayer();
    PlayerEngine._mainPlaylist = List.empty(growable: true);
    PlayerEngine._history = List.empty(growable: true);
    PlayerEngine.player.playerStateStream.listen((event) {
      switch (event.processingState) {
        case ProcessingState.completed:
          onTrackEnd();
          break;
        case ProcessingState.ready:
          canSkip = true;
          break;
        default:
          break;
      }
    });
  }

  static void onTrackEnd() async {
    if (_mainPlaylist.isNotEmpty ||
        (_currentPlaying != null && _currentPlaying!.isAPlaylist())) {
      PlayerEngine.playNextSong(nextOnQueue: true);
    } else {
      await PlayerEngine.player.pause();
      await PlayerEngine.player.load();
    }
  }

  static Future play(Song source, {bool play = true}) async {
    final audioSource = AudioSource.uri(await source.getAudioUri(),
        tag: MediaItem(
          id: source.id,
          title: source.title,
          artUri: source.getThumbnailUri(),
        ));

    await PlayerEngine.player.pause();
    await PlayerEngine.player.setAudioSource(audioSource);
    await PlayerEngine.player.seek(Duration.zero);
    _currentVideoHandlerListenable.value = source;
    _history.add(source);
    _currentPlaying = source;
    if (play) await PlayerEngine.player.play();
    _hasNextStream.value = await hasNext();

    //Pre-load the next-song
    _currentPlaying?.getNext();
  }

  static Future playNextSong({bool nextOnQueue = false}) async {
    if (!PlayerEngine.canSkip) {
      return;
    }
    PlayerEngine.canSkip = false;
    //Check in the queue
    if (_mainPlaylist.isNotEmpty) {
      await play(_mainPlaylist.removeAt(0));
      return;
    }

    //if belong to a playlist
    if (_currentPlaying != null && _currentPlaying!.isAPlaylist()) {
      Song? nextSong;

      if (_isShuffleEnable.value && nextOnQueue) {
        final songs = await _currentPlaying!.playlist!.getSongs();
        final rnd = Random();
        do {
          nextSong = songs.elementAt(rnd.nextInt(songs.length));
        } while (nextSong.id == _currentPlaying?.id);
      } else if (await _currentPlaying!.hasNext()) {
        //Get the next song
        nextSong = await _currentPlaying?.getNext();
      } else if (_isPlaylistLooping) {
        //Get the first song
        nextSong = await _currentPlaying?.getFirstOfThePlaylist();
      }
      //Play the song
      if (nextSong != null) {
        await PlayerEngine.play(nextSong);
        await PlayerEngine.player.play();
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

  static Future playPreviousSong() async {
    Song? previousSong;
    if (_history.isNotEmpty) {
      //Search in history the previous different from the current
      final currentIndex =
          _history.indexWhere((element) => element.id == _currentPlaying?.id);
      if (currentIndex - 1 >= 0) {
        previousSong = _history.elementAt(currentIndex - 1);
      }
    }
    if (previousSong == null) {
      //Search on playlist
      final songs = await _currentPlaying?.playlist?.getSongs();
      if (songs == null) {
        return;
      }
      final currentIndex =
          songs.indexWhere((element) => element.id == _currentPlaying?.id);
      if (currentIndex - 1 < 0) {
        return;
      }
      previousSong = songs.elementAt(currentIndex - 1);
    }
    PlayerEngine.play(previousSong);
  }

  static ValueNotifier<Song?> getCurrentVideoHandlerPlaying() {
    return _currentVideoHandlerListenable;
  }

  static void addSongToQueue(Song source) async {
    _mainPlaylist.add(source);
    source.downloadStream();
    _hasNextStream.value = await hasNext();
  }

  static void toggleShuffle() {
    _isShuffleEnable.value = !_isShuffleEnable.value;
  }

  static Future<bool> hasNext() async {
    return _mainPlaylist.isNotEmpty ||
        (_currentPlaying != null && await _currentPlaying!.hasNext());
  }

  static ValueNotifier<bool> hasNextStream() {
    return _hasNextStream;
  }

  static ValueNotifier<bool> isShuffleEnabled() {
    return _isShuffleEnable;
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
