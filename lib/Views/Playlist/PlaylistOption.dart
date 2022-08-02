import 'dart:io';

import 'package:android_long_task/android_long_task.dart';
import 'package:android_long_task/long_task/notification_components/button.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:holomusic/Common/Parameters/AppStyle.dart';
import 'package:holomusic/Common/Player/Song.dart';
import 'package:holomusic/Common/Playlist/PlaylistBase.dart';
import 'package:holomusic/Common/Playlist/PlaylistSaved.dart';
import 'package:holomusic/UIComponents/CommonComponents.dart';
import 'package:holomusic/ServerRequests/UserRequest.dart';
import 'package:oktoast/oktoast.dart';
import '../../Common/Player/SongStateManager.dart';

class OnServerButton extends StatefulWidget {
  late PlaylistBase playlist;
  late BuildContext context;

  OnServerButton(PlaylistBase playlist, BuildContext context) {
    this.playlist = playlist;
    this.context = context;
  }

  @override
  OnServerButtonState createState() => new OnServerButtonState(playlist, context);
}

class OnServerButtonState extends State<OnServerButton> {
  late PlaylistBase playlist;
  late BuildContext context;
  late IconData icon;
  String displayedString = "";

  OnServerButtonState(PlaylistBase playlist, BuildContext context) {
    this.playlist = playlist;
    this.context = context;
    if (!this.playlist.isOnServer) {
      this.displayedString = AppLocalizations.of(this.context)!.makePublicPlaylist;
      this.icon = Icons.key_off;
    } else {
      this.displayedString = AppLocalizations.of(this.context)!.makePrivatePlaylist;
      this.icon = Icons.key;
    }
  }

  void onPressed() async {
    bool res = false;
    if (!UserRequest.isLogin() || playlist.runtimeType != PlaylistSaved) return;
    if (this.playlist.isOnServer) {
      res = await UserRequest.makePlaylistPrivate(playlist);
    } else {
      res = await UserRequest.makePlaylistPublic(playlist);
    }

    setState(() {
      if (UserRequest.isLogin() && playlist.runtimeType == PlaylistSaved) {
        if (this.playlist.isOnServer) {
          if (res) {
            playlist.isOnServer = !playlist.isOnServer;
            this.displayedString = AppLocalizations.of(this.context)!.makePublicPlaylist;
            this.icon = Icons.key_off;
          }
        } else {
          if (res) {
            playlist.isOnServer = !playlist.isOnServer;
            this.displayedString = AppLocalizations.of(this.context)!.makePrivatePlaylist;
            this.icon = Icons.key;
          }
        }
        (playlist as PlaylistSaved).save();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CommonComponents.generateButton(text: displayedString, icon: icon, onClick: onPressed),
      CommonComponents.generateButton(
          text: AppLocalizations.of(context)!.addToFavorite,
          icon: Icons.add,
          onClick: () {
            final id = (playlist as PlaylistSaved).id;
            if (id == null) {
              OKToast(
                  child: Text(AppLocalizations.of(context)!.cantAddToFavorite),
                  position: ToastPosition.bottom);
            } else {
              print("Adding $id to favorites");
            }
          }),
    ]);
  }
}

class PlaylistOptions extends StatelessWidget {
  PlaylistBase playlist;
  AppClient appClient = AppClient("Download", "Download in corso");

  PlaylistOptions(this.playlist, {Key? key}) : super(key: key);

  void _startDownload() async {
    playlist.setIsDownloading(true);
    if (Platform.isAndroid) {
      //Listen for shared data updates
      appClient.userDataUpdates.listen((json) {
        final hasFinish = json?["hasFinish"] as bool;
        final currentProcessing = json?['currentSong'] as String?;
        final currentProcessingStateIndex = json?['currentProcessingState'] as int?;

        if (currentProcessing != null && currentProcessingStateIndex != null) {
          SongStateManager.setSongState(
              currentProcessing, SongState.values.elementAt(currentProcessingStateIndex));
        }

        if (hasFinish) {
          playlist.setIsDownloading(false);
        }
      });

      appClient.buttonUpdates.listen((buttonId) {
        if (buttonId == "cancel_button") {
          _cancelDownload();
        }
      });

      List<String> songsIds = (await playlist.getSongs()).map((e) => e.id).toList();
      appClient.setKeyValue("songs", songsIds);

      appClient.initProgressBar(0, songsIds.length, false);
      appClient.addButton(Button("cancel_button", "Cancel"));
      await appClient.execute();
    } else {
      await playlist.downloadAllSongs();
    }
    //If it is a user playlist, it must be saved to updated the file paths
    if (playlist.runtimeType == PlaylistSaved) {
      (playlist as PlaylistSaved).save();
    }
    if (!Platform.isAndroid) {
      playlist.setIsDownloading(false);
    }
  }

  Future _recomputeSongStates() async {
    final songs = await playlist.getSongs();
    for (var e in songs) {
      bool isOnline = await e.isOnline();
      e.setSongState(isOnline ? SongState.online : SongState.offline);
    }
  }

  void _cancelDownload() async {
    if (Platform.isAndroid) {
      await appClient.stopService();
      await _recomputeSongStates();
    } else {
      playlist.stopDownload();
    }
    playlist.setIsDownloading(false);
  }

  void _deleteDownloadedSongs() async {
    await playlist.deleteAllSongs();
    if (playlist.runtimeType == PlaylistSaved) {
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
                        image:
                            snapshot.data ?? const AssetImage("resources/png/fake_thumbnail.png"),
                        width: 150,
                        height: 150,
                        fit: BoxFit.fill,
                      );
                    }),
                const SizedBox(height: 15),
                Text(playlist.name, style: AppStyle.titleStyle),
                const SizedBox(height: 20),
                FutureBuilder<bool>(
                  future: playlist.areAllSongsSaved(),
                  builder: (_, snapshot) {
                    if (snapshot.hasData && (snapshot.data!) == false) {
                      return CommonComponents.generateButton(
                          text: AppLocalizations.of(context)!.saveOfflineAllSongs,
                          icon: Icons.download_outlined,
                          onClick: () {
                            _startDownload();
                            Navigator.pop(context);
                          });
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: playlist.isDownloading,
                  builder: (_, value, __) {
                    if (value) {
                      return CommonComponents.generateButton(
                          text: AppLocalizations.of(context)!.cancelDownload,
                          icon: Icons.cancel_outlined,
                          onClick: () {
                            _cancelDownload();
                            Navigator.pop(context);
                          });
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
                FutureBuilder<bool>(
                  future: playlist.isAtLeastOneSaved(),
                  builder: (_, snapshot) {
                    if (snapshot.hasData && snapshot.data!) {
                      return CommonComponents.generateButton(
                          text: AppLocalizations.of(context)!.deleteDownloadedSongs,
                          icon: Icons.delete_outline_rounded,
                          onClick: () {
                            _deleteDownloadedSongs();
                            Navigator.pop(context);
                          });
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
                /*
                CommonComponents.generateButton(
                    text:  playlist.isOnServer ? "Make it private": "Make it public",
                    icon: Icons.delete_sweep_outlined,
                    onClick: () {
                      setState(() => playlist.isOnServer = !playlist.isOnServer);
                    }),
                 */
                if (UserRequest.isLogin()) OnServerButton(this.playlist, context),
                CommonComponents.generateButton(
                    text: AppLocalizations.of(context)!.deletePlaylist,
                    icon: Icons.delete_sweep_outlined,
                    onClick: () {
                      playlist.delete().then((value) => Navigator.pop(context));
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
