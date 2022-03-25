import 'package:flutter/material.dart';
import 'package:holomusic/Views/Home/Components/PlayListWidget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:holomusic/Views/Playlist/PlaylistView.dart';

import '../../Common/Playlist/Providers/Playlist.dart';
import '../../Common/Playlist/Providers/TheGotOfficial.dart';
import '../../Common/Playlist/VideoInfo.dart';

class HomeView extends StatefulWidget {
  late Future<List<VideoInfo>> theGotOfficialChart;

  HomeView({Key? key}) : super(key: key) {
    theGotOfficialChart = TheGotOfficial("it").getVideosInfo();
  }

  @override
  State<HomeView> createState() => _HomeState();
}

class _HomeState extends State<HomeView> {
  final textStyle = const TextStyle(color: Colors.white, fontSize: 20);
  late List<Widget> chartsWidgets;
  Playlist? _playListToView;

  _HomeState() {
    chartsWidgets = <Widget>[
      PlayListWidget(playlist: TheGotOfficial("it"), onClick: onClicked),
      PlayListWidget(playlist: TheGotOfficial("it"), onClick: onClicked),
      PlayListWidget(playlist: TheGotOfficial("es"), onClick: onClicked)
    ];
  }

  void onClicked(Playlist playlist) {
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
          Expanded(
              child: ListView.separated(
            padding: const EdgeInsets.all(8),
            scrollDirection: Axis.horizontal,
            itemCount: chartsWidgets.length,
            itemBuilder: (BuildContext context, int index) {
              return chartsWidgets.elementAt(index);
            },
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(
              width: 15,
            ),
            //controller: MyScrollController(),
          )),
        ],
      );
    } else {
      return PlaylistView(_playListToView!,onBackPressed);
    }
  }
}
