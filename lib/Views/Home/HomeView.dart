import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:holomusic/Common/Playlist/PlaylistOffline.dart';
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
      return Column(
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
          Text(AppLocalizations.of(context)!.offlineContent, style: textStyle),
          const Divider(height: 10, color: Colors.transparent),
          PlayListWidget(playlist: PlaylistOffline(context), onClick: onClicked)
        ],
      );
    } else {
      return PlaylistView(_playListToView!, onBackPressed);
    }
  }
}
