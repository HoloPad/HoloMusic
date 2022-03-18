import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:holomusic/UIComponents/PlayBar.dart';
import 'package:holomusic/Views/Search/SearchView.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:holomusic/Common/VideoHandler.dart';

void main() {
  VideoHandler.player=AudioPlayer();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: pageList[_selectedNavigationBarElement],
      bottomSheet: _videoHandler != null ? PlayBar(handler: _videoHandler!) : null,
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
