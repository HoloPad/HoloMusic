import 'dart:async';
import 'dart:io';

import 'package:holomusic/Common/Player/OfflineSong.dart';
import 'package:localstore/localstore.dart';

//Library used
//https://pub.dev/packages/localstore

class SongsStorage {
  static final _db = Localstore.instance;
  static const _collectionName = "holomusic";

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
      list.add(video);
    }
    return list;
  }

}
