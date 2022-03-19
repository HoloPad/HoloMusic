import 'package:flutter/material.dart';
import 'package:holomusic/Common/PlayerEngine.dart';
import 'package:holomusic/Views/SongOptions.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:holomusic/Common/VideoHandler.dart';

class VideoCard extends StatelessWidget {
  final Video video;
  final void Function(VideoHandler) playSongFunction;

  const VideoCard(
      {Key? key, required this.video, required this.playSongFunction})
      : super(key: key);

  final _titleStyle =
      const TextStyle(fontSize: 12, fontWeight: FontWeight.bold);

  String _durationToText(Duration? duration) {
    if (duration == null) {
      return "";
    }
    if (duration.inHours < 1) {
      return "${duration.inMinutes}:${(duration.inSeconds.remainder(60))}";
    } else {
      return "${duration.inHours}:${duration.inMinutes.remainder(60)}:${(duration.inSeconds.remainder(60))}";
    }
  }

  void _videoClicked() {
    final handler = VideoHandler(video);
    PlayerEngine.play(handler);
    playSongFunction(handler);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        color: Colors.white38,
        child: Row(children: [
          Flexible(
              flex: 10,
              child: InkWell(
                  onTap: _videoClicked,
                  child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image(
                          image: NetworkImage(video.thumbnails.lowResUrl),
                          height: 60,
                        ),
                        Expanded(
                            child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        video.title,
                                        maxLines: 1,
                                        style: _titleStyle,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        _durationToText(video.duration),
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    ]))),
                      ]))),
          Flexible(
              flex: 1,
              child: TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SongOptions(video: video)));
                  },
                  child: const Icon(Icons.arrow_drop_down)))
        ]));
  }
}
