import 'package:flutter/cupertino.dart';
import 'package:holomusic/Common/Parameters/AppStyle.dart';
import 'package:holomusic/Views/Home/Components/PlayListWidget.dart';

import '../../Common/Playlist/PlaylistBase.dart';
import '../../Common/Storage/PlaylistStorage.dart';
import '../../Common/Playlist/PlaylistSaved.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../Playlist/PlaylistView.dart';

class LibraryView extends StatefulWidget {
  const LibraryView({Key? key}) : super(key: key);

  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView> {
  PlaylistBase? _playListToView;

  void onClicked(PlaylistBase playlist) {
    setState(() {
      _playListToView = playlist;
    });
  }

  void onBackPressed() {
    setState(() {
      _playListToView = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_playListToView == null) {
      return Padding(
          padding: const EdgeInsets.all(16),
          child: Align(
              child: Column(children: [
            Text(AppLocalizations.of(context)!.yourPlaylist,
                style: AppStyle.titleStyle),
            const SizedBox(height: 15),
            Expanded(
                child: SingleChildScrollView(
                    child: FutureBuilder<List<PlaylistSaved>>(
                        future: PlaylistStorage.getAllPlaylists(),
                        builder: (_, snapshot) {
                          if (snapshot.hasData) {
                            return Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 15,
                              runSpacing: 10,
                              children: snapshot.data!
                                  .map((e) => PlayListWidget(
                                      playlist: e, onClick: onClicked))
                                  .toList(),
                            );
                          } else {
                            return const SizedBox();
                          }
                        })))
          ])));
    } else {
      return PlaylistView(_playListToView!, onBackPressed);
    }
  }
}