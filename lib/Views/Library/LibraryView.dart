import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:holomusic/Common/Parameters/AppStyle.dart';
import 'package:holomusic/Views/Home/Components/PlayListWidget.dart';

import '../../Common/Notifications/ShimmerLoadingNotification.dart';
import '../../Common/Playlist/PlaylistBase.dart';
import '../../Common/Storage/PlaylistStorage.dart';
import '../../Common/Playlist/PlaylistSaved.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../UIComponents/Shimmer.dart';
import '../Playlist/PlaylistView.dart';

class LibraryView extends StatefulWidget {
  const LibraryView({Key? key}) : super(key: key);

  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView> {
  PlaylistBase? _playListToView;
  bool _loadingComplete = false;
  var _elementsToLoad = 0;

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
                            return Shimmer.fromColors(
                                baseColor: AppStyle.ShimmerColorBase,
                                highlightColor: AppStyle.ShimmerColorBackground,
                                enabled: !_loadingComplete,
                                child: NotificationListener<
                                        ShimmerLoadingNotification>(
                                    onNotification: (not) {
                                      if (not.id != "playlistwidget")
                                        return true;
                                      _elementsToLoad++;
                                      if (_elementsToLoad ==
                                          snapshot.data!.length) {
                                        SchedulerBinding.instance
                                            ?.addPostFrameCallback((timeStamp) {
                                          setState(() {
                                            _loadingComplete = true;
                                          });
                                        });
                                      }
                                      return true;
                                    },
                                    child: Wrap(
                                      alignment: WrapAlignment.center,
                                      spacing: 15,
                                      runSpacing: 10,
                                      children: snapshot.data!
                                          .map((e) => PlayListWidget(
                                              playlist: e, onClick: onClicked))
                                          .toList(),
                                    )));
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
