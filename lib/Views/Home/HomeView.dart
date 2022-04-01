import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:holomusic/Common/Notifications/ShimmerLoadingNotification.dart';
import 'package:holomusic/Common/Parameters/AppStyle.dart';
import 'package:holomusic/Common/Playlist/PlaylistOffline.dart';
import 'package:holomusic/UIComponents/Shimmer.dart';
import 'package:holomusic/Views/Home/Components/PlayListWidget.dart';
import 'package:holomusic/Views/Playlist/PlaylistView.dart';

import '../../Common/Player/Song.dart';
import '../../Common/Playlist/PlaylistBase.dart';
import '../../Common/Playlist/Providers/TheGotOfficial.dart';

class HomeView extends StatefulWidget {
  late Future<List<Song>> theGotOfficialChart;

  HomeView({Key? key}) : super(key: key) {
    theGotOfficialChart = TheGotOfficial("it").getSongs();
  }

  @override
  State<HomeView> createState() => _HomeState();
}

class _HomeState extends State<HomeView> {
  final textStyle = const TextStyle(color: Colors.white, fontSize: 20);
  late List<Widget> chartsWidgets;
  PlaylistBase? _playListToView;
  int elementsToLoad = 0;
  bool loadingComplete = false;

  _HomeState() {
    chartsWidgets = <Widget>[
      PlayListWidget(playlist: TheGotOfficial("it"), onClick: onClicked),
      PlayListWidget(playlist: TheGotOfficial("it"), onClick: onClicked),
      PlayListWidget(playlist: TheGotOfficial("es"), onClick: onClicked)
    ];
  }

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
      return Shimmer.fromColors(
          baseColor: AppStyle.ShimmerColorBase,
          highlightColor: AppStyle.ShimmerColorBackground,
          enabled: !loadingComplete,
          child: NotificationListener<ShimmerLoadingNotification>(
              onNotification: (not) {
                if (not.id != "playlistwidget") return true;
                elementsToLoad++;
                if (elementsToLoad == 4) {
                  SchedulerBinding.instance?.addPostFrameCallback((timeStamp) {
                    setState(() {
                      loadingComplete = true;
                    });
                  });
                }
                print("HERE"+ elementsToLoad.toString() + not.id);
                return true;
              },
              child: Column(
                children: [
                  Text(AppLocalizations.of(context)!.charts, style: textStyle),
                  const Divider(height: 10, color: Colors.transparent),
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(8),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: chartsWidgets.map((e) {
                        return Row(children: [e, const SizedBox(width: 15)]);
                      }).toList(),
                    ),
                  ),
                  Text(AppLocalizations.of(context)!.offlineContent,
                      style: textStyle),
                  const Divider(height: 10, color: Colors.transparent),
                  PlayListWidget(
                      playlist: PlaylistOffline(context), onClick: onClicked)
                ],
              )));
    } else {
      return PlaylistView(_playListToView!, onBackPressed);
    }
  }
}
