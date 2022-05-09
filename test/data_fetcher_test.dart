import 'package:holomusic/Common/Player/SongStateManager.dart';
import 'package:test/test.dart';

void main() {
  group('Fetcher:', () {
    setUpAll(() {
      SongStateManager.init();
    });
    /*
    test('The Got Official', () async {
      final got = TheGotOfficial("it");
      final list = await got.getSongs();
      expect(list.length, 20);
    });*/
  });
}
