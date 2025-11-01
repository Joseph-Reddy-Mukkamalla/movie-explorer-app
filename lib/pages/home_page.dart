import 'dart:math';
import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/movie_service.dart';
import '../widgets/movie_card.dart';
import 'movie_details_page.dart';

class HomePage extends StatefulWidget {
  final MovieService movieService;
  const HomePage({required this.movieService, super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Movie> allMovies;
  String searchQuery = '';
  List<String> randomGenres = [];

  @override
  void initState() {
    super.initState();
    allMovies = widget.movieService.movies;
    pickRandomGenres();
  }

  void pickRandomGenres() {
    final genresSet = <String>{};
    for (var movie in allMovies) {
      genresSet.addAll(movie.genres);
    }
    final genresList = genresSet.toList();
    genresList.shuffle();
    randomGenres = genresList.take(5).toList();
  }

  List<Movie> filterMovies(String genre) {
    var filtered = allMovies.where((m) => m.genres.contains(genre)).toList();
    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where((m) => m.title.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }
    return filtered;
  }

  List<Movie> searchMovies() {
    if (searchQuery.isEmpty) return [];
    return allMovies
        .where((m) => m.title.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Movie Explorer'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search movies...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white12,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          // Expanded list
          Expanded(
            child: allMovies.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.movie, size: 64, color: Colors.white24),
                        SizedBox(height: 12),
                        Text('No movies loaded',
                            style: TextStyle(color: Colors.white54)),
                      ],
                    ),
                  )
                : searchQuery.isNotEmpty
                    ? LayoutBuilder(
                        builder: (context, constraints) {
                          final cardWidth = 160.0;
                          final crossAxisCount = max(
                              2,
                              (constraints.maxWidth / cardWidth).floor());
                          return GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: 0.55,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 20,
                            ),
                            itemCount: searchMovies().length,
                            itemBuilder: (context, index) {
                              final movie = searchMovies()[index];
                              return MovieCard(
                                movie: movie,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MovieDetailsPage(
                                        movie: movie,
                                        movieService: widget.movieService,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      )
                    : ListView(
                        children: [
                          buildSection("Trending", getTrendingMovies()),
                          buildSection("Random Picks", getRandomMovies()),
                          for (var genre in randomGenres)
                            buildSection(genre, filterMovies(genre)),
                          const SizedBox(height: 16),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget buildSection(String title, List<Movie> movies) {
    if (movies.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(title,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: MovieCard(
                  movie: movie,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MovieDetailsPage(
                          movie: movie,
                          movieService: widget.movieService,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Trending: top 5 by popularity
  List<Movie> getTrendingMovies() {
    final list = List<Movie>.from(allMovies);
    list.sort((a, b) => b.popularity.compareTo(a.popularity));
    return list.take(10).toList();
  }

  // Random Picks: 10 random movies
  List<Movie> getRandomMovies() {
    final list = List<Movie>.from(allMovies)..shuffle();
    return list.take(10).toList();
  }
}
