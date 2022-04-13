import 'dart:io';

class ServerParameters {
  static String BASE_URL = Platform.isAndroid ? "10.0.2.2" : "127.0.0.1";
  static int PORT = 8080;
  static String FULL_URL = BASE_URL+":"+PORT.toString();

}