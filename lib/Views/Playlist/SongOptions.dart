import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:holomusic/Common/Player/OnlineSong.dart';
import 'package:holomusic/Common/Player/PlayerEngine.dart';
import 'package:holomusic/Common/Playlist/PlaylistBase.dart';
import 'package:holomusic/Common/Playlist/PlaylistSaved.dart';
import 'package:holomusic/Views/Playlist/PlaylistListView.dart';
import '../../Common/Storage/SongsStorage.dart';
import '../../Common/Parameters/AppStyle.dart';
import '../../Common/Player/Song.dart';
import '../../UIComponents/CommonComponents.dart';

class SongOptions extends StatelessWidget {
  Song song;
  late Image _image;
  PlaylistBase? playlist;

  SongOptions(this.song, {this.playlist, Key? key}) : super(key: key) {
    _image = Image(image: song.getThumbnailImageAsset(), height: 200);
  }

  final _titleStyle = const TextStyle(
      fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white);

  void onDownloadDeleteClick(BuildContext context, bool isOnline)async {
    if (isOnline) {
      SongsStorage.saveSong(song as OnlineSong);
      Navigator.pop(context, false);
    } else {
      await SongsStorage.deleteSongById(song.id);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            decoration: BoxDecoration(gradient: AppStyle.backgroundGradient),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Expanded(
                  child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _image,
                            const SizedBox(height: 20),
                            Flexible(
                                child: Text(
                              song.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _titleStyle,
                            )),
                            const SizedBox(height: 20),
                            //Save or delete offline
                            FutureBuilder<bool>(
                                initialData: null,
                                future: SongsStorage.isSongStoredById(song.id),
                                builder: (_, snapshot) {
                                  final isInsideSave =
                                      snapshot.hasData && snapshot.data!;
                                  return CommonComponents.generateButton(
                                      text:
                                          song.isOnline() && !isInsideSave
                                              ? AppLocalizations.of(context)!
                                                  .saveOffline
                                              : AppLocalizations.of(context)!
                                                  .deleteDownloadedSong,
                                      icon:
                                          song.isOnline() && !isInsideSave
                                              ? Icons.add
                                              : Icons.delete_outline_rounded,
                                      onClick: () {
                                        onDownloadDeleteClick(context,song.isOnline() && !isInsideSave);
                                      });
                                }),
                            CommonComponents.generateButton(
                                text:
                                    AppLocalizations.of(context)!.addToPlaylist,
                                icon: Icons.add,
                                onClick: () {
                                  Navigator.pop(context, false);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PlaylistListView(song)));
                                }),
                            (playlist != null && playlist is PlaylistSaved)
                                ? CommonComponents.generateButton(
                                    text: AppLocalizations.of(context)!
                                        .deleteSongFromPlaylist,
                                    icon: Icons.delete_outline_rounded,
                                    onClick: () {
                                      if (playlist != null &&
                                          playlist is PlaylistSaved) {
                                        (playlist as PlaylistSaved)
                                            .deleteSong(song, save: true);
                                      }
                                      Navigator.pop(context, true);
                                    })
                                : const SizedBox(),
                            CommonComponents.generateButton(
                                text: AppLocalizations.of(context)!.addToQueue,
                                icon: Icons.add,
                                onClick: () {
                                  PlayerEngine.addSongToQueue(song);
                                  Navigator.pop(context, false);
                                }),
                            const SizedBox(height: 15),
                            CommonComponents.generateButton(
                                text: AppLocalizations.of(context)!.cancel,
                                onClick: () => Navigator.pop(context, false),
                                opacity: 0.5),
                          ]))),
            ])));
  }
}
