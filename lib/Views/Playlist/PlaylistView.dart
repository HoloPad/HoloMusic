import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:holomusic/Common/Offline/OfflineStorage.dart';
import 'package:holomusic/Common/Parameters/AppColors.dart';
import 'package:holomusic/UIComponents/SongItem.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Common/Player/Song.dart';
import '../../Common/Playlist/Providers/Playlist.dart';

class PlaylistView extends StatefulWidget {
  Playlist playlist;
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
    OfflineStorage.isAllSaved(widget.playlist).then((value) {
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
        OfflineStorage.savePlaylist(widget.playlist);
      }
      else {
        OfflineStorage.stopDownload();
      }
    }
  }

  void _onDeletePressed() {
    final textStyle = TextStyle(color: AppColors.text);
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
              OfflineStorage.deletePlaylist(widget.playlist);
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
                        children: [
                          const Expanded(child: SizedBox()),
                          Expanded(
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                OutlinedButton(
                                  onPressed: () {},
                                  child: Text(
                                      AppLocalizations.of(context)!.follow),
                                  style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                          width: 0.5, color: Colors.white),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50))),
                                ),
                                widget.playlist.getReferenceUrl() != null
                                    ? TextButton(
                                        onPressed: _onLinkClicked,
                                        child: const Icon(Icons.link_rounded))
                                    : const SizedBox()
                              ])),
                          Expanded(
                              child: widget.playlist.isOnline
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                          Checkbox(
                                              value: _saveOfflineChecked,
                                              onChanged: _onSaveOnlineChecked,
                                              checkColor: AppColors.text,
                                              side: MaterialStateBorderSide
                                                  .resolveWith((states) =>
                                                      BorderSide(
                                                          width: 1,
                                                          color:
                                                              AppColors.text))),
                                          Text(
                                              AppLocalizations.of(context)!
                                                  .saveOffline,
                                              style: TextStyle(
                                                  color: AppColors.text)),
                                          TextButton(
                                              onPressed: _onDeletePressed,
                                              child: Icon(
                                                Icons.delete_outline_rounded,
                                                color: AppColors.text,
                                              ))
                                        ])
                                  : const SizedBox())
                        ],
                      ),
                      const SizedBox(height: 15),
                      FutureBuilder<List<Song>>(
                        future: widget.playlist.getVideosInfo(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return ListBody(
                              children: snapshot.data!.map((e) {
                                return SongItem(e);
                              }).toList(),
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
