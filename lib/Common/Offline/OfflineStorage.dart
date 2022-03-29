import 'dart:io';

import 'package:holomusic/Common/Player/OfflineSong.dart';
import 'package:holomusic/Common/Player/OnlineSong.dart';
import 'package:localstore/localstore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

//Library used
//https://pub.dev/packages/localstore
class OfflineStorage {
  static final _db = Localstore.instance;
  static const _collectionName = "holomusic";

  static Future saveSong(OnlineSong video) async {
    final docDirectory = await getApplicationDocumentsDirectory();
    final path = docDirectory.path +
        Platform.pathSeparator +
        "holomusic" +
        Platform.pathSeparator +
        "offline";
    final offlineDirectory = Directory(path);
    offlineDirectory.createSync(recursive: true);

    final _video = await video.getVideo();

    final imageResponse =
        await http.get(Uri.parse(_video.thumbnails.highResUrl));
    final imageFile = File(offlineDirectory.path +
        Platform.pathSeparator +
        _video.id.value +
        ".jpg");
    imageFile.writeAsBytes(imageResponse.bodyBytes, flush: true);

    final _yt = YoutubeExplode();
    var songFile = File(offlineDirectory.path +
        Platform.pathSeparator +
        _video.id.value +
        ".webm");
    final manifest = await _yt.videos.streamsClient.getManifest(video.id);
    final streamInfo = manifest.audioOnly.withHighestBitrate();
    final stream = _yt.videos.streamsClient.get(streamInfo);
    var fileStream = songFile.openWrite();
    await stream.pipe(fileStream);
    // Close the file.
    await fileStream.flush();
    await fileStream.close();

    await _db.collection(_collectionName).doc(_video.id.value).set({
      "title": video.title,
      "thumbnail": imageFile.path,
      "path": songFile.path
    });
    print("completed");
  }

  static Future<List<OfflineSong>> getOfflineSongs() async {
    final document = _db.collection(_collectionName);

    final elements = (await document.get())?.entries;
    if (elements == null) {
      return List.empty();
    }

    List<OfflineSong> list = List.empty(growable: true);

    for (var key in elements) {
      String fullKey = key.key;
      String id =
          fullKey.substring(fullKey.lastIndexOf(Platform.pathSeparator) + 1);

      final title = key.value['title'];
      final thumbnail = key.value['thumbnail'];
      final path = key.value['path'];
      final video = OfflineSong(id, title, thumbnail, path);
      video.thumbnail = thumbnail;
      list.add(video);
    }
    return list;
  }

  static Future deleteSong(OfflineSong offlineSong) async {
    File songPath = File(offlineSong.filePath);
    songPath.deleteSync(recursive: true);
    if (offlineSong.thumbnail != null) {
      File imgPath = File(offlineSong.thumbnail!);
      imgPath.deleteSync(recursive: true);
    }
    await _db.collection(_collectionName).doc(offlineSong.id).delete();
  }

  static Future<OfflineSong?> getSongById(String id) async {
    final element = await _db.collection(_collectionName).doc(id).get();
    if (element == null) {
      return null;
    }
    return OfflineSong(
        id, element['title'], element['thumbnail'], element['path']);
  }

  static Future<bool> isSongStoredById(String id) async {
    final element = await _db.collection(_collectionName).doc(id).get();
    return element != null;
  }
}
