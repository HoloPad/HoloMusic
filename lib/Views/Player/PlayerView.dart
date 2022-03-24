import 'dart:async';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:holomusic/Common/AppColors.dart';
import 'package:holomusic/Common/PlayerEngine.dart';
import 'package:holomusic/Common/PlayerStateController.dart';
import 'package:holomusic/Common/VideoHandler.dart';
import 'package:holomusic/UIComponents/TimeSlider.dart';
import 'package:marquee_text/marquee_text.dart';
import 'package:palette_generator/palette_generator.dart';

class PlayerView extends StatefulWidget {
  final ValueNotifier<int> playerStateStream;
  StreamController<bool> _outputStreamLoading = StreamController();

  PlayerView(this.playerStateStream, {Key? key}) : super(key: key);

  Stream<bool> getRequestLoadingViewStream() {
    return _outputStreamLoading.stream;
  }

  @override
  State<StatefulWidget> createState() => _PlayerViewState();
}

class _PlayerViewState extends State<PlayerView> {
  bool updatePosition = false;
  Color _mainColor = Colors.blue;
  ImageProvider? _lastProvider;
  bool _hasNextEnabled = true;

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

  RepetitionState _getNextRepetitionState() {
    switch (PlayerEngine.getRepetitionStateValueNotifier().value) {
      case RepetitionState.Off:
        return RepetitionState.OneItem;
      case RepetitionState.OneItem:
        return RepetitionState.AllItems;
      case RepetitionState.AllItems:
        return RepetitionState.Off;
    }
  }

  final repetitionIcon = ValueListenableBuilder<RepetitionState>(
    valueListenable: PlayerEngine.getRepetitionStateValueNotifier(),
    builder: (_, value, __) {
      const _size = 30.0;
      const _color = Colors.white;
      switch (value) {
        case RepetitionState.Off:
          return const Icon(Icons.repeat, size: _size, color: _color);
        case RepetitionState.OneItem:
          return const Icon(Icons.repeat_one_on, size: _size, color: _color);
        case RepetitionState.AllItems:
          return const Icon(Icons.repeat_on, size: _size, color: _color);
      }
    },
  );

  void _onRepetitionClick() {
    final next = _getNextRepetitionState();
    PlayerEngine.setRepetitionState(next);
  }

  //Called also when there is a new song
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
    PlayerEngine.hasNext().then((value) {
      setState(() {
        _hasNextEnabled = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              gradient:
                  AppColors.getStandardPaletteWithAnotherMainColor(_mainColor)),
          child: Column(
            children: [
              Row(children: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child:
                        const Icon(Icons.arrow_drop_down, color: Colors.white))
              ]),
              const SizedBox(height: 15),
              ValueListenableBuilder<VideoHandler?>(
                  valueListenable: PlayerEngine.getCurrentVideoHandlerPlaying(),
                  builder: (context, value, _) {
                    if (value != null) {
                      final img = ExtendedImage.network(
                          value.video.thumbnails.highResUrl,
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
              ValueListenableBuilder<VideoHandler?>(
                  valueListenable: PlayerEngine.getCurrentVideoHandlerPlaying(),
                  builder: (context, value, _) {
                    return Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: MarqueeText(
                          text: TextSpan(
                              text: value == null ? "..." : value.video.title,
                              style: _titleStyle),
                          textAlign: TextAlign.center,
                          speed: 25,
                        ));
                  }),
              const SizedBox(height: 15),
              StreamBuilder<Duration>(
                  stream: PlayerEngine.player.positionStream,
                  builder:
                      (BuildContext context, AsyncSnapshot<Duration> snapshot) {
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
                  ValueListenableBuilder<int>(
                      valueListenable: widget.playerStateStream,
                      builder: (BuildContext context, value, child) {
                        if (value & MyPlayerState.play == 0) {
                          return playIcon;
                        } else {
                          return pauseIcon;
                        }
                      }),
                  TextButton(
                      onPressed: () {
                        if (_hasNextEnabled) {
                          widget._outputStreamLoading.add(true);
                          PlayerEngine.playNextSong();
                        }
                      },
                      child: Icon(
                        Icons.skip_next,
                        size: 40,
                        color: Color.fromRGBO(
                            255, 255, 255, _hasNextEnabled ? 1 : 0.5),
                      )),
                  TextButton(
                      onPressed: _onRepetitionClick,
                      child: repetitionIcon),
                ],
              ),
            ],
          )),
      bottomSheet: ValueListenableBuilder<int>(
          valueListenable: widget.playerStateStream,
          builder: (_, value, __) {
            if (value & MyPlayerState.loading != 0) {
              return const LinearProgressIndicator();
            } else {
              return const SizedBox();
            }
          }),
    );
  }
}
