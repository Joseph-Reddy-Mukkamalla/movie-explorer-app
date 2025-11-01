import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MovieApp());
}

class Movie {
  final String title, overview, posterUrl;
  Movie(this.title, this.overview, this.posterUrl);
}

class MovieApp extends StatefulWidget {
  const MovieApp({Key? key}) : super(key: key);

  @override
  State<MovieApp> createState() => _MovieAppState();
}

class _MovieAppState extends State<MovieApp> {
  List<Movie> movies = [];
  Set<String> favorites = {};

  @override
  void initState() {
    super.initState();
    loadMovies();
    loadFavorites();
  }

  Future<void> loadMovies() async {
    final csvData = await rootBundle.loadString('assets/movies.csv');
    final rows = const LineSplitter().convert(csvData);
    final dataRows = rows.skip(1).toList();
    final random = Random();
    final chosen = <int>{};
    final tempMovies = <Movie>[];
    while (tempMovies.length < 10 && chosen.length < dataRows.length) {
      final idx = random.nextInt(dataRows.length);
      if (chosen.contains(idx)) continue;
      final cols = dataRows[idx].split(',');
      final posterUrl = cols.last.replaceAll(RegExp(r'[\[\]]'), '');
      tempMovies.add(Movie(cols[1], cols[2], posterUrl));
      chosen.add(idx);
    }
    setState(() {
      movies = tempMovies;
    });
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favorites = prefs.getStringList('favorites')?.toSet() ?? {};
    });
  }

  Future<void> toggleFavorite(String title) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (favorites.contains(title)) {
        favorites.remove(title);
      } else {
        favorites.add(title);
      }
    });
    await prefs.setStringList('favorites', favorites.toList());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Random Movies')),
        body: ListView.builder(
          itemCount: movies.length,
          itemBuilder: (context, index) {
            final m = movies[index];
            final favorited = favorites.contains(m.title);
            return Card(
              child: ListTile(
                leading: Image.network(m.posterUrl, width: 50, fit: BoxFit.cover),
                title: Text(m.title),
                subtitle: Text(m.overview, maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: IconButton(
                  icon: Icon(favorited ? Icons.favorite : Icons.favorite_border, color: favorited ? Colors.red : null),
                  onPressed: () => toggleFavorite(m.title),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
