import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:holomusic/Common/Notifications/ReRenderNotification.dart';
import 'package:holomusic/Common/Parameters/AppStyle.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:holomusic/Common/Storage/UserHistoryStorage.dart';
import '../../../ServerRequests/UserRequest.dart';
import 'package:holomusic/Common/Playlist/PlaylistSaved.dart';

class PlaylistsCard extends StatelessWidget {
  /*
  String playlistname;

  PlaylistsCard(this.playlistname, {Key? key}) : super(key: key);
*/
  PlaylistSaved playlist;

  PlaylistsCard(this.playlist, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        hoverColor: AppStyle.primaryBackground.withOpacity(0.6),
        child: Card(
            color: AppStyle.primaryBackground,
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      Image.network(playlist.songs[0].thumbnail.toString(),height: 60,),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                           Text(
                                playlist.name,
                                style: TextStyle(
                                    color: AppStyle.textStyle.color,
                                    fontSize: 20),
                              ),
                            Text(
                                  "Number of songs: " +
                                      playlist.songs.length.toString(),
                                  style: TextStyle(
                                      color: AppStyle.textStyle.color
                                          ?.withOpacity(0.8),
                                      fontSize: 12),
                                )

                          ]),
                    ]))));
  }
}
