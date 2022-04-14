import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:holomusic/Common/Playlist/PlaylistOffline.dart';
import 'package:holomusic/Common/Storage/PlaylistStorage.dart';
import 'package:holomusic/ServerRequests/User.dart';
import 'package:holomusic/Views/Home/Components/PlayListWidget.dart';
import 'package:holomusic/Views/Playlist/PlaylistView.dart';

import '../../Common/Player/Song.dart';
import '../../Common/Playlist/PlaylistBase.dart';
import '../../Common/Playlist/Providers/TheGotOfficial.dart';
import '../../UIComponents/NotificationShimmer.dart';
import '../ProfileView/LoginView.dart';

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
  late Future<List<Widget>> _yourLastPlaylist;

  @override
  initState() {
    super.initState();
    chartsWidgets = <Widget>[
      PlayListWidget(playlist: TheGotOfficial("it"), onClick: onClicked),
      PlayListWidget(playlist: TheGotOfficial("it"), onClick: onClicked),
      PlayListWidget(playlist: TheGotOfficial("es"), onClick: onClicked)
    ];
    _yourLastPlaylist = loadLastPlaylist();
  }

  Future<List<Widget>> loadLastPlaylist() async {
    final playlists = await PlaylistStorage.getAllPlaylists();
    playlists.sort((a, b) => a.lastUpdate.compareTo(b.lastUpdate));
    final widgetList = playlists.reversed.toList().take(3).map((e) {
      return Row(
          children: [PlayListWidget(playlist: e, onClick: onClicked), const SizedBox(width: 15)]);
    }).toList(growable: false);
    return widgetList;
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
      return NotificationShimmer(
          elementsToLoad: 4,
          notificationId: 'playlistwidget',
          child: SingleChildScrollView(
              child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => LoginView()),
                            ).then((value) {
                              setState(() {});
                            });
                          },
                          child: Icon(
                              UserRequest.isLogin()
                                  ? Icons.manage_accounts_rounded
                                  : Icons.manage_accounts_outlined,
                              size: 30,
                              color: Colors.white)))
                ],
              ),
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
              FutureBuilder<List<Widget>>(
                future: _yourLastPlaylist,
                builder: (_, snapshot) {
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return Column(children: [
                      Text(AppLocalizations.of(context)!.yourRecentPlaylist, style: textStyle),
                      const Divider(height: 10, color: Colors.transparent),
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(8),
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: snapshot.data!,
                        ),
                      )
                    ]);
                  } else {
                    return const SizedBox();
                  }
                },
              ),
              Text(AppLocalizations.of(context)!.offlineContent, style: textStyle),
              const Divider(height: 10, color: Colors.transparent),
              PlayListWidget(playlist: PlaylistOffline(context), onClick: onClicked)
            ],
          )));
    } else {
      return PlaylistView(_playListToView!, onBackPressed);
    }
  }
}
