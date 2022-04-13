import 'package:holomusic/ServerRequests/User.dart';
import 'package:test/test.dart';

void main() {
  group('Fetcher:', () {
    test('Get user', () async {
      final response = await UserRequest.searchUserByUsername("luca");
      expect(response.result.map((e) => e.username).contains("luca"), true);
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
