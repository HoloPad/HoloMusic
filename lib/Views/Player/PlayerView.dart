import 'package:flutter/material.dart';
import 'package:holomusic/Common/VideoHandler.dart';
import 'package:just_audio/just_audio.dart';

class PlayerView extends StatefulWidget {
  final VideoHandler handler;

  PlayerView(this.handler, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PlayerViewState(handler);
}

class _PlayerViewState extends State<PlayerView> {
  final VideoHandler _handler;
  bool updatePosition = false;

  _PlayerViewState(this._handler);

  final _titleStyle =
      const TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
  final playIcon = const Icon(
    Icons.play_circle_fill,
    size: 70,
    color: Colors.black,
  );
  final pauseIcon = const Icon(
    Icons.pause,
    size: 70,
    color: Colors.black,
  );

  void _toggle() {
    _handler.toggle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("HoloMusic"),
        ),
        body: Column(
          children: [
            Image(image: NetworkImage(_handler.video.thumbnails.highResUrl)),
            Text(
              _handler.video.title,
              style: _titleStyle,
            ),
            StreamBuilder<Duration>(
                stream: VideoHandler.player.positionStream,
                builder:
                    (BuildContext context, AsyncSnapshot<Duration> snapshot) {
                  return Slider(
                    value: snapshot.hasData
                        ? snapshot.data!.inSeconds.toDouble()
                        : 0,
                    min: 0,
                    max: VideoHandler.player.duration!.inSeconds.toDouble(),
                    onChanged: (d) {
                      VideoHandler.player.seek(Duration(seconds: d.toInt()));
                    },
                  );
                }),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: () => {},
                    child: const Icon(
                      Icons.fast_rewind,
                      size: 40,
                      color: Colors.black,
                    )),
                TextButton(
                    onPressed: _toggle,
                    child: StreamBuilder<PlayerState>(
                        stream: VideoHandler.player.playerStateStream,
                        builder: (BuildContext context,
                            AsyncSnapshot<PlayerState> snapshot) {
                          if (snapshot.hasData &&
                              snapshot.data!.playing &&
                              !widget.handler.isEnd()) {
                            return pauseIcon;
                          } else {
                            return playIcon;
                          }
                        })),
                TextButton(
                    onPressed: () => {},
                    child: const Icon(
                      Icons.fast_forward,
                      size: 40,
                      color: Colors.black,
                    )),
              ],
            )
          ],
        ));
  }
}
