import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:holomusic/Common/Parameters/AppStyle.dart';
import 'package:holomusic/Common/Playlist/PlaylistSaved.dart';
import 'package:holomusic/Common/Playlist/Providers/YouTubePlaylist.dart';
import 'package:holomusic/ServerRequests/UserRequest.dart';
import 'package:holomusic/UIComponents/NotificationShimmer.dart';
import 'package:holomusic/UIComponents/Shimmer.dart';
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

enum FollowButtonState { Loading, Followed, Unfollowed, Hidden }

class _PlaylistViewState extends State<PlaylistView> {
  double _imageSize = 150;
  var loadedElements = 0;
  final ValueNotifier<FollowButtonState> _isFavouriteListenable =
      ValueNotifier(FollowButtonState.Loading);

  @override
  void initState() {
    super.initState();
    if (widget.playlist.runtimeType == PlaylistSaved) {
      UserRequest.checkIfPlaylistIsFavourite(widget.playlist as PlaylistSaved).then((value) async {
        _isFavouriteListenable.value =
            value ? FollowButtonState.Followed : FollowButtonState.Unfollowed;
      });

    } /*else if (widget.playlist.runtimeType == YoutubePlaylist) {
      UserRequest.isYoutubePlaylistFollowed(widget.playlist as YoutubePlaylist).then((value) {
        _isFavouriteListenable.value =
            value ? FollowButtonState.Followed : FollowButtonState.Unfollowed;
      });
    } */else {
      _isFavouriteListenable.value = FollowButtonState.Hidden;
    }
  }

  void _onLinkClicked() async {
    if (!await launch(widget.playlist.getReferenceUrl()!)) {
      print("Cannot launch url");
    }
  }

  void onFollowClick() async {
    if (widget.playlist.runtimeType == PlaylistSaved) {
      UserRequest.makePlaylistAsFavourite(widget.playlist as PlaylistSaved);
    } else if (widget.playlist.runtimeType == YoutubePlaylist) {
      UserRequest.addYoutubePlaylistToFavourite(widget.playlist as YoutubePlaylist);
    }
    _isFavouriteListenable.value = FollowButtonState.Followed;
  }

  void onUnFollowClick() async {
    if (widget.playlist.runtimeType == PlaylistSaved) {
      UserRequest.unsetPlaylistAsFavourite(widget.playlist as PlaylistSaved);
    } else if (widget.playlist.runtimeType == YoutubePlaylist) {
      UserRequest.removeYoutubePlaylistToFavourite(widget.playlist as YoutubePlaylist);
    }
    _isFavouriteListenable.value = FollowButtonState.Unfollowed;
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
                      _imageSize = max(150 - notification.metrics.extentBefore, 0);
                    });
                    return true;
                  },
                  child: ListView(clipBehavior: Clip.antiAlias, children: <Widget>[
                    Column(children: [
                      Container(
                          decoration: BoxDecoration(
                              color: widget.playlist.backgroundColor ?? Colors.transparent,
                              borderRadius: BorderRadius.circular(10)),
                          child: FutureBuilder<ImageProvider<Object>>(
                              future: widget.playlist.getImageProvider(),
                              builder: (_, snapshot) {
                                if (snapshot.hasData) {
                                  return ExtendedImage(
                                    image: snapshot.data!,
                                    width: _imageSize,
                                    height: _imageSize,
                                  );
                                } else {
                                  return Padding(
                                      padding: EdgeInsets.all((_imageSize - 50) / 2),
                                      child: const SizedBox(
                                          width: 50,
                                          height: 50,
                                          child: CircularProgressIndicator()));
                                }
                              })),
                      const SizedBox(height: 5),
                      Text(widget.playlist.name,
                          style: TextStyle(color: AppStyle.text, fontSize: 25)),
                      if (widget.playlist.runtimeType == PlaylistSaved &&
                          (widget.playlist as PlaylistSaved).ownerId != null)
                        Text((widget.playlist as PlaylistSaved).ownerId!,
                            style: const TextStyle(color: Colors.grey, fontSize: 15)),
                      const SizedBox(height: 15),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            widget.playlist.isOnline &&
                                    ((widget.playlist.runtimeType == PlaylistSaved &&
                                            (widget.playlist as PlaylistSaved)
                                                .isOtherUsersPlaylist) ||
                                        widget.playlist.runtimeType == YoutubePlaylist)
                                ? ValueListenableBuilder<FollowButtonState>(
                                    valueListenable: _isFavouriteListenable,
                                    builder: (_, isFavourite, __) {
                                      bool isFollow = isFavourite == FollowButtonState.Followed;
                                      if (isFavourite == FollowButtonState.Hidden) {
                                        return SizedBox();
                                      }
                                      return Shimmer.fromColors(
                                          baseColor: AppStyle.ShimmerColorBase,
                                          highlightColor: AppStyle.ShimmerColorBackground,
                                          enabled: isFavourite == FollowButtonState.Loading,
                                          //If loading show the shimmer
                                          child: OutlinedButton(
                                            onPressed: isFollow ? onUnFollowClick : onFollowClick,
                                            child: isFollow
                                                ? Text(AppLocalizations.of(context)!
                                                    .removeFromFavourite)
                                                : Text(AppLocalizations.of(context)!.addToFavorite),
                                            style: OutlinedButton.styleFrom(
                                                side: const BorderSide(
                                                    width: 0.5, color: Colors.white),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(50))),
                                          ));
                                    })
                                : const SizedBox(),
                            widget.playlist.getReferenceUrl() != null
                                ? TextButton(
                                    onPressed: _onLinkClicked,
                                    child: const Icon(Icons.link_rounded),
                                    style: TextButton.styleFrom(
                                        padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                                        minimumSize: Size.zero))
                                : const SizedBox()
                          ]),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          TextButton(
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PlaylistOptions(widget.playlist))),
                              child: Icon(
                                Icons.more_vert,
                                color: AppStyle.text,
                              ),
                              style: TextButton.styleFrom(
                                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                                  minimumSize: Size.zero))
                        ],
                      )
                    ]),
                    const SizedBox(height: 15),
                    FutureBuilder<List<Song>>(
                      future: widget.playlist.getSongs(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data!.isEmpty) {
                            return Text(
                              AppLocalizations.of(context)!.noSongsInThisPlaylist,
                              style: AppStyle.textStyle,
                              textAlign: TextAlign.center,
                            );
                          } else {
                            return NotificationShimmer(
                                elementsToLoad: snapshot.data!.length,
                                notificationId: 'songitem',
                                child: ListBody(
                                  children: snapshot.data!.map((e) {
                                    return SongItem(e,
                                        playlist: widget.playlist,
                                        reloadList: () => setState(() {}));
                                  }).toList(),
                                ));
                          }
                        } else {
                          return Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                            SizedBox(width: 50, height: 50, child: CircularProgressIndicator())
                          ]);
                        }
                      },
                    ),
                    const SizedBox(
                      height: 100,
                    )
                  ])))
        ]));
  }
}
