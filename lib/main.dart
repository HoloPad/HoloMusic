import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:holomusic/Common/PlayerEngine.dart';
import 'package:holomusic/UIComponents/PlayBar.dart';
import 'package:holomusic/Views/Search/SearchView.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:holomusic/Common/VideoHandler.dart';

void main() {
  PlayerEngine.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static late final AudioPlayer player;

  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: 'Holo Music'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedNavigationBarElement = 1;
  VideoHandler? _videoHandler;
  late List<Widget> pageList;
  bool _playBarMustBeShown = false;

  void _onNavigationBarTappedItem(int index) {
    setState(() {
      _selectedNavigationBarElement = index;
    });
  }

  void _startSong(VideoHandler handler) {
    setState(() {
      _videoHandler = handler;
    });
  }

  _MyHomePageState() {
    pageList = [
      Text("To implement"),
      SearchView(playSongFunction: _startSong),
      Text("To implement"),
    ];
  }

  _getBarWidget(LoadingState state) {
    final a = List<Widget>.empty(growable: true);

    if (state == LoadingState.loading) {
      a.add(const Flexible(child: LinearProgressIndicator()));
    }
    if (state == LoadingState.loaded || _playBarMustBeShown) {
      a.add(Flexible(child: PlayBar(handler: _videoHandler!)));
      _playBarMustBeShown = true;
    }
    return a;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: pageList[_selectedNavigationBarElement],
      //bottomSheet: _videoHandler != null ? PlayBar(handler: _videoHandler!) : null,
      bottomSheet: StreamBuilder<LoadingState>(
          stream: _videoHandler?.getVideoState(),
          initialData: LoadingState.initialized,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final state = snapshot.data!;
              return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: _getBarWidget(state));
            }
            return const SizedBox();
          }),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedNavigationBarElement,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Search",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Playlist")
        ],
        onTap: _onNavigationBarTappedItem,
      ),
    );
  }
}
