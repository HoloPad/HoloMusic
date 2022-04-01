import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:holomusic/Common/Parameters/AppStyle.dart';
import 'package:holomusic/Common/Playlist/PlaylistBase.dart';
import 'package:holomusic/UIComponents/CommonComponents.dart';

class PlaylistOptions extends StatelessWidget {
  PlaylistBase playlistInterface;

  PlaylistOptions(this.playlistInterface, {Key? key}) : super(key: key);

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
                    future: playlistInterface.getImageProvider(),
                    builder: (_, snapshot) {
                      return ExtendedImage(
                        image: snapshot.data ??
                            const AssetImage(
                                "resources/png/fake_thumbnail.png"),
                        width: 150,
                        height: 150,
                        fit: BoxFit.fill,
                        //loadStateChanged: _onImageLoaded,
                      );
                    }),
                const SizedBox(height: 15),
                Text(playlistInterface.name, style: AppStyle.titleStyle),
                const SizedBox(height: 20),
                CommonComponents.generateButton(
                    text: AppLocalizations.of(context)!.saveOfflineAllSongs,
                    icon: Icons.download_outlined,
                    onClick: () {
                      playlistInterface.downloadAllSongs();
                      Navigator.pop(context);
                    }),
                CommonComponents.generateButton(
                    text: AppLocalizations.of(context)!.deleteDownloadedSongs,
                    icon: Icons.delete_outline_rounded,
                    onClick: () {
                      playlistInterface.deleteAllSongs();
                      Navigator.pop(context);
                    }),
                CommonComponents.generateButton(
                    text: AppLocalizations.of(context)!.deletePlaylist,
                    icon: Icons.delete_sweep_outlined,
                    onClick: () {
                      playlistInterface
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
