import 'package:flutter/material.dart';
import '../models/movie.dart';
import 'fallback_poster.dart';
import 'favorite_button.dart';
import 'rating_badge.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;

  const MovieCard({
    required this.movie,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 160,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        movie.posterUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            FallbackPoster(title: movie.title),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: RatingBadge(rating: movie.voteAverage),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: FavoriteButton(movie: movie),
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: 40,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
                  child: Text(
                    movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.2,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
