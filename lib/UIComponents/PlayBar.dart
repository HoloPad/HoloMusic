import 'package:flutter/material.dart';
import 'package:holomusic/Common/PlayerEngine.dart';
import 'package:holomusic/Views/Player/PlayerView.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../Common/LoadingNotification.dart';

class PlayBar extends StatefulWidget {
  static bool isVisible = false;
  final Stream<bool> showLoading;

  const PlayBar(this.showLoading, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PlayBarState();
}

class _PlayBarState extends State<PlayBar> {
  _PlayBarState() {
    PlayBar.isVisible = true;
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
        context,
        MaterialPageRoute(
            builder: (context) => PlayerView(widget.showLoading)));
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
                children: [
                  TextButton(
                      onPressed: _openPlayerView,
                      child: const Icon(
                        Icons.arrow_drop_up,
                        size: 40,
                        color: Colors.white,
                      )),
                  Expanded(
                    child: ValueListenableBuilder<Video?>(
                        valueListenable: PlayerEngine.getCurrentVideoPlaying(),
                        builder: (context, value, _) {
                          return Text(
                            value == null ? "..." : value.title,
                            style: _titleStyle,
                            textAlign: TextAlign.center,
                          );
                        }),
                  ),
                  TextButton(
                      onPressed: () => PlayerEngine.toggle(),
                      child: StreamBuilder<PlayerState>(
                          stream: PlayerEngine.player.playerStateStream,
                          builder: (BuildContext context,
                              AsyncSnapshot<PlayerState> snapshot) {
                            if (snapshot.hasData &&
                                snapshot.data!.playing &&
                                snapshot.data!.processingState !=
                                    ProcessingState.completed) {
                              return pauseIcon;
                            } else {
                              return playIcon;
                            }
                          })),
                  TextButton(
                      onPressed: () {
                        LoadingNotification(true).dispatch(context);
                        PlayerEngine.playNextSong();
                      },
                      child: const Icon(
                        Icons.skip_next,
                        size: 40,
                        color: Colors.white,
                      )),
                ],
              ),
              Container(
                height: 2,
                color: const Color.fromRGBO(0, 0, 0, 0.5),
              )
            ]));
  }
}
