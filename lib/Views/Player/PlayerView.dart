import 'package:flutter/material.dart';
import 'package:holomusic/Common/PlayerEngine.dart';
import 'package:holomusic/Common/VideoHandler.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

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
    if (PlayerEngine.player.playing) {
      PlayerEngine.player.pause();
    } else {
      PlayerEngine.player.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("HoloMusic"),
        ),
        body: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                ValueListenableBuilder<Video?>(
                    valueListenable: PlayerEngine.getCurrentVideoPlaying(),
                    builder: (context, value, _) {
                      if (value != null) {
                        return Image(
                            height: 250,
                            image: NetworkImage(value.thumbnails.highResUrl));
                      } else {
                        //TODO implements a default image
                        return const Image(
                            height: 250,
                            image: NetworkImage(
                                "https://27mi124bz6zg1hqy6n192jkb-wpengine.netdna-ssl.com/wp-content/uploads/2019/10/Our-Top-10-Songs-About-School-768x569.png"));
                      }
                    }),
                const SizedBox(height: 20),
                ValueListenableBuilder<Video?>(
                    valueListenable: PlayerEngine.getCurrentVideoPlaying(),
                    builder: (context, value, _) {
                      return Text(
                        value == null ? "..." : value.title,
                        style: _titleStyle,
                        textAlign: TextAlign.center,
                      );
                    }),
                const SizedBox(height: 10),
                StreamBuilder<Duration>(
                    stream: PlayerEngine.player.positionStream,
                    builder: (BuildContext context,
                        AsyncSnapshot<Duration> snapshot) {
                      return Slider(
                        value: snapshot.hasData
                            ? snapshot.data!.inSeconds.toDouble()
                            : 0,
                        min: 0,
                        max: PlayerEngine.player.duration == null
                            ? 0
                            : PlayerEngine.player.duration!.inSeconds
                                .toDouble(),
                        onChanged: (d) {
                          PlayerEngine.player
                              .seek(Duration(seconds: d.toInt()));
                        },
                      );
                    }),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                        onPressed: () => PlayerEngine.playPreviousSong(),
                        child: const Icon(
                          Icons.skip_previous,
                          size: 40,
                          color: Colors.black,
                        )),
                    TextButton(
                        onPressed: _toggle,
                        child: StreamBuilder<PlayerState>(
                            stream: PlayerEngine.player.playerStateStream,
                            builder: (BuildContext context,
                                AsyncSnapshot<PlayerState> snapshot) {
                              if (snapshot.hasData && snapshot.data!.playing) {
                                return pauseIcon;
                              } else {
                                return playIcon;
                              }
                            })),
                    TextButton(
                        onPressed: () => PlayerEngine.playNextSong(),
                        child: const Icon(
                          Icons.skip_next,
                          size: 40,
                          color: Colors.black,
                        )),
                  ],
                )
              ],
            )));
  }
}
