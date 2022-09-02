import 'dart:io';

class ServerParameters {
  static String BASE_URL = "164.92.172.121"; //Platform.isAndroid ? "10.0.2.2" : "127.0.0.1";
  static int PORT = 80;
  static String FULL_URL = BASE_URL + ":" + PORT.toString();
}
