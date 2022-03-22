import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:holomusic/Common/DataFetcher/Providers/Playlist.dart';
import '../../../UIComponents/Shimmer.dart';

class PlayListWidget extends StatefulWidget {
  Color? backgroundColor;
  Playlist playlist;
  Function(Playlist)? onClick;

  PlayListWidget({Key? key, required this.playlist, this.onClick})
      : super(key: key);

  @override
  State<PlayListWidget> createState() => _PlayListWidgetState();
}

class _PlayListWidgetState extends State<PlayListWidget> {
  bool _imageIsLoading = false;

  Widget? _onImageLoaded(ExtendedImageState state) {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      setState(() {
        _imageIsLoading = state.extendedImageLoadState != LoadState.completed;
      });
    });
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
                    child: ExtendedImage.network(
                      widget.playlist.imageUrl,
                      width: 150,
                      height: 150,
                      fit: BoxFit.contain,
                      enableLoadState: true,
                      loadStateChanged: _onImageLoaded,
                    ))),
            Text(widget.playlist.name, style: _nameTextStyle)
          ],
        ));
  }
}
