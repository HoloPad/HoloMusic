import 'dart:convert';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:holomusic/Common/Playlist/PlaylistBase.dart';
import 'package:holomusic/ServerRequests/PaginatedResponse.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:holomusic/Common/Playlist/PlaylistSaved.dart';
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
enum PlaylistResponse{success, error}

class UserRequest {
  static var dio = Dio();
  static late PersistCookieJar cookieJar;
  static late SharedPreferences prefs;

  //Init the CookieManager, if a directory is not passed, it will use the tmp directory to store cookies
  static Future init([Directory? directory]) async {
    directory ??= await getTemporaryDirectory();
    var tempPath = directory.path;
    cookieJar = PersistCookieJar(storage: FileStorage(tempPath));
    dio.interceptors.add(CookieManager(
        cookieJar)); //CookieManager stores the sessionCookie for the authenticated request
    prefs = await SharedPreferences.getInstance();
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

  static Future <bool> makePlaylistPublic(PlaylistBase playlist) async{
    final uri = Uri.http(ServerParameters.FULL_URL, "makePlaylistPublic");

    //Get request to get csrf
    final response0 = await dio.get(uri.toString());
    final cookie =
    Cookie.fromSetCookieValue(response0.headers.value("set-cookie")!); //Get the cookie for csrf

    //POST Request
    final bodyContent = FormData.fromMap({
      'json_file': ((playlist as PlaylistSaved).toJson()),
      'csrfmiddlewaretoken': cookie.value
    });
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

  static Future <bool> makePlaylistPrivate(PlaylistBase playlist) async{
    final uri = Uri.http(ServerParameters.FULL_URL, "makePlaylistPrivate");

    //Get request to get csrf
    final response0 = await dio.get(uri.toString());
    final cookie =
    Cookie.fromSetCookieValue(response0.headers.value("set-cookie")!); //Get the cookie for csrf

    //POST Request
    final bodyContent = FormData.fromMap({
      'playlistname': playlist.name,
      'csrfmiddlewaretoken': cookie.value
    });
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

  static Future<bool> alreadyExists(String username, [String languageCode = "it-it"]) async {
    final errors = await register("", username, "");

    return errors.keys.contains("username") &&
        List<String>.from(errors['username']).any((element) => element.contains("already"));
  }

  static bool isLogin() {
    try {
      final sessionCookie = cookieJar.hostCookies.values.first.values.first['sessionid']?.cookie;
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
}
