import 'dart:convert';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:holomusic/ServerRequests/PaginatedResponse.dart';
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

  toJson() {
    return jsonEncode({"id": id, "username": username, "playlist_count": public_playlist_count});
  }

  @override
  String toString() {
    return "id: $id, username: $username";
  }
}

class UserRequest {
  static var dio = Dio();
  static var cookieJar = CookieJar();

  static init() {
    dio.interceptors.add(CookieManager(
        cookieJar)); //CookieManager stores the sessionCookie for the authenticated request
  }

  static Future<PaginatedResponse<List<User>>> searchUserByUsername(String username,
      {int page = 0}) async {
    final queryParameters = {"username": username, "page": page.toString()};
    final uri = Uri.http(ServerParameters.FULL_URL, "searchUser", queryParameters);
    final response = await http.get(uri);
    final jsonObject = jsonDecode(response.body);
    final hasNext = jsonObject['hasNextPage'] as bool;
    final currentPage = jsonObject['currentPage'] as int;
    final userList = (jsonObject['results'] as List<dynamic>).map((e) => User.fromJson(e)).toList();
    return PaginatedResponse(userList, currentPage: currentPage, hasNext: hasNext);
  }

  //Login an user, returns true if success, false otherwise
  static Future<bool> userLogin(String username, String password) async {
    final uri = Uri.http(ServerParameters.FULL_URL, "signIn");

    //Get request to get csrf
    final response0 = await dio.get(uri.toString());
    final cookie =
        Cookie.fromSetCookieValue(response0.headers.value("set-cookie")!); //Get the cookie for csrf

    //POST Request
    final bodyContent = FormData.fromMap(
        {'username': username, 'password': password, 'csrfmiddlewaretoken': cookie.value});
    final response1 = await dio.post(uri.toString(),
        data: bodyContent, options: Options(headers: {"X-CSRFToken": cookie.value}));
    return response1.statusCode == 200 && response1.data['success'];
  }

  //Logout an user, returns true on success, false otherwise
  static Future<bool> logout() async {
    final uri = Uri.http(ServerParameters.FULL_URL, "logout");
    final response = await dio.get(uri.toString());
    return response.statusCode == 200 && response.data['success'];
  }

  static Future<Map<String, dynamic>> register(String email, String username, String password,
      [String languageCode = "it-it"]) async {
    print("REGISTER $email $username $password");
    final uri = Uri.http(ServerParameters.FULL_URL, "signUp");

    //Get request to get csrf
    final response0 = await dio.get(uri.toString());
    final cookie =
        Cookie.fromSetCookieValue(response0.headers.value("set-cookie")!); //Get the cookie for csrf

    //POST Request
    final bodyContent = FormData.fromMap({
      'username': username,
      'password': password,
      'email': email,
      'csrfmiddlewaretoken': cookie.value
    });
    final headers = {"X-CSRFToken": cookie.value, "Accept-Language": languageCode};
    final response1 =
        await dio.post(uri.toString(), data: bodyContent, options: Options(headers: headers));
    if (response1.data['success'] != true) {
      return (response1.data['errors'] as Map<String, dynamic>);
    } else {
      return {};
    }
  }

  static Future<bool> alreadyExists(String username, [String languageCode = "it-it"]) async {
    final errors = await register("", username, "");

    return errors.keys.contains("username") &&
        List<String>.from(errors['username']).any((element) => element.contains("already"));
  }
}
