import 'dart:convert';

import 'package:holomusic/ServerRequests/Response.dart';
import 'package:http/http.dart' as http;

import 'ServerParameters.dart';

class User {
  int id;
  String username;

  User(this.id, this.username);

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        username = json['username'] as String;

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
