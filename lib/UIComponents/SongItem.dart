import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:holomusic/Common/Notifications/LoadingNotification.dart';
import 'package:holomusic/Common/Parameters/AppStyle.dart';
import 'package:holomusic/Common/Player/PlayerEngine.dart';
import 'package:holomusic/Common/Storage/SongsStorage.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../Common/Player/Song.dart';
import '../Common/Playlist/PlaylistBase.dart';
import '../Views/Playlist/SongOptions.dart';

class SongItem extends StatelessWidget {
  Song song;
  PlaylistBase? playlist;
  var yt = YoutubeExplode();
  Function()? reloadList;

  SongItem(this.song, {this.playlist, this.reloadList, Key? key})
      : super(key: key);

  void _onOptionClick(BuildContext context) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                SongOptions(song, playlist: playlist)))
        .then((value) {
      if ((value as bool) && reloadList != null) reloadList!();
    });
  }


  void _onPlayClicked(BuildContext context) async {
    LoadingNotification(true).dispatch(context);
    if (!await song.isOnline()) {
      //If offline play directly
      PlayerEngine.play(song);
    } else {
      //Check first on the offline storage
      final offlineSong = await SongsStorage.getSongById(song.id);
      if (offlineSong != null) {
        PlayerEngine.play(offlineSong);
      } else {
        PlayerEngine.play(song);
      }
    }
  }



  Widget? _onImageLoaded(ExtendedImageState state) {
    if (state.extendedImageLoadState == LoadState.failed) {
      return Image.asset("resources/png/fake_thumbnail.png");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    const _titleStyle = TextStyle(color: Colors.white);
    const itemRadius = 10.0;

    return Card(
        color: AppStyle.primaryBackground,
        elevation: 1,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(itemRadius)),
        child:
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
              child: InkWell(
                  onTap: ()=>_onPlayClicked(context),
                  child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ExtendedImage(
                                image: song.getThumbnailImageAsset(),
                                width: 60,
                                height: 60,
                                fit: BoxFit.fill,
                                enableLoadState: true,
                                loadStateChanged: _onImageLoaded,
                              ),
                        Expanded(
                            child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        song.title,
                                        maxLines: 1,
                                        style: _titleStyle,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ]))),
                      ]))),
          Row(children: [
            ValueListenableBuilder<SongState>(
              valueListenable: song.getStateNotifier(),
              builder: (_, state, __) {
                switch (state) {
                  case SongState.online:
                    return const SizedBox();
                  case SongState.offline:
                    return Icon(Icons.download_done,
                        color: AppStyle.text);
                  case SongState.downloading:
                    return const CircularProgressIndicator(
                        color: Colors.grey);
                  case SongState.errorOnDownloading:
                    return Icon(Icons.clear,
                        color: AppStyle.text);
                }
              },
            ),
            /*
            FutureBuilder<List<DownloadNotification>>(
                future: SongsStorage.getCurrentState(),
                builder: (_, s0) {
                  if (s0.hasData) {
                    return StreamBuilder<List<DownloadNotification>>(
                        stream: SongsStorage.getDownloadStream(),
                        initialData: s0.data!,
                        builder: (_, s1) {
                          if (s1.hasData) {
                            for (var e in s1.data!) {
                              if (e.id == widget.song.id) {
                                switch (e.state) {
                                  case DownloadState.nope:
                                  case DownloadState.waiting:
                                    return const SizedBox();
                                  case DownloadState.downloading:
                                    return const CircularProgressIndicator(
                                        color: Colors.grey);
                                  case DownloadState.downloaded:
                                    return Icon(Icons.download_done,
                                        color: AppStyle.text);
                                  case DownloadState.error:
                                    return Icon(Icons.clear,
                                        color: AppStyle.text);
                                }
                              }
                            }
                          }
                          return const SizedBox();
                        });
                  } else {
                    return const SizedBox();
                  }
                })*/
            TextButton(
                onPressed: () => _onOptionClick(context),
                child: const Icon(Icons.more_vert))
          ])
        ]));
  }
}
