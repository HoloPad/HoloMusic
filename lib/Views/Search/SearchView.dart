import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:holomusic/UIComponents/SongItem.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:holomusic/Common/VideoHandler.dart';
import 'package:holomusic/UIComponents/PlayBar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SearchView extends StatefulWidget {
  const SearchView({Key? key}) : super(key: key);

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  late YoutubeExplode _youtubeExplode;
  Future<SearchList?>? _searchResults;

  bool _isLoadingData = false;

  _SearchViewState() {
    _youtubeExplode = YoutubeExplode();
  }

  void _onSubmitted(String query) {
    final queryRes = _youtubeExplode.search.getVideos(query);
    setState(() {
      _searchResults = queryRes;
    });
  }

  Future<SearchList?> _loadNextPage() async {
    final currentStream = await _searchResults;
    final nextStream = await currentStream?.nextPage();
    if (nextStream != null) currentStream?.addAll(nextStream);
    setState(() {
      _isLoadingData = false;
    });
    return currentStream;
  }

  void _getNextPage() {
    setState(() {
      _isLoadingData = true;
      _searchResults = _loadNextPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: PlayBar.isVisible
            ? const EdgeInsets.only(bottom: 40)
            : const EdgeInsets.all(0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextField(
              style: const TextStyle(color:Colors.white), //Text entered by the user
              decoration: InputDecoration(
                labelStyle:
                    const TextStyle(color: Color.fromRGBO(200, 200, 200, 1)),
                enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                border: const OutlineInputBorder(),
                labelText: AppLocalizations.of(context)!.searchASong,
                icon: const Icon(Icons.search, color: Colors.white),
              ),
              onSubmitted: _onSubmitted,
            ),
            FutureBuilder<SearchList?>(
              future: _searchResults,
              builder:
                  (BuildContext context, AsyncSnapshot<SearchList?> snapshot) {
                if (snapshot.hasData) {
                  final list = snapshot.data!;
                  return Expanded(
                      child: NotificationListener<ScrollNotification>(
                          onNotification: (notification) {
                            if (notification.metrics.extentAfter < 20 &&
                                !_isLoadingData) {
                              //Loads new songs
                              _getNextPage();
                            }
                            return true; //To stop the notification bubble
                          },
                          child: ListView(
                            clipBehavior: Clip.antiAlias,
                            children: list
                                .map((p0) => SongItem(
                                      p0.title,
                                      p0.thumbnails.lowResUrl,
                                      video: p0,
                                    ))
                                .toList(),
                          )));
                } else {
                  return Text("No data");
                }
              },
            ),
            if (_isLoadingData) ...[const LinearProgressIndicator()]
          ],
        ));
  }
}
