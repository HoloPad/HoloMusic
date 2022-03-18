import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:holomusic/Common/VideoHandler.dart';
import 'package:holomusic/Views/Player/PlayerView.dart';
import 'package:just_audio/just_audio.dart';

class PlayBar extends StatefulWidget {
  final VideoHandler handler;
  static bool isVisible = false;

  const PlayBar({Key? key, required this.handler}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PlayBarState(handler);
}

class _PlayBarState extends State<PlayBar> {
  VideoHandler handler;

  _PlayBarState(this.handler){
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

  final titleStyle = const TextStyle(
    fontSize: 15,
  );

  void _toggle() {
    handler.toggle();
  }

  void _openPlayerView() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => PlayerView(handler)));
  }

  @override
  void dispose() {
    print("dispose bar");
    super.dispose();
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
                child: Text(
              widget.handler.video.title,
              style: titleStyle,
              textAlign: TextAlign.center,
            )),
            TextButton(
                onPressed: _toggle,
                child: TextButton(
                    onPressed: _toggle,
                    child: StreamBuilder<PlayerState>(
                        stream: VideoHandler.player.playerStateStream,
                        builder: (BuildContext context,
                            AsyncSnapshot<PlayerState> snapshot) {
                          if (snapshot.hasData && snapshot.data!.playing) {
                            return pauseIcon;
                          } else {
                            return playIcon;
                          }
                        }))),
            TextButton(
                onPressed: () {},
                child: const Icon(
                  Icons.skip_next,
                  size: 40,
                  color: Colors.black,
                )),
          ],
        ));
  }
}
