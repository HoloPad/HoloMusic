import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:holomusic/Common/Player/Song.dart';

class SongStateManager {
  static const initialState = SongState.online;
  static late HashMap<String, ValueNotifier<SongState>>? songsMap;

  static void init() {
    songsMap = HashMap();
  }

  static void setSongState(String id, SongState state) {
    songsMap![id] ??= ValueNotifier(initialState);
    songsMap![id]!.value = state;
  }

  static ValueNotifier<SongState> getSongState(String id) {
    songsMap![id] ??= ValueNotifier(initialState);
    return songsMap![id]!;
  }

  static void dismiss(){
    songsMap?.clear();
  }

  static bool isInitialized(){
    return songsMap!=null;
  }
}
