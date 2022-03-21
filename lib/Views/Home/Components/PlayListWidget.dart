import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:holomusic/Common/DataFetcher/Providers/Playlist.dart';
import 'package:holomusic/Views/Playlist/PlaylistView.dart';

class PlayListWidget extends StatelessWidget {
  Color? backgroundColor;
  Playlist playlist;
  Function(Playlist)? onClick;

  PlayListWidget({Key? key, required this.playlist, this.onClick}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const _nameTextStyle = TextStyle(color: Colors.white, fontSize: 15);

    return InkWell(
        onTap: (){
          if(onClick!=null) {
            onClick!(playlist);
          }
        },
        child: Column(
          children: [
            Container(
                decoration: BoxDecoration(
                    color: playlist.backgroundColor ?? Colors.transparent,
                    borderRadius: BorderRadius.circular(10)),
                child: Image.network(
                  playlist.imageUrl,
                  width: 150,
                  height: 150,
                )),
            Text(playlist.name, style: _nameTextStyle)
          ],
        ));
  }
}
