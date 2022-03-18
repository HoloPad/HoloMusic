import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:holomusic/Views/Search/VideoCard.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:holomusic/Common/VideoHandler.dart';
import 'package:holomusic/UIComponents/PlayBar.dart';

class SearchView extends StatefulWidget {
  final void Function(VideoHandler) playSongFunction;

  const SearchView({Key? key, required this.playSongFunction})
      : super(key: key);

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

  void _startSong(VideoHandler handler) {
    setState(() {});
    widget.playSongFunction(handler);
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
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Search a song",
                icon: Icon(Icons.search),
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
                          child: ListView.builder(
                              padding: const EdgeInsets.all(8),
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: snapshot.data?.length,
                              itemBuilder: (BuildContext context, int index) {
                                return VideoCard(
                                  video: list.elementAt(index),
                                  playSongFunction: _startSong,
                                );
                              })));
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
