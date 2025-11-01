import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../widgets/favorite_button.dart';
import '../widgets/movie_card.dart';
import '../services/movie_service.dart';

class MovieDetailsPage extends StatelessWidget {
  final Movie movie;
  final MovieService movieService; // required for similar movies

  const MovieDetailsPage({
    required this.movie,
    required this.movieService,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    // Similar movies based on shared genres
    final similarMovies = movieService.movies
        .where((m) => m != movie && m.genres.any((g) => movie.genres.contains(g)))
        .take(10)
        .toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(movie.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background poster blurred + dark overlay
          Positioned.fill(
            child: Image.network(
              movie.posterUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.black),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(color: Colors.black.withOpacity(0.6)),
            ),
          ),
          // Main content
          SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: screenHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: kToolbarHeight + 16),
                    // Poster + details
                    isPortrait
                        ? Column(
                            children: [
                              posterWidget(),
                              const SizedBox(height: 16),
                              detailsSection(),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(width: 16),
                              posterWidget(),
                              const SizedBox(width: 24),
                              Expanded(child: detailsSection()),
                            ],
                          ),
                    const SizedBox(height: 24),
                    // Similar movies section
                    similarMovies.isNotEmpty
                        ? similarMoviesSection(similarMovies, context)
                        : Container(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget posterWidget() {
    return Hero(
      tag: movie.title,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          movie.posterUrl,
          width: 200,
          height: 300,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Container(
            width: 200,
            height: 300,
            color: Colors.deepPurple,
            alignment: Alignment.center,
            child: Text(
              movie.title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget detailsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            movie.title,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber),
              const SizedBox(width: 4),
              Text("${movie.voteAverage} (${movie.voteCount} votes)",
                  style: const TextStyle(color: Colors.white)),
              const SizedBox(width: 16),
              FavoriteButton(movie: movie),
            ],
          ),
          const SizedBox(height: 8),
          Text("Release Date: ${movie.releaseDate}",
              style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 4),
          Text("Language: ${movie.language.toUpperCase()}",
              style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 4),
          Text("Genres: ${movie.genres.join(', ')}",
              style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          Text(movie.overview, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget similarMoviesSection(List<Movie> movies, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "Similar Movies",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final m = movies[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: MovieCard(
                  movie: m,
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MovieDetailsPage(movie: m, movieService: movieService),
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
}
