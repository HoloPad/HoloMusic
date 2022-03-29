import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:holomusic/Common/Notifications/DownloadNotification.dart';
import 'package:holomusic/Common/Offline/OfflineStorage.dart';
import 'package:holomusic/Common/Parameters/AppColors.dart';
import 'package:holomusic/Common/Player/PlayerEngine.dart';
import 'package:holomusic/Common/Notifications/LoadingNotification.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'dart:io';
import '../Common/Player/OnlineSong.dart';
import '../Common/Player/Song.dart';
import '../Views/Playlist/SongOptions.dart';
import '../Common/Playlist/Providers/Playlist.dart' as MyPlaylist;
import 'Shimmer.dart';

class SongItem extends StatefulWidget {
  Song song;
  MyPlaylist.Playlist? playlist;
  var yt = YoutubeExplode();

  SongItem(this.song, {Key? key}) : super(key: key);

  @override
  State<SongItem> createState() => _SongItemState();
}

class _SongItemState extends State<SongItem> with TickerProviderStateMixin {
  bool _isLoading = false;
  bool _imageIsLoading = false;

  @override
  initState() {
    super.initState();
  }

  void _onOptionClick(BuildContext context) async {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => SongOptions(widget.song)));
  }

  void _onPlayClicked() async {
    LoadingNotification(true).dispatch(context);
    if (!widget.song.isOnline()) {
      //If offline play directly
      PlayerEngine.play(widget.song);
    } else {
      //Check first on the offline storage
      final offlineSong = await OfflineStorage.getSongById(widget.song.id);
      if (offlineSong != null) {
        PlayerEngine.play(offlineSong);
      } else {
        PlayerEngine.play(widget.song);
      }
    }
  }

  Widget? _onImageLoaded(ExtendedImageState state) {
    if (state.extendedImageLoadState == LoadingState.loaded) {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        setState(() {
          _imageIsLoading = false;
        });
      });
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    const _titleStyle = TextStyle(color: Colors.white);
    const itemRadius = 10.0;

    return Card(
        color: const Color.fromRGBO(56, 56, 56, 0.8),
        elevation: 1,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(itemRadius)),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
              child: InkWell(
                  onTap: _onPlayClicked,
                  child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Shimmer.fromColors(
                            baseColor: const Color.fromRGBO(34, 35, 39, 1),
                            highlightColor:
                                const Color.fromRGBO(100, 103, 115, 1),
                            enabled: _imageIsLoading,
                            child: ClipRRect(
                              child: widget.song.isOnline()
                                  ? ExtendedImage.network(
                                      widget.song.getThumbnail(),
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.fill,
                                      enableLoadState: true,
                                      loadStateChanged: _onImageLoaded,
                                    )
                                  : ExtendedImage.file(
                                      File(widget.song.getThumbnail()),
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.fill,
                                      enableLoadState: true,
                                      loadStateChanged: _onImageLoaded,
                                    ),
                              borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(itemRadius)),
                            )),
                        Expanded(
                            child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.song.title,
                                        maxLines: 1,
                                        style: _titleStyle,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ]))),
                      ]))),
          Row(children: [
            FutureBuilder<List<DownloadNotification>>(
                future: OfflineStorage.getCurrentState(),
                builder: (_, s0) {
                  if (s0.hasData) {
                    return StreamBuilder<List<DownloadNotification>>(
                        stream: OfflineStorage.getDownloadStream(),
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
                                        color: AppColors.text);
                                  case DownloadState.error:
                                    return Icon(Icons.clear,color: AppColors.text);
                                }
                              }
                            }
                          }
                          return const SizedBox();
                        });
                  } else
                    return const SizedBox();
                }),
            TextButton(
                onPressed: () => _onOptionClick(context),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.more_vert))
          ])
        ]));
  }
}
