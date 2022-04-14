import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:holomusic/ServerRequests/User.dart';

void main() async {
  group('User manager:', () {
    final tmpDirectory = Directory("./tmpDirectory");
    setUpAll(() async {
      await UserRequest.init(tmpDirectory);
    });

    test('Get user', () async {
      final response = await UserRequest.searchUserByUsername("luca");
      expect(response.result.map((e) => e.username).contains("luca"), true);
    });

    test('Register invalid account', () async {
      var response = await UserRequest.register("pippo", "pippo", "pippo");
      expect(response.keys.contains("email"), true);

      response = await UserRequest.register("pippo", "ca", "ca");
      expect(response.keys.contains("username"), true);
      expect(response.keys.contains("email"), true);
      expect(response.keys.contains("password"), true);

      response = await UserRequest.register("pippo@franco.it", "luca", "22");
      bool alreadyExists =
          List<String>.from(response['username']).any((element) => element.contains("already"));
      expect(response.keys.contains("username"), true);
      expect(alreadyExists, true);
    });

    /*
    test('Register', () async {
      final response =
          await UserRequest.register("pippo@franco.it", "pippo_franco", "superpassowrd");
      expect(response.length, 0);
    });
     */

    test('Already exists', () async {
      bool response = await UserRequest.alreadyExists("hackerino");
      expect(response, true);
      response = await UserRequest.alreadyExists("pippo_baudo");
      expect(response, false);
    });

    test('login and logout', () async {
      await UserRequest.logout();
      var response = await UserRequest.userLogin("hackerino", "hackerino");
      expect(response, true);
      expect(UserRequest.isLogin(), true);
      await UserRequest.logout();

      response = await UserRequest.userLogin("hackerino", "wrongpass");
      expect(response, false);
      expect(UserRequest.isLogin(), false);

      response = await UserRequest.userLogin("luca00_97@hotmail.it", "hackerino");
      expect(response, true);
      expect(UserRequest.isLogin(), true);
      UserRequest.logout();

      response = await UserRequest.userLogin("utente", "non_registrato");
      expect(response, false);
      expect(UserRequest.isLogin(), false);
    });

    tearDownAll(() async {
      tmpDirectory.deleteSync(recursive: true);
    });
  });
}
