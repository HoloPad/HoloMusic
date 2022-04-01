import 'package:flutter/cupertino.dart';
import 'package:holomusic/Common/Storage/SongsStorage.dart';
import 'package:holomusic/Common/Playlist/PlaylistBase.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../Player/Song.dart';

class PlaylistOffline extends PlaylistBase {
  PlaylistOffline(BuildContext context)
      : super(AppLocalizations.of(context)!.savedSongs, null , null) {
    isOnline = false;
  }

  @override
  Future<List<Song>> getSongs() async {
    final list = await SongsStorage.getOfflineSongs();
    for (var element in list) {
      element.playlist = this;
    }
    return list;
  }
}
