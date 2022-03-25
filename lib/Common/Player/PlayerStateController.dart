import 'package:flutter/foundation.dart';

class MyPlayerState {
  static int loading = 1 << 0;
  static int play = 1 << 1;
  static int visible = 1 << 2;
}

class PlayerStateController {
  final ValueNotifier<int> _valueListenable = ValueNotifier(0);

  void isLoading(bool isLoading) {
    if (isLoading) {
      _valueListenable.value |= MyPlayerState.loading;
    } else {
      _valueListenable.value &= (~MyPlayerState.loading);
    }
  }

  void isPlaying(bool isPlaying) {
    if (isPlaying) {
      _valueListenable.value |= MyPlayerState.play;
    } else {
      _valueListenable.value &= (~MyPlayerState.play);
    }
  }

  void isVisible(bool isVisible) {
    if (isVisible) {
      _valueListenable.value |= MyPlayerState.visible;
    } else {
      _valueListenable.value &= (~MyPlayerState.visible);
    }
  }

  ValueNotifier<int> getPlayerStateValueNotifier() {
    return _valueListenable;
  }
}
