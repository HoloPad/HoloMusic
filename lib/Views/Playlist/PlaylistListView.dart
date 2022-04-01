import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:holomusic/Common/Playlist/PlaylistSaved.dart';
import 'package:holomusic/Views/Home/Components/PlayListWidget.dart';
import '../../Common/Parameters/AppStyle.dart';
import '../../Common/Player/Song.dart';
import '../../Common/Playlist/PlaylistBase.dart';
import '../../Common/Storage/PlaylistStorage.dart';

class PlaylistListView extends StatelessWidget {
  final _textController = TextEditingController();
  final Song song;

  PlaylistListView(this.song, {Key? key}) : super(key: key);

  void onSavePressed(BuildContext context) async {
    final playlist = PlaylistSaved(_textController.text);
    playlist.addSong(song);
    playlist.save();
    var count = 0;
    Navigator.popUntil(context, (route) {
      return count++ == 2;
    });
  }

  void onAddToPlaylist(BuildContext context, PlaylistBase playlist) async {
    if (playlist is! PlaylistSaved) {
      return;
    }
    playlist.addSong(song);
    playlist.save();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final _newPlaylist = AlertDialog(
      backgroundColor: AppStyle.primaryBackground,
      title: Text(AppLocalizations.of(context)!.newPlaylist,
          style: AppStyle.textStyle),
      content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context)!.insertPlaylistName,
                style: AppStyle.textStyle),
            TextField(
              style: AppStyle.textStyle,
              controller: _textController,
            )
          ]),
      actions: <Widget>[
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel)),
        TextButton(
            onPressed: () => onSavePressed(context),
            child: Text(AppLocalizations.of(context)!.save,
                style: AppStyle.textStyle)),
      ],
    );

    return Scaffold(
        body: SafeArea(
            child: Container(
                padding: const EdgeInsets.all(20),
                decoration:
                    BoxDecoration(gradient: AppStyle.backgroundGradient),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Icon(Icons.arrow_back_ios,
                                  color: Colors.white))
                        ],
                      ),
                      Expanded(
                          child: SingleChildScrollView(
                        child: Column(
                          children: [
                            OutlinedButton(
                                onPressed: () => showDialog(
                                    context: context,
                                    builder: (ctx) => _newPlaylist),
                                child: Text(
                                    AppLocalizations.of(context)!.newPlaylist,
                                    style: TextStyle(color: AppStyle.text)),
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25)),
                                  padding: const EdgeInsets.all(15),
                                  backgroundColor: AppStyle.primaryBackground,
                                )),
                            const SizedBox(height: 20),
                            Text(
                              AppLocalizations.of(context)!
                                  .selectWhereToSavePlaylist,
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.white),
                            ),
                            const SizedBox(height: 20),
                            FutureBuilder<List<PlaylistSaved>>(
                                future: PlaylistStorage.getAllPlaylists(),
                                builder: (_, snapshot) {
                                  if (snapshot.hasData) {
                                    return Wrap(
                                      spacing: 10,
                                      children: snapshot.data!
                                          .map((e) => PlayListWidget(
                                              playlist: e,
                                              onClick: (plt) => onAddToPlaylist(
                                                  context, plt)))
                                          .toList(),
                                    );
                                  } else {
                                    return const SizedBox();
                                  }
                                })
                          ],
                        ),
                      ))
                    ]))));
  }
}
