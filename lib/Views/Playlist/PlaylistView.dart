import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:holomusic/UIComponents/SongItem.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Common/Playlist/Providers/Playlist.dart';
import '../../Common/Playlist/VideoInfo.dart';

class PlaylistView extends StatefulWidget {
  Playlist playlist;
  Function()? onBackPressed;

  PlaylistView(this.playlist, this.onBackPressed, {Key? key}) : super(key: key);

  @override
  State<PlaylistView> createState() => _PlaylistViewState();
}

class _PlaylistViewState extends State<PlaylistView> {
  double _imageSize = 150;

  void _onLinkClicked() async {
    if (!await launch(widget.playlist.getReferenceUrl()!)) {
      print("Cannot launch url");
    }
  }

  @override
  Widget build(BuildContext context) {
    const _nameTextStyle = TextStyle(color: Colors.white, fontSize: 15);

    return Padding(
        padding: const EdgeInsets.all(10),
        child: Column(children: [
          Row(children: [
            TextButton(
                onPressed: widget.onBackPressed,
                child: const Icon(Icons.arrow_back_ios, color: Colors.white))
          ]),
          Expanded(
              child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    setState(() {
                      _imageSize =
                          max(150 - notification.metrics.extentBefore, 0);
                    });
                    return true;
                  },
                  child:
                      ListView(clipBehavior: Clip.antiAlias, children: <Widget>[
                    Column(children: [
                      Container(
                          decoration: BoxDecoration(
                              color: widget.playlist.backgroundColor ??
                                  Colors.transparent,
                              borderRadius: BorderRadius.circular(10)),
                          child: ExtendedImage.network(
                            widget.playlist.imageUrl,
                            width: _imageSize,
                            height: _imageSize,
                          )),
                      const SizedBox(height: 15),
                      Text(widget.playlist.name, style: _nameTextStyle),
                      const SizedBox(height: 15),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            OutlinedButton(
                              onPressed: () {},
                              child: Text(AppLocalizations.of(context)!.follow),
                              style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      width: 0.5, color: Colors.white),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50))),
                            ),
                            widget.playlist.getReferenceUrl() != null
                                ? TextButton(
                                    onPressed: _onLinkClicked,
                                    child: const Icon(Icons.link_rounded))
                                : const SizedBox()
                          ]),
                      const SizedBox(height: 15),
                      FutureBuilder<List<VideoInfo>>(
                        future: widget.playlist.getVideosInfo(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return ListBody(
                              children: snapshot.data!
                                  .map((e) => SongItem(
                                        e.title,
                                        e.thumbnail,
                                        url: e.url,
                                        playlist: widget.playlist,
                                      ))
                                  .toList(),
                            );
                          } else {
                            return const CircularProgressIndicator();
                          }
                        },
                      ),
                      const SizedBox(
                        height: 50,
                      )
                    ])
                  ])))
        ]));
  }
}
