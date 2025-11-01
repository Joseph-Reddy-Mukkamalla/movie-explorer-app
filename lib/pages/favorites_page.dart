import 'package:flutter/material.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import '../models/movie.dart';
import '../services/movie_service.dart';
import '../services/storage_service.dart';
import '../widgets/movie_card.dart';
import 'movie_details_page.dart';

class FavoritesPage extends StatefulWidget {
  final MovieService movieService;
  const FavoritesPage({required this.movieService, super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Movie> favorites = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  void loadFavorites() async {
    setState(() => loading = true);
    final favTitles = await StorageService.getFavorites();
    final all = widget.movieService.movies;
    final found = all.where((m) => favTitles.contains(m.title)).toList();
    setState(() {
      favorites = found;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: Container(
          color: Colors.black,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
              child: Row(
                children: [
                  Text(
                    'Favorites',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : favorites.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.favorite_border, size: 64, color: Colors.white24),
                      SizedBox(height: 12),
                      Text('No favorites yet', style: TextStyle(color: Colors.white54)),
                    ],
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final cardWidth = 160.0;
                    final crossAxisCount = max(2, (constraints.maxWidth / cardWidth).floor());
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 0.55,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 20,
                      ),
                      itemCount: favorites.length,
                      itemBuilder: (context, index) {
                        final movie = favorites[index];
                        return MovieCard(
                          movie: movie,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MovieDetailsPage(
                                  movie: movie,
                                  movieService: widget.movieService,
                                  showSimilar: false,
                                  otherMovies: favorites.where((m) => m != movie).toList(),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                )
    );
  }
}
