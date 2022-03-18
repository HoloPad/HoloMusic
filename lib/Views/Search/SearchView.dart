import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:holomusic/Views/Search/VideoCard.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:holomusic/Common/VideoHandler.dart';


class SearchView extends StatefulWidget {
  final void Function(VideoHandler) playSongFunction;
  const SearchView({Key? key, required this.playSongFunction}) : super(key: key);

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  late YoutubeExplode _youtubeExplode;
  Future<SearchList>? _searchResults;

  _SearchViewState() {
    _youtubeExplode = YoutubeExplode();
  }

  void _onSubmitted(String query) {
    final queryRes = _youtubeExplode.search.getVideos(query);
    setState(() {
      _searchResults = queryRes;
    });
    queryRes.then((value) {
      print("NEW RESULT " + value.length.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        TextField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Search a song",
            icon: Icon(Icons.search),
          ),
          onSubmitted: _onSubmitted,
        ),
        FutureBuilder<SearchList>(
          future: _searchResults,
          builder: (BuildContext context, AsyncSnapshot<SearchList> snapshot) {
            if (snapshot.hasData) {
              final list = snapshot.data!;
              print("NEW DATA");
              return Expanded(
                  child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: snapshot.data?.length,
                      itemBuilder: (BuildContext context, int index) {
                        return VideoCard(video: list.elementAt(index),playSongFunction: widget.playSongFunction,);
                      }));
            } else {
              print("NO DATA " + snapshot.error.toString());
              return Text("No data");
            }
          },
        )
      ],
    );
  }
}
