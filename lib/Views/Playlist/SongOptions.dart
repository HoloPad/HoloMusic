import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:holomusic/Common/Player/PlayerEngine.dart';
import 'package:holomusic/Common/Playlist/PlaylistBase.dart';
import 'package:holomusic/Common/Playlist/PlaylistSaved.dart';
import 'package:holomusic/Views/Playlist/PlaylistListView.dart';

import '../../Common/Parameters/AppStyle.dart';
import '../../Common/Parameters/PlatformSize.dart';
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

  void onDownloadOrDeleteClick(bool isOnline) async {
    if (isOnline) {
      await song.saveSong();
    } else {
      await song.deleteSong();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Container(
                decoration:
                    BoxDecoration(gradient: AppStyle.backgroundGradient),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Expanded(
                      child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _image,
                                SizedBox(height: PlatformSize.sizedBoxSpaceL),
                                Flexible(
                                    child: Text(
                                  song.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: _titleStyle,
                                )),
                                SizedBox(height: PlatformSize.sizedBoxSpaceL),
                                //Save or delete offline
                                FutureBuilder<bool>(
                                    initialData: true,
                                    future: song.isOnline(),
                                    builder: (_, snapshot) {
                                      final isOnline = snapshot.data ?? true;
                                      return CommonComponents.generateButton(
                                          text: isOnline
                                              ? AppLocalizations.of(context)!
                                                  .saveOffline
                                              : AppLocalizations.of(context)!
                                                  .deleteDownloadedSong,
                                          icon: isOnline
                                              ? Icons.add
                                              : Icons.delete_outline_rounded,
                                          onClick: () {
                                            onDownloadOrDeleteClick(isOnline);
                                            Navigator.pop(context, false);
                                          });
                                    }),
                                CommonComponents.generateButton(
                                    text: AppLocalizations.of(context)!
                                        .addToPlaylist,
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
                                    text: AppLocalizations.of(context)!
                                        .addToQueue,
                                    icon: Icons.add,
                                    onClick: () {
                                      PlayerEngine.addSongToQueue(song);
                                      Navigator.pop(context, false);
                                    }),
                                SizedBox(height: PlatformSize.sizedBoxSpaceL),
                                CommonComponents.generateButton(
                                    text: AppLocalizations.of(context)!.cancel,
                                    onClick: () =>
                                        Navigator.pop(context, false),
                                    opacity: 0.5),
                              ]))),
                ]))));
  }
}
