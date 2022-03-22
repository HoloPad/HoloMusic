import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:holomusic/Common/AppColors.dart';
import 'package:holomusic/Common/PlayerEngine.dart';
import 'package:holomusic/UIComponents/TimeSlider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:palette_generator/palette_generator.dart';

import '../../Common/LoadingNotification.dart';

enum RepetitionMode { disabled, oneSongs, allSongs }

class PlayerView extends StatefulWidget {
  final Stream<bool> loadingStream;

  PlayerView(this.loadingStream, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PlayerViewState();
}

class _PlayerViewState extends State<PlayerView> {
  bool updatePosition = false;
  RepetitionMode _repetitionMode = RepetitionMode.disabled;
  Color _mainColor = Colors.blue;
  ImageProvider? _lastProvider;

  final _titleStyle = const TextStyle(
      fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white);

  final playIcon = TextButton(
      onPressed: () => PlayerEngine.toggle(),
      child: const Icon(
        Icons.play_circle_fill,
        size: 70,
        color: Colors.white,
      ));

  final pauseIcon = TextButton(
      onPressed: () => PlayerEngine.toggle(),
      child: const Icon(
        Icons.pause,
        size: 70,
        color: Colors.white,
      ));

  final loadingIcon = const SizedBox(
    height: 70,
    width: 70,
    child: CircularProgressIndicator(),
  );

  RepetitionMode _getNextRepetitionState() {
    switch (_repetitionMode) {
      case RepetitionMode.disabled:
        return RepetitionMode.oneSongs;
      case RepetitionMode.oneSongs:
        return RepetitionMode.allSongs;
      case RepetitionMode.allSongs:
        return RepetitionMode.disabled;
    }
  }

  IconData _getRepetitionIcon() {
    switch (_repetitionMode) {
      case RepetitionMode.disabled:
        return Icons.repeat;
      case RepetitionMode.oneSongs:
        return Icons.repeat_one_on;
      case RepetitionMode.allSongs:
        return Icons.repeat_on;
    }
  }

  void _onRepetitionClick() {
    final next = _getNextRepetitionState();
    switch (next) {
      case RepetitionMode.disabled:
        PlayerEngine.player.setLoopMode(LoopMode.off);
        break;
      case RepetitionMode.oneSongs:
        PlayerEngine.player.setLoopMode(LoopMode.one);
        break;
      case RepetitionMode.allSongs:
        //TODO must be implemented when playlist are done
        PlayerEngine.player.setLoopMode(LoopMode.all);
        break;
    }
    setState(() {
      _repetitionMode = next;
    });
  }


  Future _updateBackground(ImageProvider provider) async {
    if (provider == _lastProvider) {
      return;
    }
    _lastProvider = provider;
    final palette = await PaletteGenerator.fromImageProvider(provider);
    if (palette.dominantColor != null) {
      final newColor = palette.dominantColor!.color;
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        setState(() {
          _mainColor = newColor;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                gradient: AppColors.getStandardPaletteWithAnotherMainColor(
                    _mainColor)),
            child: Column(
              children: [
                Row(children: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_drop_down,
                          color: Colors.white))
                ]),
                const SizedBox(height: 15),
                ValueListenableBuilder<Video?>(
                    valueListenable: PlayerEngine.getCurrentVideoPlaying(),
                    builder: (context, value, _) {
                      if (value != null) {
                        final img = ExtendedImage.network(
                            value.thumbnails.highResUrl,
                            height: 250);
                        _updateBackground(img.image);
                        return img;
                      } else {
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
                const SizedBox(height: 15),
                StreamBuilder<Duration>(
                    stream: PlayerEngine.player.positionStream,
                    builder: (BuildContext context,
                        AsyncSnapshot<Duration> snapshot) {
                      if (snapshot.hasData) {
                        return TimeSlider(
                            current: snapshot.data,
                            end: PlayerEngine.player.duration,
                            textColor: Colors.white,
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
                        onPressed: () => {},
                        child: const Icon(
                          Icons.monitor_heart_outlined,
                          size: 30,
                          color: Colors.white,
                        )),
                    TextButton(
                        onPressed: () => PlayerEngine.playPreviousSong(),
                        child: const Icon(
                          Icons.skip_previous,
                          size: 40,
                          color: Colors.white,
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
                        onPressed: () {
                          LoadingNotification(true).dispatch(context);
                          PlayerEngine.playNextSong();
                        },
                        child: const Icon(
                          Icons.skip_next,
                          size: 40,
                          color: Colors.white,
                        )),
                    TextButton(
                        onPressed: _onRepetitionClick,
                        child: Icon(
                          _getRepetitionIcon(),
                          size: 30,
                          color: Colors.white,
                        )),
                  ],
                )
              ],
            )));
  }
}
