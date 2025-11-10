// TEST: simple comment added for automated edit
import 'package:flutter/material.dart';
import 'dart:async';
import 'helpers/csv_parser.dart';
import 'services/movie_service.dart';
import 'pages/home_page.dart';
import 'models/movie.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final List<Movie> movies = await CsvParser.loadMovies('assets/movies.csv'); // <-- specify List<Movie>
  // Debug: print loaded movie count so it's visible in the terminal/console
  // This helps diagnose why the UI may show no movies.
  // You can remove this after debugging.
  // ignore: avoid_print abc
  print('Loaded ${movies.length} movies from assets/movies.csv');
  runApp(MyApp(movies: movies));
}

class MyApp extends StatelessWidget {
  final List<Movie> movies; // <-- specify List<Movie>
  const MyApp({required this.movies, super.key});

  @override
  Widget build(BuildContext context) {
    final movieService = MovieService(movies);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Movie Explorer',
      theme: AppTheme.getTheme(),
      home: HomePage(movieService: movieService),
    );
  }
}
