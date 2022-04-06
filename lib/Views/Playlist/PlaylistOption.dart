import 'dart:io';

import 'package:android_long_task/android_long_task.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:holomusic/Common/ForegroundService/SharedDownloadData.dart';
import 'package:holomusic/Common/Parameters/AppStyle.dart';
import 'package:holomusic/Common/Player/Song.dart';
import 'package:holomusic/Common/Player/SongStateManager.dart';
import 'package:holomusic/Common/Playlist/PlaylistBase.dart';
import 'package:holomusic/Common/Playlist/PlaylistSaved.dart';
import 'package:holomusic/UIComponents/CommonComponents.dart';

class PlaylistOptions extends StatelessWidget {
  PlaylistBase playlist;

  PlaylistOptions(this.playlist, {Key? key}) : super(key: key);

  void _startDownload(BuildContext context) async {
    if (Platform.isAndroid) {
      //Listen for shared data updates
      AppClient.updates.listen((json) {
        var serviceDataUpdate = SharedDownloadData.fromJson(json!);
        SongStateManager.setSongState(serviceDataUpdate.getProcessingId(),
            serviceDataUpdate.currentProcessingState);
      });

      SharedDownloadData sharedDownloadData = SharedDownloadData();
      sharedDownloadData.songs =
          (await playlist.getSongs()).map((e) => e.id).toList();
      await AppClient.execute(sharedDownloadData);
    } else {
      await playlist.downloadAllSongs();
    }
    //If it is a user playlist, it must be saved to updated the file paths
    if (playlist.runtimeType == PlaylistSaved) {
      (playlist as PlaylistSaved).save();
    }
  }

  void _recomputeSongStates() async {
    final songs = await playlist.getSongs();
    for (var e in songs) {
      bool isOnline = await e.isOnline();
      e.setSongState(isOnline ? SongState.online : SongState.offline);
    }
  }

  void _cancelDownload(BuildContext context) async {
    if (Platform.isAndroid) {
      AppClient.stopService();
      _recomputeSongStates();
    } else {
      playlist.stopDownload();
    }
    Navigator.pop(context);
  }

  void _onDeleteDownloadedSongClicked() async {
    await playlist.deleteAllSongs();
    if(playlist.runtimeType == PlaylistSaved){
      (playlist as PlaylistSaved).save();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          padding: const EdgeInsets.all(16),
          decoration: AppStyle.scaffoldDecoration,
          child: Align(
              child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FutureBuilder<ImageProvider<Object>>(
                    future: playlist.getImageProvider(),
                    builder: (_, snapshot) {
                      return ExtendedImage(
                        image: snapshot.data ??
                            const AssetImage(
                                "resources/png/fake_thumbnail.png"),
                        width: 150,
                        height: 150,
                        fit: BoxFit.fill,
                      );
                    }),
                const SizedBox(height: 15),
                Text(playlist.name, style: AppStyle.titleStyle),
                const SizedBox(height: 20),
                CommonComponents.generateButton(
                    text: AppLocalizations.of(context)!.saveOfflineAllSongs,
                    icon: Icons.download_outlined,
                    onClick: () {
                      _startDownload(context);
                      Navigator.pop(context);
                    }),
                CommonComponents.generateButton(
                    text: "Cancel download",
                    icon: Icons.cancel_outlined,
                    onClick: () => _cancelDownload(context)),
                CommonComponents.generateButton(
                    text: AppLocalizations.of(context)!.deleteDownloadedSongs,
                    icon: Icons.delete_outline_rounded,
                    onClick: () {
                      _onDeleteDownloadedSongClicked();
                      Navigator.pop(context);
                    }),
                CommonComponents.generateButton(
                    text: AppLocalizations.of(context)!.deletePlaylist,
                    icon: Icons.delete_sweep_outlined,
                    onClick: () {
                      playlist
                          .delete()
                          .then((value) => Navigator.pop(context));
                    }),
                const SizedBox(height: 15),
                CommonComponents.generateButton(
                    text: AppLocalizations.of(context)!.cancel,
                    onClick: () => Navigator.pop(context),
                    opacity: 0.5),
              ],
            ),
          ))),
    );
  }
}
