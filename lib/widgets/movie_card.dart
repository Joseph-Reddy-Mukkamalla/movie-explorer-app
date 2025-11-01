import 'package:flutter/material.dart';
import '../models/movie.dart';
import 'fallback_poster.dart';
import 'favorite_button.dart';
import 'rating_badge.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;

  const MovieCard({required this.movie, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    movie.posterUrl,
                    height: 200,
                    width: 140,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        FallbackPoster(title: movie.title),
                  ),
                ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: RatingBadge(rating: movie.voteAverage),
                ),
                Positioned(
                  top: 5,
                  left: 5,
                  child: FavoriteButton(movie: movie),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              movie.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
