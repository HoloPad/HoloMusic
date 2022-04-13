import 'dart:convert';
import 'dart:io';

import 'package:holomusic/ServerRequests/User.dart';
import 'package:localstore/localstore.dart';

class UserHistoryStorage {
  static final String collectionName =
      "holomusic" + Platform.pathSeparator + "history";
  static const String documentName = "user_history";

  static Future<List<User>> getUserHistory() async {
    final data = await Localstore.instance
        .collection(collectionName)
        .doc(documentName)
        .get();
    if (data?.containsKey("users") ?? false) {
      List<dynamic> a = List.from(data!['users']);
      return a.
      map((e) => e.runtimeType==String ? jsonDecode(e):e).
      map((e) => User.fromJson(e)).toList(growable: true);
    } else {
      return List.empty(growable: true);
    }
  }

  static void addUser(User user) async {
    final userList = await getUserHistory();
    if (userList.length > 20) {
      userList.removeLast();
    }
    if (userList.any((element) => element.id == user.id)) {
      userList.removeWhere((element) => element.id == user.id);
    }
    userList.insert(0, user);

    await Localstore.instance
        .collection(collectionName)
        .doc(documentName)
        .set({"users": userList});
  }

  static void deleteUser(User user) async {
    final userList = await getUserHistory();

    userList.removeWhere((element) => element.id == user.id);

    await Localstore.instance
        .collection(collectionName)
        .doc(documentName)
        .set({"users": userList});
  }
}
