import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:holomusic/Common/Notifications/ShimmerLoadingNotification.dart';

import '../../../Common/Playlist/PlaylistBase.dart';

class PlayListWidget extends StatefulWidget {
  Color? backgroundColor;
  PlaylistBase playlist;
  Function(PlaylistBase)? onClick;

  PlayListWidget({Key? key, required this.playlist, this.onClick})
      : super(key: key);

  @override
  State<PlayListWidget> createState() => _PlayListWidgetState();
}

class _PlayListWidgetState extends State<PlayListWidget> {
  bool imageLoadedFantore = true;

  Widget? _onImageLoaded(ExtendedImageState state) {
    if (state.extendedImageLoadState == LoadState.failed) {
      ShimmerLoadingNotification("playlistwidget").dispatch(context);
      return Image.asset("resources/png/fake_thumbnail.png");
    } else if (state.extendedImageLoadState == LoadState.completed) {
      ShimmerLoadingNotification("playlistwidget").dispatch(context);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    const _nameTextStyle = TextStyle(color: Colors.white, fontSize: 15);
    return InkWell(
        onTap: () {
          if (widget.onClick != null) {
            widget.onClick!(widget.playlist);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                decoration: BoxDecoration(
                    color:
                        widget.playlist.backgroundColor ?? Colors.transparent),
                child: FutureBuilder<ImageProvider<Object>>(
                    future: widget.playlist.getImageProvider(),
                    builder: (_, snapshot) {
                      if (snapshot.hasData) {
                        return ExtendedImage(
                          image: snapshot.data!,
                          width: 150,
                          height: 150,
                          fit: widget.playlist.backgroundColor == null
                              ? BoxFit.fill
                              : BoxFit.contain,
                          enableLoadState: true,
                          handleLoadingProgress: true,
                          //loadStateChanged: _onImageLoaded,
                        );
                      } else {
                        return const Padding(
                            padding: EdgeInsets.all((150 - 50) / 2),
                            child: SizedBox(
                                width: 50,
                                height: 50,
                                child: CircularProgressIndicator()));                      }
                    })),
            SizedBox(
                width: 150,
                height: 30,
                child: Text(
                  widget.playlist.name,
                  style: _nameTextStyle,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ))
          ],
        ));
  }
}
