import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:holomusic/Common/PlayerEngine.dart';
import 'package:holomusic/Common/class%20LoadingNotification.dart';
import 'package:holomusic/UIComponents/PlayBar.dart';
import 'package:holomusic/Views/Home/HomeView.dart';
import 'package:holomusic/Views/Search/SearchView.dart';
import 'package:just_audio/just_audio.dart';
import 'package:holomusic/Common/VideoHandler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
      onGenerateTitle: (context) {
        return AppLocalizations.of(context)!.appTitle;
      },
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        // 'en' is the language code. We could optionally provide a
        // a country code as the second param, e.g.
        // Locale('en', 'US'). If we do that, we may want to
        // provide an additional app_en_US.arb file for
        // region-specific translations.
        Locale('it', ''),
        Locale('en', ''),
      ],
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: 'HoloMusic'),
      scrollBehavior: MyCustomScrollBehavior(),
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
  late List<Widget> pageList;
  bool _playBarMustBeShown = false;
  bool _forceLoading = false;

  void _onNavigationBarTappedItem(int index) {
    setState(() {
      _selectedNavigationBarElement = index;
    });
  }

  _MyHomePageState() {
    pageList = [
      HomeView(),
      SearchView(),
      Text("To implement"),
    ];
  }

  _getBarWidget(ProcessingState state) {
    final a = List<Widget>.empty(growable: true);
    if (state == ProcessingState.buffering ||
        state == ProcessingState.loading ||
        _forceLoading) {
      a.add(const Flexible(child: LinearProgressIndicator()));
    }
    if (state == ProcessingState.ready || _playBarMustBeShown) {
      a.add(const Flexible(child: PlayBar()));
      _playBarMustBeShown = true;
    }
    return a;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue, Color.fromRGBO(18, 18, 18, 1)],
                stops: [0.01, 0.4])),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: NotificationListener<LoadingNotification>(
              onNotification: (notification) {
                setState(() {
                  _forceLoading = notification.isLoading;
                });
                return true;
              },
              child: pageList[_selectedNavigationBarElement]),
          bottomSheet: StreamBuilder<ProcessingState>(
              stream: PlayerEngine.player.processingStateStream,
              initialData: ProcessingState.idle,
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
            backgroundColor: const Color.fromRGBO(34, 35, 39, 1.0),
            selectedItemColor: Colors.white,
            unselectedItemColor: const Color.fromRGBO(124, 125, 129, 1),
            currentIndex: _selectedNavigationBarElement,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: const Icon(Icons.home),
                  label: AppLocalizations.of(context)!.home),
              BottomNavigationBarItem(
                icon: const Icon(Icons.search),
                label: AppLocalizations.of(context)!.search,
              ),
              BottomNavigationBarItem(
                  icon: const Icon(Icons.list),
                  label: AppLocalizations.of(context)!.library)
            ],
            onTap: _onNavigationBarTappedItem,
          ),
        ));
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        // etc.
      };
}
