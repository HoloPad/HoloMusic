import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:holomusic/Common/Parameters/AppStyle.dart';
import 'package:holomusic/ServerRequests/PaginatedResponse.dart';
import 'package:holomusic/ServerRequests/UserRequest.dart';
import 'package:holomusic/Views/Search/Components/PlaylistsCard.dart';
import 'package:holomusic/Common/Playlist/PlaylistSaved.dart';




class UsersPlaylists extends StatefulWidget {
  late String username;
  late BuildContext context;

  UsersPlaylists(this.username, this.context);
  @override
  UsersPlaylistsState createState() => new UsersPlaylistsState(username, context);

}

class UsersPlaylistsState extends State<UsersPlaylists> {
  Color _mainColor = AppStyle.scaffoldBackgroundColor;
  late String username;
  late BuildContext context;
  //Future<PaginatedResponse<List<String>>>? _userSongsResults;
  Future<PaginatedResponse<List<PlaylistSaved>>>? _userSongsResults;
  bool _isLoadingData = false;

  UsersPlaylistsState(String username, BuildContext context){
    this.username = username;
    this.context = context;
    final queryRes = UserRequest.getPlaylistsFromUsername(username);
    _userSongsResults = queryRes;
    queryRes.whenComplete(() => _isLoadingData = false);
  }

  void updateUI() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {


    //final playlistItems = FutureBuilder<PaginatedResponse<List<String>>>(
    final playlistItems = FutureBuilder<PaginatedResponse<List<PlaylistSaved>>>(
        future: _userSongsResults,
        builder: (_, snapshot) {
          if (snapshot.hasData && snapshot.data!.result.isNotEmpty) {
            return Expanded(
                child: ListView(
                  children:
                  snapshot.data!.result.map((e) => PlaylistsCard(e)).toList(),
                ));
          } else {
            return const SizedBox();
          }
        });

    return Scaffold(

        body: SafeArea(
        child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
        gradient: AppStyle.getStandardPaletteWithAnotherMainColor(_mainColor)),
        child: SafeArea(child: Column(mainAxisAlignment: MainAxisAlignment.start,children: [Align(
          alignment: Alignment.topLeft, child:ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },

          style: ElevatedButton.styleFrom(
              primary: AppStyle.primaryBackground,
              padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 20),
              textStyle:
              AppStyle.textStyle,),

          child: Wrap(
            children: <Widget>[
              Icon(
                Icons.arrow_back,
                color: AppStyle.scaffoldBackgroundColor,
                size: 24.0,
              ),
              SizedBox(
                width:10,
              ),
            ],
          ),)
        ),...[playlistItems],],
    )))));

  }
}
