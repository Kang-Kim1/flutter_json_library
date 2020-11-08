/*
 Code written by Kangmin Kim
 - Suggestions for input
 - Cache search input
 -
*/

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model.dart';

void main() {
  runApp(MaterialApp(home: Home()));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<List<Book>> _bookList;
  Future<List<String>> _searchList;
  TextEditingController tec = new TextEditingController();
  String _inputText = "";

  @override
  void initState()  {
    super.initState();
    _bookList = _getBookList();
    _searchList = _getRecentSearches();
  }

  // Get Json result - GET request
  Future<List<Book>> _getBookList() async {
    final response = await http.get('https://api.itbook.store/1.0/search/mongodb');

    if (response.statusCode == 200) {
      List<Book> books = [];
      var parsedJson = jsonDecode(response.body)['books'];
      books = parsedJson.map<Book>((book)=> Book.fromJson(book)).toList();

      return books;
    } else {
      throw Exception('Failed Fectching Data ');
    }
  }

  // Loading the search input
  Future<List<String>> _getRecentSearches() async {
    final pref = await SharedPreferences.getInstance();
    final allSearches = pref.getStringList("recentSearches");
    return allSearches;
    // return allSearches.where((search) => search.startsWith(query)).toList();
  }

  // Caching the search input
  Future<void> _saveRecentSearches(String searchText) async {
    if (searchText == null) return;
    final pref = await SharedPreferences.getInstance();

    Set<String> allSearches =
        pref.getStringList("recentSearches")?.toSet() ?? {};

    allSearches = {searchText, ...allSearches};
    pref.setStringList("recentSearches", allSearches.toList());
  }

  @override
  Widget build(BuildContext context)  {
    return Scaffold(
      appBar: AppBar(
        title: Text('IT Book Library'),
      ),
      body:
      Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onSubmitted: (value) {
                // Caching search input
                _saveRecentSearches(value);
              },
              onChanged: (value) {
                setState(() {
                  print('input : ' + value);
                  _inputText = value;
                });
              },
              controller: tec,
              decoration: InputDecoration(
                labelText: 'Search IT Book here!',
                hintText: 'Enter Book Name',
                prefixIcon: Icon(Icons.search),
              ),
            ),

          ),
          Expanded(
          child : FutureBuilder(
              future:_bookList,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if(snapshot.data == null) {
                  return Container(
                    child: Center(
                      child: Text('Loading'),
                    ),
                  );
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      // Filter Books by search Input
                      if(snapshot.data[index].title.toLowerCase().contains(_inputText.toLowerCase())) {
                        return getGestureDetectorForBook(snapshot, index);
                      } else {
                        return Container();
                      }
                    },
                  );
                }
              }
            ),
          ),
        ]
      )
    );
  }
  Widget getGestureDetectorForBook(var snapshot, int index) {
    return GestureDetector(
      //onTap: () =>   Navigator.push(context, MaterialPageRoute(builder: (context) => new WebView())),
      onTap: () => launch(snapshot.data[index].url),
      child:
        Card(
          child : Row(
            children: <Widget>[
              Image(
                  image: new NetworkImage(
                      snapshot.data[index].image),
                  height: 150,
                  width: 150
              ),
              Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.topLeft,
                        child:Container(
                          margin: const EdgeInsets.only(top: 10.0, bottom: 15.0),
                            child : Text(snapshot.data[index].title,
                            style: TextStyle(fontSize: 15,
                                fontWeight: FontWeight.bold)),
                        ),
                      ),
                      RichText(
                        text: new TextSpan(
                            style: new TextStyle(
                                fontSize: 13,
                                color: Colors.black
                            ),
                            children: <TextSpan>[
                              new TextSpan(
                                  text: 'ISBN13 : ',
                                  style: new TextStyle(
                                      fontWeight: FontWeight
                                          .bold)),
                              new TextSpan(
                                  text: snapshot
                                      .data[index]
                                      .isbn),
                            ]
                        ),
                      ),
                      RichText(
                        text: new TextSpan(
                            style: new TextStyle(
                                fontSize: 13,
                                color: Colors.black
                            ),
                            children: <TextSpan>[
                              new TextSpan(
                                  text: 'Price : ',
                                  style: new TextStyle(
                                      fontWeight: FontWeight
                                          .bold)),
                              new TextSpan(
                                  text: snapshot
                                      .data[index]
                                      .price),
                            ]
                        ),
                      ),
                    ],
                  )
              )
            ],
          ),
        ),
    );
  }

}

class BookSearch extends SearchDelegate {
  Future<List<Book>> _bookList;

  BookSearch(Future<List<Book>> books) {
    this._bookList = books;
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    return  [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
    return null;
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if(query == null) {
      return Center (
        child : Text('No data found'),
      );
    } else {
      return Center (
        child : Text('data found'),
      );
    }
  }

  @override
  Widget buildSuggestions(BuildContext context) {
 //   final Iterable<Book> suggestions = query.isEmpty ? [] : _bookList.toList().where((Book b) => b.title.contains(query));
    return Center(
      child: Text(query),
    ) ;
  }
}
