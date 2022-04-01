import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:holomusic/Common/Player/OnlineSong.dart';
import 'package:html/parser.dart' show  parseFragment;
import 'package:http/http.dart' as http;
import 'package:youtube_parser/youtube_parser.dart';

import '../../Player/Song.dart';
import '../PlaylistBase.dart';

class TheGotOfficial extends PlaylistBase {
  late Uri url;
  Future<List<Song>>? _listVideoCache;

  TheGotOfficial(String countryCode)
      : super(
            "The Got Official",
            const NetworkImage("https://www.thegotofficial.com/res/images/thegottino.png"),
            const Color.fromRGBO(178, 178, 107, 1)) {
    String url =
        "https://www.thegotofficial.com/youtube-" + countryCode.toLowerCase();
    this.url = Uri.parse(url);
  }

  @override
  String? getReferenceUrl() {
    return "https://www.thegotofficial.com/";
  }

  @override
  Future<List<Song>> getSongs() async {
    _listVideoCache ??= _getVideosInfo();
    return _listVideoCache!;
  }

  Future<List<Song>> _getVideosInfo() async {
    const maxAttempts = 5;
    var numberOfAttempt = 0;
    http.Response response;
    do {
      response = await http.get(url).timeout(const Duration(seconds: 5));
      numberOfAttempt++;
      print("Attemp " +
          numberOfAttempt.toString() +
          " " +
          response.statusCode.toString());
    } while (response.statusCode != 200 && numberOfAttempt < maxAttempts);

    final elements = const Utf8Decoder()
        .convert(response.bodyBytes)
        .split("<tr")
        .where((element) => element.contains("</tr>"))
        .map((e) => "<tr" + e)
        .map((e) => parseFragment(e, container: "tr", encoding: "UTF-8"))
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
            final id = getIdFromUrl(url);
            if (id == null) {
              return null;
            }
            final info = OnlineSong.lazy(id, name, thumbnail, playlist: this);
            return info;
          }
        })
        .whereType<OnlineSong>()
        .toList();
    return elements;
  }
}
