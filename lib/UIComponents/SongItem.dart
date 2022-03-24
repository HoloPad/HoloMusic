import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:holomusic/Common/PlayerEngine.dart';
import 'package:holomusic/Common/VideoHandler.dart';
import 'package:holomusic/Common/LoadingNotification.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../Views/Playlist/SongOptions.dart';
import '../Common/DataFetcher/Providers/Playlist.dart' as MyPlaylist;
import 'Shimmer.dart';

class SongItem extends StatefulWidget {
  String title;
  String? thumbnail;
  String? url;
  Video? video;
  MyPlaylist.Playlist? playlist;
  var yt = YoutubeExplode();

  SongItem(this.title, this.thumbnail,
      {this.url, this.video, this.playlist, Key? key})
      : super(key: key);

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

  Future<Video?> _getVideo() async {
    if (widget.video != null) {
      return widget.video;
    }
    if (widget.url == null) {
      return null;
    }
    widget.video = await widget.yt.videos.get(widget.url);
    return widget.video;
  }

  void _onOptionClick(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    widget.video = await _getVideo();
    setState(() {
      _isLoading = false;
    });

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SongOptions(video: widget.video!)));
  }

  void _onPlayClicked() async {
    LoadingNotification(true).dispatch(context);
    final video = await _getVideo();
    //LoadingNotification(false).dispatch(context);
    if (video != null) {
      PlayerEngine.play(VideoHandler(video, playlist: widget.playlist));
    } else {
      final snackbar =
          SnackBar(content: Text(AppLocalizations.of(context)!.cannotLoadSong));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
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
                              child: ExtendedImage.network(
                                widget.thumbnail!,
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
                                        widget.title,
                                        maxLines: 1,
                                        style: _titleStyle,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ]))),
                      ]))),
          TextButton(
              onPressed: () => _onOptionClick(context),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Icon(Icons.more_vert))
        ]));
  }
}
