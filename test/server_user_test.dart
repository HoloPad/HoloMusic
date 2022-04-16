import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:holomusic/ServerRequests/UserRequest.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  group('User manager:', () {
    final tmpDirectory = Directory("./tmpDirectory");
    setUpAll(() async {
      SharedPreferences.setMockInitialValues({}); //set values here
      if(!tmpDirectory.existsSync())tmpDirectory.createSync();
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
          await UserRequest.register("luca00_97@hotmail.it", "hackerino", "hackerino");
      expect(response.length, 0);
    });*/


    test('Already exists', () async {
      bool response = await UserRequest.alreadyExists("hackerino");
      expect(response, true);
      response = await UserRequest.alreadyExists("pippo_baudo");
      expect(response, false);
    });

    test('login and logout', () async {
      await UserRequest.logout();
      var response = await UserRequest.userLogin("hackerino", "hackerino");
      expect(response, LoginResponse.success);
      expect(UserRequest.isLogin(), true);
      await UserRequest.logout();

      response = await UserRequest.userLogin("hackerino", "wrongpass");
      expect(response, LoginResponse.error);
      expect(UserRequest.isLogin(), false);

      response = await UserRequest.userLogin("luca00_97@hotmail.it", "hackerino");
      expect(response, LoginResponse.success);
      expect(UserRequest.isLogin(), true);
      UserRequest.logout();

      response = await UserRequest.userLogin("utente", "non_registrato");
      expect(response, LoginResponse.error);
      expect(UserRequest.isLogin(), false);
    });

/*
    test("user delete", () async {
      bool response = await UserRequest.deleteAccount("hackerino");
      expect(response, false);

      LoginResponse resp = await UserRequest.userLogin("hackerino", "hackerino");
      expect(resp, LoginResponse.success);

      response = await UserRequest.deleteAccount("hackerino");
      expect(response, true);

    });*/

    tearDownAll(() async {
      tmpDirectory.deleteSync(recursive: true);
    });
  });
}
