import 'package:flutter/material.dart';
// Import services for SystemMouseCursors
//import 'package:flutter/services.dart'; 

import '../models/movie.dart';
import 'fallback_poster.dart';
import 'favorite_button.dart';
import 'rating_badge.dart';

class MovieCard extends StatefulWidget {
  final Movie movie;
  final VoidCallback onTap;

  const MovieCard({
    required this.movie,
    required this.onTap,
    super.key,
  });

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      // SystemMouseCursors.click is now correctly accessible
      cursor: SystemMouseCursors.click, 
      child: GestureDetector(
        onTap: widget.onTap,
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
                        widget.movie.posterUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        // Using a function call for errorBuilder for clarity and correctness
                        errorBuilder: (context, error, stackTrace) =>
                            FallbackPoster(title: widget.movie.title),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: RatingBadge(rating: widget.movie.voteAverage),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: FavoriteButton(movie: widget.movie),
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: 40,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
                  child: Text(
                    widget.movie.title,
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