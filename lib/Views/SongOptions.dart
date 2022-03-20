import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:holomusic/Common/PlayerEngine.dart';
import 'package:holomusic/Common/VideoHandler.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SongOptions extends StatelessWidget {
  final Video video;

  const SongOptions({Key? key, required this.video}) : super(key: key);

  final _titleStyle =
      const TextStyle(fontSize: 20, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Expanded(
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image(
                      image: NetworkImage(video.thumbnails.highResUrl),
                      height: 200,
                    ),
                    const SizedBox(height: 20),
                    Flexible(
                        child: Text(
                      video.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _titleStyle,
                    )),
                    const SizedBox(height: 20),
                    TextButton(
                        onPressed: () {
                          PlayerEngine.addSongToQueue(VideoHandler(video));
                          Navigator.pop(context);
                        },
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(AppLocalizations.of(context)!.addToQueue),
                              const SizedBox(width: 5),
                              const Icon(Icons.add)
                            ])),
                    const SizedBox(height: 20),
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(AppLocalizations.of(context)!.cancel),
                              const SizedBox(width: 5),
                              const Icon(Icons.cancel)
                            ])),
                    const SizedBox(height: 20)
                  ]))),
    ]));
  }
}
