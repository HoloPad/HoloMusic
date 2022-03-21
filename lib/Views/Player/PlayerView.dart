import 'package:flutter/material.dart';
import 'package:holomusic/Common/PlayerEngine.dart';
import 'package:holomusic/Common/VideoHandler.dart';
import 'package:holomusic/UIComponents/TimeSlider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PlayerView extends StatefulWidget {

  PlayerView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PlayerViewState();
}

class _PlayerViewState extends State<PlayerView> {
  bool updatePosition = false;

  final _titleStyle =
      const TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

  final playIcon = TextButton(
      onPressed: () => PlayerEngine.toggle(),
      child: const Icon(
        Icons.play_circle_fill,
        size: 70,
        color: Colors.black,
      ));

  final pauseIcon = TextButton(
      onPressed: () => PlayerEngine.toggle(),
      child: const Icon(
        Icons.pause,
        size: 70,
        color: Colors.black,
      ));

  final loadingIcon = const SizedBox(
    height: 70,
    width: 70,
    child: CircularProgressIndicator(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.appTitle),
        ),
        body: Padding(
            padding: const EdgeInsets.all(20),
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
                      if (snapshot.hasData) {
                        return TimeSlider(
                            current: snapshot.data,
                            end: PlayerEngine.player.duration,
                            onChange: (d) {
                              PlayerEngine.player
                                  .seek(Duration(seconds: d.toInt()));
                            });
                      } else {
                        return const SizedBox();
                      }
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
                    StreamBuilder<PlayerState>(
                        stream: PlayerEngine.player.playerStateStream,
                        builder: (BuildContext context,
                            AsyncSnapshot<PlayerState> snapshot) {
                          if (snapshot.hasData) {
                            switch (snapshot.data!.processingState) {
                              case ProcessingState.loading:
                              case ProcessingState.buffering:
                                return loadingIcon;
                              case ProcessingState.idle:
                              case ProcessingState.ready:
                              case ProcessingState.completed:
                                if (snapshot.data!.playing) {
                                  return pauseIcon;
                                } else {
                                  return playIcon;
                                }
                            }
                          } else {
                            return playIcon;
                          }
                        }),
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
