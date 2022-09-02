import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:holomusic/Common/Playlist/PlaylistOffline.dart';
import 'package:holomusic/Common/Playlist/Providers/YouTubePlaylist.dart';
import 'package:holomusic/Common/Storage/PlaylistStorage.dart';
import 'package:holomusic/ServerRequests/UserRequest.dart';
import 'package:holomusic/Views/Home/Components/PlayListWidget.dart';
import 'package:holomusic/Views/Playlist/PlaylistView.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../Common/Player/Song.dart';
import '../../Common/Playlist/PlaylistBase.dart';
import '../../Common/Playlist/Providers/TheGotOfficial.dart';
import '../../UIComponents/NotificationShimmer.dart';
import '../ProfileView/UserManagerView.dart';

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
  bool userIsLogged = false;
  final _hasConnection = InternetConnectionChecker().hasConnection;

  @override
  initState() {
    super.initState();
    List<String> url = [
      //Add here more youtube playlists
      "https://www.youtube.com/watch?list=PL4fGSI1pDJn6puJdseH2Rt9sMvt9E2M4i", //Top 100 worlds
      "https://www.youtube.com/watch?list=RDCLAK5uy_nBQm8_YpP--R6zU8p3dypKm1QKqzWY6qU", //Electronic
      "https://www.youtube.com/watch?list=RDCLAK5uy_km8O-Ih1wUwDSDLdsobHb0PURoU136_5Q", //Rock
      "https://www.youtube.com/watch?list=RDCLAK5uy_ms55UKAmQE5XAkphnhV1GPaWnd6fx_5Fc", //90's
      "https://www.youtube.com/watch?list=RDCLAK5uy_lqkZ7XVUPH7IZbFwDY6zkjEM6nSCiov0E", //POP
    ];
    chartsWidgets = url
        .map((e) =>
        FutureBuilder<YoutubePlaylist>(
            future: YoutubePlaylist.createFromUrl(e),
            builder: (_, snapshot) {
              if (snapshot.hasData) {
                return PlayListWidget(playlist: snapshot.data!, onClick: onClicked);
              } else {
                return const SizedBox(
                  width: 150,
                  height: 150,
                );
              }
            }))
        .toList(growable: false);
    userIsLogged = UserRequest.isLogin();
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
                                  MaterialPageRoute(builder: (context) => UserManagerView()),
                                ).then((value) {
                                  print(userIsLogged);
                                  setState(() {
                                    userIsLogged = UserRequest.isLogin();
                                  });
                                });
                              },
                              child: Icon(
                                  userIsLogged
                                      ? Icons.manage_accounts_rounded
                                      : Icons.manage_accounts_outlined,
                                  size: 30,
                                  color: Colors.white)))
                    ],
                  ),
                  FutureBuilder<bool>(
                      future: _hasConnection,
                      builder: (_, snapshot) {
                        if (snapshot.hasData && snapshot.data != null && snapshot.data!) {
                          return Column(
                            children: [
                              Text(AppLocalizations.of(context)!.suggestions, style: textStyle),
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
                            ],
                          );
                        } else {
                          return Container(
                              margin: const EdgeInsets.fromLTRB(10, 10, 10, 20),
                              child: Text(
                                AppLocalizations.of(context)!.noInternetConnection,
                                style: const TextStyle(
                                  color: Color.fromARGB(124, 255, 255, 255),
                                  fontSize: 10,
                                ),
                              ));
                        }
                      }),
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
