import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import '../../../Common/Playlist/PlaylistBase.dart';
import '../../../UIComponents/Shimmer.dart';

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
  bool _imageIsLoading = false;
  bool imageLoadedFantore = true;

  Widget? _onImageLoaded(ExtendedImageState state) {
    if (state.extendedImageLoadState == LoadState.completed) {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        setState(() {
          _imageIsLoading = false;
        });
      });
    } else if (state.extendedImageLoadState == LoadState.failed) {
      return Image.asset("resources/png/fake_thumbnail.png");
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
            Shimmer.fromColors(
                baseColor: const Color.fromRGBO(34, 35, 39, 1),
                highlightColor: const Color.fromRGBO(100, 103, 115, 1),
                enabled: _imageIsLoading,
                child: Container(
                    decoration: BoxDecoration(
                        color: widget.playlist.backgroundColor ??
                            Colors.transparent,
                        borderRadius: BorderRadius.circular(10)),
                    child: FutureBuilder<ImageProvider<Object>>(
                        future: widget.playlist.getImageProvider(),
                        builder: (_, snapshot) {
                          return ExtendedImage(
                            image: snapshot.data ??
                                const AssetImage(
                                    "resources/png/fake_thumbnail.png"),
                            width: 150,
                            height: 150,
                            fit: widget.playlist.backgroundColor == null
                                ? BoxFit.fill
                                : BoxFit.contain,
                            loadStateChanged: _onImageLoaded,
                          );
                        }))),
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
