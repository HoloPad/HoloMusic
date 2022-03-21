import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:holomusic/Common/PlayerEngine.dart';
import 'package:holomusic/Common/VideoHandler.dart';
import 'package:holomusic/Common/class%20LoadingNotification.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../Views/Playlist/SongOptions.dart';

class SongItem extends StatefulWidget {
  String title;
  String? thumbnail;
  String? url;
  Video? video;
  var yt = YoutubeExplode();

  SongItem(this.title, this.thumbnail, {this.url, this.video, Key? key})
      : super(key: key);

  @override
  State<SongItem> createState() => _SongItemState();
}

class _SongItemState extends State<SongItem> with TickerProviderStateMixin {
  bool _isLoading = false;

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
    LoadingNotification(false).dispatch(context);
    if (video != null) {
      PlayerEngine.play(VideoHandler(video));
    } else {
      final snackbar = SnackBar(content: Text(AppLocalizations.of(context)!.cannotLoadSong));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
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
                        ClipRRect(
                          child: Image(
                              image: NetworkImage(widget.thumbnail!),
                              width: 60,
                              height: 60,
                              fit: BoxFit.fill),
                          borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(itemRadius)),
                        ),
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
