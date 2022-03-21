import 'package:flutter/material.dart';
import 'package:holomusic/Common/DataFetcher/Providers/Playlist.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:holomusic/Common/DataFetcher/VideoInfo.dart';
import 'package:holomusic/UIComponents/SongItem.dart';

class PlaylistView extends StatelessWidget {
  Playlist playlist;
  Function()? onBackPressed;

  PlaylistView(this.playlist, this.onBackPressed, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const _nameTextStyle = TextStyle(color: Colors.white, fontSize: 15);

    return Padding(
        padding: const EdgeInsets.all(10),
        child: Column(children: [
          Row(children: [
            TextButton(
                onPressed: onBackPressed,
                child: const Icon(Icons.arrow_back_ios, color: Colors.white))
          ]),
          Expanded(
              child: ListView(clipBehavior: Clip.antiAlias, children: <Widget>[
            Column(children: [
              Container(
                  decoration: BoxDecoration(
                      color: playlist.backgroundColor ?? Colors.transparent,
                      borderRadius: BorderRadius.circular(10)),
                  child: Image.network(
                    playlist.imageUrl,
                    width: 150,
                    height: 150,
                  )),
              const SizedBox(height: 15),
              Text(playlist.name, style: _nameTextStyle),
              const SizedBox(height: 15),
              OutlinedButton(
                onPressed: () {},
                child: Text(AppLocalizations.of(context)!.follow),
                style: OutlinedButton.styleFrom(
                    side: const BorderSide(width: 0.5, color: Colors.white),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50))),
              ),
              const SizedBox(height: 15),
              FutureBuilder<List<VideoInfo>>(
                future: playlist.getVideosInfo(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListBody(
                      children: snapshot.data!
                          .map((e) => SongItem(e.title, e.thumbnail, url: e.url))
                          .toList(),
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              )
            ])
          ]))
        ]));
  }
}
