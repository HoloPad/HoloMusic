import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:holomusic/Common/Parameters/AppStyle.dart';
import 'package:holomusic/Common/Storage/SongsStorage.dart';
import 'package:holomusic/UIComponents/SongItem.dart';
import 'package:holomusic/Views/Playlist/PlaylistOption.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Common/Player/Song.dart';
import '../../Common/Playlist/PlaylistBase.dart';

class PlaylistView extends StatefulWidget {
  PlaylistBase playlist;
  Function()? onBackPressed;

  PlaylistView(this.playlist, this.onBackPressed, {Key? key}) : super(key: key);

  @override
  State<PlaylistView> createState() => _PlaylistViewState();
}

class _PlaylistViewState extends State<PlaylistView> {
  double _imageSize = 150;
  bool _saveOfflineChecked = false;

  @override
  void initState() {
    SongsStorage.isAllSaved(widget.playlist).then((value) {
      setState(() {
        _saveOfflineChecked = value;
      });
    });
    super.initState();
  }

  void _onLinkClicked() async {
    if (!await launch(widget.playlist.getReferenceUrl()!)) {
      print("Cannot launch url");
    }
  }

  void _onSaveOnlineChecked(bool? state) {
    if (state != null) {
      setState(() {
        _saveOfflineChecked = state;
      });
      if (state) {
        SongsStorage.savePlaylist(widget.playlist);
      } else {
        SongsStorage.stopDownload();
      }
    }
  }

  void _onPlaylistDeletePressed() {
    final textStyle = TextStyle(color: AppStyle.text);
    final dialog = AlertDialog(
      title: Text(AppLocalizations.of(context)!.areYouSure, style: textStyle),
      content: Text(AppLocalizations.of(context)!.deletePlaylistConfirm,
          style: textStyle),
      actions: [
        TextButton(
            onPressed: () {
              setState(() {
                _saveOfflineChecked = false;
              });
              SongsStorage.deletePlaylist(widget.playlist);
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.yes, style: textStyle)),
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.no, style: textStyle))
      ],
      elevation: 24,
      backgroundColor: Colors.black,
    );
    showDialog(context: context, builder: (_) => dialog);
  }

  @override
  Widget build(BuildContext context) {
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
                          child: ExtendedImage(
                            image: widget.playlist.imageProvider,
                            width: _imageSize,
                            height: _imageSize,
                          )),
                      const SizedBox(height: 15),
                      Text(widget.playlist.name, style: AppStyle.titleStyle),
                      const SizedBox(height: 15),
                      Flex(
                        direction: Axis.horizontal,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        clipBehavior: Clip.antiAlias,
                        children: [
                          const Flexible(child: SizedBox()),
                          Expanded(
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                widget.playlist.isOnline
                                    ? OutlinedButton(
                                        onPressed: () {},
                                        child: Text(
                                            AppLocalizations.of(context)!
                                                .follow),
                                        style: OutlinedButton.styleFrom(
                                            side: const BorderSide(
                                                width: 0.5,
                                                color: Colors.white),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(50))),
                                      )
                                    : const SizedBox(),
                                widget.playlist.getReferenceUrl() != null
                                    ? TextButton(
                                        onPressed: _onLinkClicked,
                                        child: const Icon(Icons.link_rounded),
                                        style: TextButton.styleFrom(
                                            padding: const EdgeInsets.fromLTRB(
                                                4, 0, 4, 0),
                                            minimumSize: Size.zero))
                                    : const SizedBox()
                              ])),
                          Flexible(
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextButton(
                                      onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  PlaylistOptions(
                                                      widget.playlist))),
                                      child: Icon(
                                        Icons.more_vert,
                                        color: AppStyle.text,
                                      ),
                                      style: TextButton.styleFrom(
                                          padding: const EdgeInsets.fromLTRB(
                                              4, 0, 4, 0),
                                          minimumSize: Size.zero))
                                ]),
                          )
                        ],
                      )
                    ]),
                    const SizedBox(height: 15),
                    FutureBuilder<List<Song>>(
                      future: widget.playlist.getVideosInfo(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return ListBody(
                            children: snapshot.data!.map((e) {
                              return SongItem(e,
                                  playlist: widget.playlist,
                                  reloadList: () => setState(() {}));
                            }).toList(),
                          );
                        } else {
                          return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: CircularProgressIndicator())
                              ]);
                        }
                      },
                    ),
                    const SizedBox(
                      height: 50,
                    )
                  ])))
        ]));
  }
}
