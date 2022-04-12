import 'package:holomusic/ServerRequests/User.dart';
import 'package:test/test.dart';

void main() {
  group('Fetcher:', () {
    test('Get user', () async {
      final response = await UserRequest.searchUserByUsername("luca");
      expect(response.result.map((e) => e.username).contains("luca"), true);
    });
  });
}
