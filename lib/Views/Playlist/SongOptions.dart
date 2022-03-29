import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:holomusic/Common/Player/OfflineSong.dart';
import 'package:holomusic/Common/Player/OnlineSong.dart';
import 'package:holomusic/Common/Player/PlayerEngine.dart';
import 'dart:io';
import '../../Common/Offline/OfflineStorage.dart';
import '../../Common/Parameters/AppColors.dart';
import '../../Common/Player/Song.dart';

class SongOptions extends StatelessWidget {
  Song song;
  late Image _image;

  SongOptions(this.song, {Key? key}) : super(key: key) {
    if (song.isOnline()) {
      _image = Image(image: NetworkImage(song.getThumbnail()), height: 200);
    } else {
      _image = Image(image: FileImage(File(song.getThumbnail())), height: 200);
    }
  }

  final _titleStyle = const TextStyle(
      fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
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
                            FutureBuilder<bool>(
                                initialData: null,
                                future: OfflineStorage.isSongStoredById(song.id),
                                builder: (_, snapshot) {
                                  bool foundBetweenSaved = snapshot.hasData && snapshot.data!;
                                  return TextButton(
                                      onPressed: () {
                                        if (song.isOnline() &&
                                            !foundBetweenSaved) {
                                          OfflineStorage.saveSong(
                                              song as OnlineSong);
                                        } else {
                                          OfflineStorage.deleteSong(
                                              song as OfflineSong);
                                        }
                                        Navigator.pop(context);
                                      },
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(song.isOnline() &&
                                                    !foundBetweenSaved
                                                ? AppLocalizations.of(context)!
                                                    .saveOffline
                                                : AppLocalizations.of(context)!
                                                    .deleteSong),
                                            const SizedBox(width: 5),
                                            const Icon(Icons.add)
                                          ]));
                                }),
                            const SizedBox(height: 20),
                            TextButton(
                                onPressed: () {
                                  PlayerEngine.addSongToQueue(song);
                                  Navigator.pop(context);
                                },
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(AppLocalizations.of(context)!
                                          .addToQueue),
                                      const SizedBox(width: 5),
                                      const Icon(Icons.add)
                                    ])),
                            const SizedBox(height: 20),
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                          AppLocalizations.of(context)!.cancel),
                                      const SizedBox(width: 5),
                                      const Icon(Icons.cancel)
                                    ])),
                            const SizedBox(height: 20)
                          ]))),
            ])));
  }
}
