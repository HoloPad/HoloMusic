import 'dart:io';
import 'dart:ui';

import 'package:android_long_task/android_long_task.dart';
import 'package:android_long_task/long_task/service_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:holomusic/Common/Notifications/LoadingNotification.dart';
import 'package:holomusic/Common/Player/PlayerEngine.dart';
import 'package:holomusic/Common/Player/Song.dart';
import 'package:holomusic/Common/Player/SongStateManager.dart';
import 'package:holomusic/Common/Storage/SongsStorage.dart';
import 'package:holomusic/ServerRequests/User.dart';
import 'package:holomusic/UIComponents/PlayBar.dart';
import 'package:holomusic/Views/Home/HomeView.dart';
import 'package:holomusic/Views/Library/LibraryView.dart';
import 'package:holomusic/Views/Search/SearchView.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:localstore/localstore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import 'Common/Parameters/AppStyle.dart';
import 'Common/Player/PlayerStateController.dart';

Future<void> main() async {
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  UserRequest.init();
  SongStateManager.init();
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
      theme: ThemeData(primarySwatch: Colors.grey),
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
  int _selectedNavigationBarElement = 0;
  late List<Widget> pageList;
  PlayerStateController playerStateController = PlayerStateController();

  void _onNavigationBarTappedItem(int index) {
    setState(() {
      _selectedNavigationBarElement = index;
    });
  }

  _MyHomePageState() {
    pageList = [
      HomeView(),
      const SearchView(),
      const LibraryView(),
    ];

    PlayerEngine.getCurrentVideoHandlerPlaying().addListener(() {
      final value = PlayerEngine.getCurrentVideoHandlerPlaying().value;
      if (value != null) {
        playerStateController.isVisible(true);
      }
    });
    PlayerEngine.player.playingStream.listen((event) {
      playerStateController.isPlaying(event);
    });
    PlayerEngine.player.playerStateStream.listen((event) {
      switch (event.processingState) {
        case ProcessingState.loading:
        case ProcessingState.buffering:
          playerStateController.isLoading(true);
          break;
        case ProcessingState.ready:
        case ProcessingState.completed:
        case ProcessingState.idle:
          playerStateController.isLoading(false);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
            decoration: BoxDecoration(gradient: AppStyle.backgroundGradient),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: NotificationListener<LoadingNotification>(
                  onNotification: (notification) {
                    playerStateController.isLoading(notification.isLoading);
                    return true;
                  },
                  child: pageList[_selectedNavigationBarElement]),
              bottomSheet: NotificationListener<LoadingNotification>(
                  onNotification: (notification) {
                    playerStateController.isLoading(notification.isLoading);
                    return true;
                  },
                  child: ValueListenableBuilder<int>(
                      valueListenable:
                          playerStateController.getPlayerStateValueNotifier(),
                      builder: (context, value, child) {
                        List<Widget> children = List.empty(growable: true);
                        if (value & MyPlayerState.loading != 0) {
                          children.add(const LinearProgressIndicator());
                        }
                        if (value & MyPlayerState.visible != 0) {
                          children.add(Flexible(
                              child: PlayBar(playerStateController
                                  .getPlayerStateValueNotifier())));
                        }
                        return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: children);
                      })),
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
            )));
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

Future<bool> downloadSong(String id) async {
  final instance = YoutubeExplode();

  try {
    final video = await instance.videos.get(id);
    //get streams
    var manifest = await instance.videos.streamsClient.getManifest(video.id);
    var streamInfo = manifest.audioOnly.withHighestBitrate();
    var stream = instance.videos.streamsClient.get(streamInfo);

    //Create directories
    final docDirectory = await getApplicationDocumentsDirectory();
    final folderPath = docDirectory.path +
        Platform.pathSeparator +
        "holomusic" +
        Platform.pathSeparator +
        "offline";
    final directory = await Directory(folderPath);
    await directory.create(recursive: true);

    //Create files
    var songFile = File(
        directory.path + Platform.pathSeparator + video.id.value + ".webm");
    final imageFile =
        File(directory.path + Platform.pathSeparator + video.id.value + ".jpg");

    //Download song
    var fileStream = songFile.openWrite();
    await stream.pipe(fileStream);
    // Close the file.
    await fileStream.flush();
    await fileStream.close();

    //Download thumbnail
    final imageResponse =
        await http.get(Uri.parse(video.thumbnails.highResUrl));
    imageFile.writeAsBytes(imageResponse.bodyBytes, flush: true);

    //Store on the localstore
    await Localstore.instance
        .collection(SongsStorage.collectionName)
        .doc(id)
        .set({
      "title": video.title,
      "thumbnail": imageFile.path,
      "path": songFile.path
    });
    return true;
  } catch (_) {
    return false;
  }
}

//this entire function runs in your ForegroundService
@pragma('vm:entry-point')
serviceMain() async {
  //make sure you add this
  WidgetsFlutterBinding.ensureInitialized();
  //if your use dependency injection you initialize them here
  //what ever dart objects you created in your app main function is not  accessible here

  //set a callback and define the code you want to execute when your  ForegroundService runs
  ServiceClient.setExecutionCallback((initialData) async {
    initialData.setKeyValue('hasFinish', false);
    List<String> songs = List.from(initialData.getKeyValue('songs'));

    ServiceClient.setOnClickCallback((buttonId) async {
      initialData.setKeyValue('currentProcessingState', SongState.online.index);
      await ServiceClient.update(initialData);
      await ServiceClient.endExecution(initialData);
      await ServiceClient.stopService();
      return;
    });
    //you set initialData when you are calling AppClient.execute()
    //runs your code here
    for (int i = 0; i < songs.length; i++) {
      final id = songs[i];
      initialData.barProgress = i + 1;
      initialData.notificationDescription = "Download ${i + 1}/${songs.length}";
      initialData.setKeyValue(
          'currentProcessingState', SongState.downloading.index);
      initialData.setKeyValue('currentSong', id);
      await ServiceClient.update(initialData);

      //Check if already exists
      final element = await Localstore.instance
          .collection(SongsStorage.collectionName)
          .doc(id)
          .get();

      if (element == null) {
        bool success = false;
        int maxAttempt = 3;
        int currentAttemp = 0;
        while (!success && currentAttemp < maxAttempt) {
          success = await downloadSong(id)
              .timeout(const Duration(seconds: 60), onTimeout: () => false);
          currentAttemp++;
        }
        if (success) {
          initialData.setKeyValue(
              'currentProcessingState', SongState.offline.index);
        } else {
          initialData.setKeyValue(
              'currentProcessingState', SongState.errorOnDownloading.index);
        }
      } else {
        initialData.setKeyValue(
            'currentProcessingState', SongState.offline.index);
      }
      initialData.setKeyValue('hasFinish', true);
      await ServiceClient.update(initialData);
    }
    await ServiceClient.endExecution(initialData);
    await ServiceClient.stopService();
  });
}
