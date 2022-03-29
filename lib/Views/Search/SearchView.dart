import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:holomusic/Common/Player/OnlineSong.dart';
import 'package:holomusic/UIComponents/PlayBar.dart';
import 'package:holomusic/UIComponents/SongItem.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class SearchView extends StatefulWidget {
  const SearchView({Key? key}) : super(key: key);

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  late YoutubeExplode _youtubeExplode;
  Future<SearchList?>? _searchResults;
  bool _hasFocus = false;
  bool _isLoadingData = false;
  bool _isLoadingFirst = false;

  _SearchViewState() {
    _youtubeExplode = YoutubeExplode();
  }

  void _onSubmitted(String query) {
    setState(() {
      _isLoadingFirst = true;
    });
    final queryRes = _youtubeExplode.search.getVideos(query);
    setState(() {
      _searchResults = queryRes;
    });
    queryRes.whenComplete(() => setState(() {
          _isLoadingFirst = false;
        }));
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
            AnimatedPadding(
                padding: EdgeInsets.all(_hasFocus ? 0 : 8),
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeIn,
                child: Focus(
                    onFocusChange: (hasFocus) {
                      setState(() {
                        _hasFocus = hasFocus;
                      });
                    },
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      //Text entered by the user
                      decoration: InputDecoration(
                          labelStyle: const TextStyle(
                              color: Color.fromRGBO(0, 0, 0, 1)),
                          contentPadding: const EdgeInsets.all(8),
                          enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.zero),
                          focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.zero),
                          border: const OutlineInputBorder(),
                          hintText: AppLocalizations.of(context)!.searchASong,
                          hintStyle: const TextStyle(color: Colors.white),
                          suffixIcon:
                              const Icon(Icons.search, color: Colors.white),
                          fillColor: const Color.fromRGBO(34, 35, 39, 1),
                          filled: true),
                      onSubmitted: _onSubmitted,
                    ))),
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
                                .map((p0) => SongItem(OnlineSong(p0)))
                                .toList(),
                          )));
                } else {
                  return _isLoadingFirst
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator())
                      : AnimatedPadding(
                          padding: EdgeInsets.only(top: _hasFocus ? 0 : 8),
                          duration: const Duration(microseconds: 200),
                          child: AnimatedOpacity(
                              opacity: _hasFocus ? 0 : 1,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeIn,
                              child: Text(
                                AppLocalizations.of(context)!.noRecentSearch,
                                style: const TextStyle(color: Colors.white),
                              )));
                }
              },
            ),
            if (_isLoadingData) ...[const LinearProgressIndicator()]
          ],
        ));
  }
}
