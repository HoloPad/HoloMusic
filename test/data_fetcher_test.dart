import 'package:holomusic/Common/DataFetcher/Providers/TheGotOfficial.dart';
import 'package:test/test.dart';

void main() {
  group('Fetcher:', () {
    test('The Got Official', () async {
      final got = TheGotOfficial("it");
      final list = await got.getVideosInfo();
      expect(list.length, 20);
    });
  });
}
