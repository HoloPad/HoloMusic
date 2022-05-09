import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:holomusic/Common/Notifications/ReRenderNotification.dart';
import 'package:holomusic/Common/Parameters/AppStyle.dart';
import 'package:holomusic/Common/Player/OnlineSong.dart';
import 'package:holomusic/Common/Playlist/PlaylistSearchHistory.dart';
import 'package:holomusic/Common/Storage/UserHistoryStorage.dart';
import 'package:holomusic/ServerRequests/PaginatedResponse.dart';
import 'package:holomusic/ServerRequests/UserRequest.dart';
import 'package:holomusic/UIComponents/PlayBar.dart';
import 'package:holomusic/UIComponents/SongItem.dart';
import 'package:holomusic/Views/Search/Components/ProfileCard.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../../Common/Player/Song.dart';
import '../../UIComponents/NotificationShimmer.dart';
import 'UsersPlaylists.dart';
import 'package:holomusic/Common/Playlist/PlaylistBase.dart';
import '../Playlist/PlaylistView.dart';

class SearchView extends StatefulWidget {
  const SearchView({Key? key}) : super(key: key);

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  late YoutubeExplode _youtubeExplode;
  Future<SearchList?>? _searchResults;
  Future<PaginatedResponse<List<User>>>? _userSearchResults;
  final TextEditingController _textEditingController = TextEditingController();
  UsersPlaylists? Usersplaylists;
  PlaylistBase? _playListToView;

  bool _hasFocus = false;

  bool _isLoadingData = false;
  bool _showSearchResultMusic = false;
  bool _showSearchResultUser = false;

  late PlaylistSearchHistory historyPlaylist;
  bool _searchForMusic = true;

  _SearchViewState() {
    _youtubeExplode = YoutubeExplode();
    historyPlaylist = PlaylistSearchHistory.instance();
  }

  void _onSubmitted(String query) {
    if (_searchForMusic) {
      setState(() {
        _showSearchResultMusic = true;
        _isLoadingData = true;
      });
      final queryRes = _youtubeExplode.search.getVideos(query);
      setState(() {
        _searchResults = queryRes;
      });
      queryRes.whenComplete(() => setState(() {
            _isLoadingData = false;
          }));
    } else {
      setState(() {
        _showSearchResultUser = true;
        _isLoadingData = true;
      });
      final queryRes = UserRequest.searchUserByUsername(query);
      setState(() {
        _userSearchResults = queryRes;
      });
      queryRes.whenComplete(() => setState(() {
            _isLoadingData = false;
          }));
    }
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


  void onUsersPlaylistBackPressed(){
    setState(() {
      Usersplaylists=null;
    });
  }

  void onUserClicked(String username){
    setState(() {
      Usersplaylists=UsersPlaylists(username,onUsersPlaylistBackPressed,onClicked,context);
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

  void onItemClick(Song song) async {
    historyPlaylist.addSong(song);
  }

  void updateUI() {
    setState(() {});
  }

  ButtonStyle buttonsStyleGenerator(bool isLeft, bool isSelected) {
    const double radius = 15.0;
    return OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isLeft ? radius : 0),
                bottomLeft: Radius.circular(isLeft ? radius : 0),
                topRight: Radius.circular(isLeft ? 0 : radius),
                bottomRight: Radius.circular(isLeft ? 0 : radius))),
        backgroundColor:
            isSelected ? AppStyle.primaryBackground : Colors.transparent,
        side: BorderSide(color: AppStyle.primaryBackground),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10));
  }

  @override
  Widget build(BuildContext context) {
    final selectionFieldsButtons =
    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      OutlinedButton(
          onPressed: () {
            setState(() {
              _searchForMusic = true;
            });
            _textEditingController.clear();
          },
          child: Text(AppLocalizations.of(context)!.music),
          style: buttonsStyleGenerator(true, _searchForMusic)),
      OutlinedButton(
          onPressed: () {
            setState(() {
              _searchForMusic = false;
            });
            _textEditingController.clear();
          },
          child: Text(AppLocalizations.of(context)!.users),
          style: buttonsStyleGenerator(false, !_searchForMusic)),
    ]);

    final songSearchItems = FutureBuilder<SearchList?>(
      future: _searchResults,
      builder: (_, snapshot) {
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
                  child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: ListView(
                        clipBehavior: Clip.antiAlias,
                        children: list
                            .map((p0) =>
                            SongItem(OnlineSong(p0),
                                onClickCallback: onItemClick))
                            .toList(),
                      ))));
        } else {
          return const SizedBox();
        }
      },
    );
    final lastMusicSearches = FutureBuilder<List<Song>>(
      //No search, show last searches
        future: historyPlaylist.getSongs(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            List<Widget> items = snapshot.data!
                .map((e) => SongItem(e, playlist: historyPlaylist))
                .toList();

            return Expanded(
                child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: NotificationShimmer(
                        elementsToLoad: items.length,
                        notificationId: 'songitem',
                        child: NotificationListener<ReRenderNotification>(
                            onNotification: (_) {
                              updateUI();
                              return true;
                            },
                            child: ListView(children: [...items])))));
          } else {
            return Text(
              AppLocalizations.of(context)!.noRecentSearch,
              style: const TextStyle(color: Colors.white),
            );
          }
        });

    final userSearchItems = FutureBuilder<PaginatedResponse<List<User>>>(
        future: _userSearchResults,
        builder: (_, snapshot) {
          if (snapshot.hasData && snapshot.data!.result.isNotEmpty) {
            return Expanded(
                child: ListView(
                  children:
                  snapshot.data!.result.map((e) => ProfileCard(e, onUserClicked)).toList(),
                ));
          } else {
            return const SizedBox();
          }
        });

    final lastSearchedUser = FutureBuilder<List<User>>(
      future: UserHistoryStorage.getUserHistory(),
      builder: (_, snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return Expanded(
              child: NotificationListener<ReRenderNotification>(
                  onNotification: (_) {
                    updateUI();
                    return true;
                  },
                  child: ListView(
                    children:
                    snapshot.data!.map((e) => ProfileCard(e, onUserClicked)).toList(),
                  )));
        } else {
          return const SizedBox();
        }
      },
    );


    if (_playListToView != null){
      return PlaylistView(_playListToView!, onBackPressed);

    }
    if (Usersplaylists != null) {
      return Usersplaylists!;
    }

    else {
      return Padding(
          padding: PlayBar.isVisible
              ? const EdgeInsets.only(bottom: 40)
              : const EdgeInsets.all(0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              //Search bar
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
                            hintText: _searchForMusic
                                ? AppLocalizations.of(context)!.searchASong
                                : AppLocalizations.of(context)!.searchAnUser,
                            hintStyle: const TextStyle(color: Colors.white),
                            suffixIcon:
                            const Icon(Icons.search, color: Colors.white),
                            fillColor: const Color.fromRGBO(34, 35, 39, 1),
                            filled: true),
                        onSubmitted: _onSubmitted,
                        controller: _textEditingController,
                      ))),
              AnimatedPadding(
                  padding: EdgeInsets.fromLTRB(8, _hasFocus ? 8 : 0, 8, 0),
                  duration: const Duration(milliseconds: 100),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            (_showSearchResultMusic && _searchForMusic ||
                                (_showSearchResultUser && !_searchForMusic))
                                ? AppLocalizations.of(context)!.searchResult
                                : AppLocalizations.of(context)!.recentSearch,
                            style: AppStyle.textStyle),
                        selectionFieldsButtons
                      ])),
              if (_searchForMusic && _showSearchResultMusic) ...[songSearchItems],
              if (_searchForMusic && !_showSearchResultMusic) ...[
                lastMusicSearches
              ],
              if (!_searchForMusic && _showSearchResultUser) ...[userSearchItems],
              if (!_searchForMusic && !_showSearchResultUser) ...[
                lastSearchedUser
              ],
              //LinearProgressIndicator
              if (_isLoadingData) ...[
                const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: LinearProgressIndicator())
              ]
            ],
          ));
    }
  }
}
