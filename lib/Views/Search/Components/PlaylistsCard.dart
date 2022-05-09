import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:holomusic/Common/Parameters/AppStyle.dart';
import 'package:holomusic/Common/Playlist/PlaylistSaved.dart';
import 'package:holomusic/Common/Playlist/PlaylistBase.dart';


class PlaylistsCard extends StatefulWidget {
  late PlaylistSaved playlist;
  late BuildContext context;
  late Function(PlaylistBase playlist) onClicked;
  PlaylistsCard(PlaylistSaved playlist, Function(PlaylistBase playlist) onCli, BuildContext context){
    this.onClicked = onCli;
    this.playlist = playlist;
    this.context = context;
  }

  @override
  PlaylistsCardState createState() => new PlaylistsCardState(playlist, context);
}

class PlaylistsCardState extends State<PlaylistsCard> {
  late PlaylistSaved playlist;
  late BuildContext context;



  PlaylistsCardState(PlaylistSaved playlist, BuildContext context){
    this.playlist = playlist;
    this.context = context;
  }




  @override
  Widget build(BuildContext context) {
    return InkWell(
        hoverColor: AppStyle.primaryBackground.withOpacity(0.6),
        onTap: (){
          widget.onClicked(playlist);
        },
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
