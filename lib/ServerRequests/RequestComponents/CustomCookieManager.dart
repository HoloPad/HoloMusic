import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomCookieManager extends CookieManager {
  SharedPreferences sharedPreferences;

  CustomCookieManager(CookieJar cookieJar, this.sharedPreferences) : super(cookieJar) {
    final cookieList = sharedPreferences.getStringList("cookie");
    final cookieHost = sharedPreferences.getString("cookie_host");
    if (cookieList != null && cookieHost != null) {
      cookieJar.saveFromResponse(
          Uri.parse(cookieHost), cookieList.map((e) => Cookie.fromSetCookieValue(e)).toList());
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    super.onResponse(response, handler);
    var cookies = response.headers[HttpHeaders.setCookieHeader];
    if (cookies != null) {
      sharedPreferences.setStringList("cookie", cookies);
      sharedPreferences.setString("cookie_host", response.requestOptions.uri.host);
    }
  }
}
