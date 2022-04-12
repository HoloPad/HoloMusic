import 'dart:convert';

import 'package:holomusic/ServerRequests/Response.dart';
import 'package:http/http.dart' as http;

import 'ServerParameters.dart';

class User {
  int id;
  String username;
  int public_playlist_count = -1;

  User(this.id, this.username);

  factory User.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int;
    final username = json['username'] as String;
    final user = User(id, username);
    if (json.containsKey("playlist_count")) {
      user.public_playlist_count = json['playlist_count'] as int;
    }
    return user;
  }

  @override
  String toString() {
    return "ID: $id, username: $username";
  }
}

class UserRequest {
  static Future<Response<List<User>>> searchUserByUsername(String username,
      {int page = 0}) async {
    final queryParameters = {"username": username, "page": page.toString()};
    final uri =
        Uri.http(ServerParameters.BASE_URL, "searchUser", queryParameters);
    final response = await http.get(uri);
    final jsonObject = jsonDecode(response.body);
    final hasNext = jsonObject['hasNextPage'] as bool;
    final currentPage = jsonObject['currentPage'] as int;
    final userList = (jsonObject['results'] as List<dynamic>)
        .map((e) => User.fromJson(e))
        .toList();
    return Response(userList, currentPage: currentPage, hasNext: hasNext);
  }
}
