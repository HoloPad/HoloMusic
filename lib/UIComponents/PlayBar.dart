import 'package:flutter/material.dart';
import 'package:holomusic/Common/Player/PlayerEngine.dart';
import 'package:holomusic/Views/Player/PlayerView.dart';
import 'package:marquee_text/marquee_text.dart';

import '../Common/Notifications/LoadingNotification.dart';
import '../Common/Player/PlayerStateController.dart';
import '../Common/Player/VideoHandler.dart';

class PlayBar extends StatefulWidget {
  static bool isVisible = false;
  final ValueNotifier<int> playerState;

  const PlayBar(this.playerState, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PlayBarState();
}

class _PlayBarState extends State<PlayBar> {
  late PlayerView _playerView;

  _PlayBarState() {
    PlayBar.isVisible = true;
  }

  @override
  void initState() {
    _playerView = PlayerView(widget.playerState);
    _playerView.getRequestLoadingViewStream().listen((event) {
      LoadingNotification(event).dispatch(context);
    });
    super.initState();
  }

  final playIcon = const Icon(
    Icons.play_circle_outline,
    size: 40,
    color: Colors.white,
  );

  final pauseIcon = const Icon(
    Icons.pause_circle_outline,
    size: 40,
    color: Colors.white,
  );

  final _titleStyle = const TextStyle(fontSize: 15, color: Colors.white);

  void _openPlayerView() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => _playerView));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: const Color.fromRGBO(34, 35, 39, 1.0),
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  TextButton(
                      onPressed: _openPlayerView,
                      child: const Icon(
                        Icons.arrow_drop_up,
                        size: 40,
                        color: Colors.white,
                      )),
                  Expanded(
                      child: ValueListenableBuilder<VideoHandler?>(
                          valueListenable:
                              PlayerEngine.getCurrentVideoHandlerPlaying(),
                          builder: (context, value, _) {
                            return MarqueeText(
                              text: TextSpan(
                                  text:
                                      value == null ? "..." : value.video.title,
                                  style: _titleStyle),
                              textAlign: TextAlign.center,
                              speed: 25,
                            );
                          })),
                  TextButton(
                      onPressed: () => PlayerEngine.toggle(),
                      child: ValueListenableBuilder<int>(
                          valueListenable: widget.playerState,
                          builder: (context, data, child) {
                            if (data & MyPlayerState.play == 0) {
                              return playIcon;
                            } else {
                              return pauseIcon;
                            }
                          })),
                  ValueListenableBuilder<bool>(
                    valueListenable: PlayerEngine.hasNextStream(),
                    builder: (_, value, __) {
                      return TextButton(
                          onPressed: () {
                            if (value) {
                              LoadingNotification(true).dispatch(context);
                              PlayerEngine.playNextSong();
                            }
                          },
                          child: Icon(
                            Icons.skip_next,
                            size: 40,
                            color:
                                Color.fromRGBO(255, 255, 255, value ? 1 : 0.5),
                          ));
                    },
                  )
                ],
              ),
              Container(
                height: 2,
                color: const Color.fromRGBO(0, 0, 0, 0.5),
              )
            ]));
  }
}
