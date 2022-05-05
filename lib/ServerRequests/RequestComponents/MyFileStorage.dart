import 'package:cookie_jar/cookie_jar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyFileStorage extends Storage {
  late SharedPreferences sharedPreferences;
  final MAINKEY = "COK_STOR";
  final COOKIE_KEY_LIST = "COK_9fh4LIST";

  @override
  Future<void> delete(String key) async {
    sharedPreferences.remove(MAINKEY + key);
    final list = sharedPreferences.getStringList(COOKIE_KEY_LIST);
    if (list != null) {
      list.remove(key);
      sharedPreferences.setStringList(COOKIE_KEY_LIST, list);
    }
  }

  @override
  Future<void> deleteAll(List<String> keys) async{
    keys.forEach((element) {
      delete(element);
    });
  }

  @override
  Future<void> init(bool persistSession, bool ignoreExpires) async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  @override
  Future<String?> read(String key) {
    return Future.value(sharedPreferences.getString(MAINKEY + key));
  }

  @override
  Future<void> write(String key, String value) async {
    sharedPreferences.setString(MAINKEY + key, value);
    final list = sharedPreferences.getStringList(COOKIE_KEY_LIST);
    if (list != null) {
      list.add(key);
      sharedPreferences.setStringList(COOKIE_KEY_LIST, list);
    }
  }
}
