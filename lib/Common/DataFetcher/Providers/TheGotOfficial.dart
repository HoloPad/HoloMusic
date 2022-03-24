import 'dart:convert';
import 'dart:ui';

import 'package:holomusic/Common/DataFetcher/Providers/Playlist.dart';
import 'package:holomusic/Common/DataFetcher/VideoInfo.dart';
import 'package:html/parser.dart' show parse, parseFragment;
import 'package:http/http.dart' as http;

class TheGotOfficial extends Playlist {
  late Uri url;
  Future<List<VideoInfo>>? _listVideoCache;

  TheGotOfficial(String countryCode)
      : super(
            "The Got Official",
            "https://www.thegotofficial.com/res/images/thegottino.png",
            const Color.fromRGBO(178, 178, 107, 1)) {
    String url =
        "https://www.thegotofficial.com/youtube-" + countryCode.toLowerCase();
    this.url = Uri.parse(url);
  }

  @override
  String? getReferenceUrl(){
    return "https://www.thegotofficial.com/";
  }

  @override
  Future<List<VideoInfo>> getVideosInfo() async {

    _listVideoCache ??= _getVideosInfo();
    return _listVideoCache!;
  }

  Future<List<VideoInfo>> _getVideosInfo() async {
    const maxAttempts = 5;
    var numberOfAttempt = 0;
    http.Response response;
    do {
      response = await http.get(url).timeout(const Duration(seconds: 5));
      numberOfAttempt++;
      print("Attemp "+numberOfAttempt.toString()+" "+response.statusCode.toString());
    }
    while (response.statusCode!=200 && numberOfAttempt<maxAttempts);

    final elements = const Utf8Decoder().convert(response.bodyBytes)
        .split("<tr")
        .where((element) => element.contains("</tr>"))
        .map((e) => "<tr" + e)
        .map((e) => parseFragment(e, container: "tr",encoding: "UTF-8"))
        .where((element) => element.querySelectorAll(".rank").isEmpty)
        .map((e) {
          final name = e
              .querySelector(".tableContentFirstName, .tableContentOtherName")
              ?.innerHtml;
          final onclick = e
              .querySelector(".tableContentOtherImage, .tableContentFirstImage")
              ?.attributes["onclick"];
          final url = onclick?.substring(
              onclick.indexOf("https://"), onclick.indexOf("');"));
          final thumbnail = e
              .querySelector(".tableContentOtherImage, .tableContentFirstImage")
              ?.attributes["alt"];
          if (name == null || url == null) {
            return null;
          } else {
            final info = VideoInfo(name, url);
            info.thumbnail = thumbnail;
            return info;
          }
        })
        .whereType<VideoInfo>()
        .toList();
    return elements;
  }
}
