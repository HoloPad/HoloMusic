import 'package:holomusic/ServerRequests/User.dart';
import 'package:test/test.dart';

void main() {
  group('User manager:', () {
    UserRequest.init();

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

    test('login', () async {
      var response = await UserRequest.userLogin("hackerino", "hackerino");
      expect(response, true);
      response = await UserRequest.userLogin("utente", "non_registrato");
      expect(response, false);
    });

    test('logout', () async {
      final response = await UserRequest.logout();
      expect(response, true);
    });
  });
}
