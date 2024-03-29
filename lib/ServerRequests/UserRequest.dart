import 'dart:convert';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:holomusic/Common/Playlist/PlaylistBase.dart';
import 'package:holomusic/Common/Playlist/PlaylistSaved.dart';
import 'package:holomusic/Common/Playlist/Providers/YouTubePlaylist.dart';
import 'package:holomusic/ServerRequests/PaginatedResponse.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'RequestComponents/CustomCookieManager.dart';
import 'RequestComponents/MyFileStorage.dart';
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

enum LoginResponse { success, emailNotVerified, error }

enum PlaylistResponse { success, error }

class UserRequest {
  static var dio = Dio();
  static late PersistCookieJar cookieJar;
  static late SharedPreferences prefs;

  //Init the CookieManager, if a directory is not passed, it will use the document/holomusic/cookies directory to store cookies
  static Future init([Directory? directory]) async {
    prefs = await SharedPreferences.getInstance();
    final fileStorage = MyFileStorage();
    cookieJar = PersistCookieJar(storage: fileStorage);
    dio.interceptors.add(CustomCookieManager(cookieJar, prefs));
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

  //static Future<PaginatedResponse<List<String>>> getPlaylistsFromUsername(String username,
  static Future<PaginatedResponse<List<PlaylistSaved>>> getPlaylistsFromUsername(String username,
      {int page = 0}) async {
    final queryParameters = {"username": username, "page": page.toString()};
    final uri = Uri.http(ServerParameters.FULL_URL, "getPlaylistsFromUsername", queryParameters);
    final response = await http.get(uri);
    final jsonObject = jsonDecode(response.body);
    final hasNext = jsonObject['hasNextPage'] as bool;
    final currentPage = jsonObject['currentPage'] as int;
    //final userList = (jsonObject['results'] as List<dynamic>).map((e) => e.toString()).toList();
    final userList =
        (jsonObject['results'] as List<dynamic>).map((e) => PlaylistSaved.fromJson(e)).toList();
    for (var value in userList) {
      value.ownerId = username;
    }
    return PaginatedResponse(userList, currentPage: currentPage, hasNext: hasNext);
  }

  //Login an user, returns true if success, false otherwise
  static Future<LoginResponse> userLogin(String username, String password) async {
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

    if (response1.statusCode == 200 && response1.data['success'] == true) {
      //Success
      await prefs.setString("username", response1.data['username']);
      await prefs.setString("email", response1.data['email']);
      return LoginResponse.success;
    } else if (response1.statusCode == 200 &&
        (response1.data['message'] as String).toLowerCase().contains("mail not verified")) {
      return LoginResponse.emailNotVerified;
    } else {
      return LoginResponse.error;
    }
  }

  //Logout an user, returns true on success, false otherwise
  static Future logout() async {
    await prefs.remove("username");
    await prefs.remove("email");
    if (!UserRequest.isLogin()) {
      return;
    }
    final uri = Uri.http(ServerParameters.FULL_URL, "logout");
    await dio.get(uri.toString());
    await cookieJar.deleteAll();
  }

  static Future<bool> makePlaylistPublic(PlaylistBase playlist) async {
    final uri = Uri.http(ServerParameters.FULL_URL, "makePlaylistPublic");

    //Get request to get csrf
    final response0 = await dio.get(uri.toString());
    final cookie =
        Cookie.fromSetCookieValue(response0.headers.value("set-cookie")!); //Get the cookie for csrf

    //POST Request
    final bodyContent = FormData.fromMap(
        {'json_file': ((playlist as PlaylistSaved).toJson()), 'csrfmiddlewaretoken': cookie.value});
    final headers = {"X-CSRFToken": cookie.value};
    final response1 =
        await dio.post(uri.toString(), data: bodyContent, options: Options(headers: headers));

    if (response1.statusCode == 200 && response1.data['success'] == true) {
      //Success
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> makePlaylistPrivate(PlaylistBase playlist) async {
    final uri = Uri.http(ServerParameters.FULL_URL, "makePlaylistPrivate");

    //Get request to get csrf
    final response0 = await dio.get(uri.toString());
    final cookie =
        Cookie.fromSetCookieValue(response0.headers.value("set-cookie")!); //Get the cookie for csrf

    //POST Request
    final bodyContent =
        FormData.fromMap({'playlistname': playlist.name, 'csrfmiddlewaretoken': cookie.value});
    final headers = {"X-CSRFToken": cookie.value};
    final response1 =
        await dio.post(uri.toString(), data: bodyContent, options: Options(headers: headers));

    if (response1.statusCode == 200 && response1.data['success'] == true) {
      //Success
      return true;
    } else {
      return false;
    }
  }

  static Future<Map<String, dynamic>> register(String email, String username, String password,
      [String languageCode = "it-it"]) async {
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
    try {
      final response1 =
          await dio.post(uri.toString(), data: bodyContent, options: Options(headers: headers));

      if (response1.statusCode == 200 && response1.data['success'] != true) {
        return (response1.data['errors'] as Map<String, dynamic>);
      } else {
        return {};
      }
    } catch (_) {
      return {};
    }
  }

  static Future<Map<String, dynamic>> resetPassword(String email, String password,
      [String languageCode = "it-it"]) async {
    final uri = Uri.http(ServerParameters.FULL_URL, "resetPassword");

    //Get request to get csrf
    final response0 = await dio.get(uri.toString());
    final cookie =
        Cookie.fromSetCookieValue(response0.headers.value("set-cookie")!); //Get the cookie for csrf

    //POST Request
    final bodyContent = FormData.fromMap(
        {'password': password, 'email': email, 'csrfmiddlewaretoken': cookie.value});
    final headers = {"X-CSRFToken": cookie.value, "Accept-Language": languageCode};
    try {
      final response1 =
          await dio.post(uri.toString(), data: bodyContent, options: Options(headers: headers));

      if (response1.statusCode == 200 && response1.data['success'] != true) {
        return (response1.data['errors'] as Map<String, dynamic>);
      } else {
        return {};
      }
    } catch (_) {
      return {};
    }
  }

  static Future<bool> alreadyExists(String username, [String languageCode = "it-it"]) async {
    final errors = await register("", username, "");

    return errors.keys.contains("username") &&
        List<String>.from(errors['username']).any((element) => element.contains("already"));
  }

  static bool isLogin() {
    try {
      final cookie = cookieJar.hostCookies.values
          .firstWhere((e) => e.values.any((e) => e.keys.contains("sessionid")));
      final sessionCookie = cookie.values.first['sessionid']?.cookie;
      return sessionCookie?.expires?.isAfter(DateTime.now()) ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> deleteAccount(String password) async {
    if (!isLogin()) {
      return false;
    }
    final uri = Uri.http(ServerParameters.FULL_URL, "deleteAccount");

    //Get request to get csrf
    final response0 = await dio.get(uri.toString());
    final cookie =
        Cookie.fromSetCookieValue(response0.headers.value("set-cookie")!); //Get the cookie for csrf

    //POST Request
    final bodyContent = FormData.fromMap({
      'username': prefs.getString("username"),
      'password': password,
      'csrfmiddlewaretoken': cookie.value
    });
    final headers = {"X-CSRFToken": cookie.value};
    final response1 =
        await dio.post(uri.toString(), data: bodyContent, options: Options(headers: headers));
    bool status = response1.statusCode == 200 && response1.data['success'];
    if (status) {
      await prefs.remove("username");
      await prefs.remove("email");
      await cookieJar.deleteAll();
    }
    return status;
  }

  static Future<bool> sendVerificationEmail(String username, String password) async {
    final uri = Uri.http(ServerParameters.FULL_URL, "sendVerificationEmail");
    //Get request to get csrf
    final response0 = await dio.get(uri.toString());
    final cookie =
        Cookie.fromSetCookieValue(response0.headers.value("set-cookie")!); //Get the cookie for csrf

    //POST Request
    final bodyContent = FormData.fromMap(
        {'username': username, 'password': password, 'csrfmiddlewaretoken': cookie.value});
    final headers = {"X-CSRFToken": cookie.value};
    final response =
        await dio.post(uri.toString(), data: bodyContent, options: Options(headers: headers));
    return response.statusCode == 200 && response.data['success'];
  }

  static Future<bool> makePlaylistAsFavourite(PlaylistBase playlistBase) async {
    final uri = Uri.http(ServerParameters.FULL_URL, "setFavouritePlaylist");
    //Get request to get csrf
    final response0 = await dio.get(uri.toString());
    final cookie =
        Cookie.fromSetCookieValue(response0.headers.value("set-cookie")!); //Get the cookie for csrf
    var bodyContent = FormData.fromMap({});
    if (playlistBase.runtimeType == PlaylistSaved) {
      final playlist = playlistBase as PlaylistSaved;

      bodyContent = FormData.fromMap({
        'playlist_id': playlist.id,
        'username_playlist_creator': playlist.ownerId,
        'csrfmiddlewaretoken': cookie.value
      });
    } else if (playlistBase.runtimeType == YoutubePlaylist) {
      final playlist = playlistBase as YoutubePlaylist;
      bodyContent = FormData.fromMap({
        'playlist_id': playlist.id,
        //'username_playlist_creator': owner.id,
        'csrfmiddlewaretoken': cookie.value
      });
    } else {
      return false;
    }
    final headers = {"X-CSRFToken": cookie.value};
    final response =
        await dio.post(uri.toString(), data: bodyContent, options: Options(headers: headers));
    return response.statusCode == 200 && response.data['success'];
  }

  static Future<bool> unsetPlaylistAsFavourite(PlaylistBase playlistBase) async {
    final uri = Uri.http(ServerParameters.FULL_URL, "unsetFavouritePlaylist");
    //Get request to get csrf
    final response0 = await dio.get(uri.toString());
    final cookie =
        Cookie.fromSetCookieValue(response0.headers.value("set-cookie")!); //Get the cookie for csrf
    var bodyContent = FormData.fromMap({});
    if (playlistBase.runtimeType == PlaylistSaved) {
      final playlist = playlistBase as PlaylistSaved;

      bodyContent = FormData.fromMap({
        'playlist_id': playlist.id,
        'username_playlist_creator': playlist.ownerId,
        'csrfmiddlewaretoken': cookie.value
      });
    } else if (playlistBase.runtimeType == YoutubePlaylist) {
      final playlist = playlistBase as YoutubePlaylist;
      bodyContent =
          FormData.fromMap({'playlist_id': playlist.id, 'csrfmiddlewaretoken': cookie.value});
    } else {
      return false;
    }
    final headers = {"X-CSRFToken": cookie.value};
    final response =
        await dio.post(uri.toString(), data: bodyContent, options: Options(headers: headers));
    return response.statusCode == 200 && response.data['success'];
  }

  static Future<PaginatedResponse<List<PlaylistSaved>>> getFavouritePlaylists(
      {int page = 0}) async {
    final uri = Uri.http(ServerParameters.FULL_URL, "getFavouritePlaylists");
    final response = await dio.get(uri.toString());
    final hasNext = response.data['hasNextPage'] as bool;
    final currentPage = response.data['currentPage'] as int;
    final userList =
        (response.data['results'] as List<dynamic>).map((e) => PlaylistSaved.fromJson(e)).toList();
    return PaginatedResponse(userList, currentPage: currentPage, hasNext: hasNext);
  }

  static Future<bool> checkIfPlaylistIsFavourite(PlaylistSaved playlistSaved) async {
    PaginatedResponse paginatedResponse = await UserRequest.getFavouritePlaylists();
    do {
      if (paginatedResponse.result.any((element) => element.id == playlistSaved.id)) {
        return true;
      }
      if (!paginatedResponse.hasNext) {
        return false;
      }
      paginatedResponse =
          await UserRequest.getFavouritePlaylists(page: paginatedResponse.currentPage + 1);
    } while (paginatedResponse.hasNext);
    return false;
  }

  static Future<PaginatedResponse<List<PlaylistSaved>>>? getUserOnlinePlaylists() {
    final username = prefs.getString("username");
    if (username != null) {
      return getPlaylistsFromUsername(username);
    } else {
      return null;
    }
  }

  static Future<bool> addYoutubePlaylistToFavourite(YoutubePlaylist playlist) async {
    await Future.delayed(const Duration(seconds: 1));
    return false;
    //TODO
  }

  static Future<bool> removeYoutubePlaylistToFavourite(YoutubePlaylist playlist) async {
    await Future.delayed(const Duration(seconds: 1));
    return false;
    //TODO
  }

  static Future<List<YoutubePlaylist>> getFollowedYoutubePlaylist() async {
    await Future.delayed(const Duration(seconds: 1));
    return List.empty();
    //TODO
  }

  static Future<bool> isYoutubePlaylistFollowed(YoutubePlaylist playlist) async {
    return false;
    //TODO
  }
}
