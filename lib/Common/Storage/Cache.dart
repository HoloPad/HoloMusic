import 'dart:io';

import 'package:localstore/localstore.dart';

class Cache {
  static final _db = Localstore.instance;
  static final _collectionName = "holomusic" + Platform.pathSeparator + "cache";

  static Future<String?> getValueByKey(String key) async {
    final collection = await _db.collection(_collectionName).doc("keyvalue").get();
    if (collection == null) return null;
    return collection[key];
  }

  static void setValueByKey(String value, String key) async {
    Map<String,dynamic>? collection = await _db.collection(_collectionName).doc("keyvalue").get();
    collection ??= Map();
    collection.addAll({key:value});
    _db.collection(_collectionName).doc("keyvalue").set(collection);
  }
}


