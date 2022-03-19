import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:holomusic/Common/VideoHandler.dart';
import 'package:holomusic/Views/Player/PlayerView.dart';
import 'package:just_audio/just_audio.dart';
import 'package:holomusic/Common/PlayerEngine.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class PlayBar extends StatefulWidget {
  final VideoHandler handler;
  static bool isVisible = false;

  const PlayBar({Key? key, required this.handler}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PlayBarState(handler);
}

class _PlayBarState extends State<PlayBar> {
  VideoHandler handler;

  _PlayBarState(this.handler) {
    PlayBar.isVisible = true;
  }

  final playIcon = const Icon(
    Icons.play_circle_outline,
    size: 40,
    color: Colors.black,
  );

  final pauseIcon = const Icon(
    Icons.pause_circle_outline,
    size: 40,
    color: Colors.black,
  );

  final _titleStyle = const TextStyle(
    fontSize: 15,
  );

  void _openPlayerView() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => PlayerView(handler)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.black12,
        child: Row(
          children: [
            TextButton(
                onPressed: _openPlayerView,
                child: const Icon(
                  Icons.arrow_drop_up,
                  size: 40,
                  color: Colors.black,
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
                  PlayerEngine.playNextSong();
                },
                child: const Icon(
                  Icons.skip_next,
                  size: 40,
                  color: Colors.black,
                )),
          ],
        ));
  }
}
