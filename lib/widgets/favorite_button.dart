import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class FavoriteButton extends StatefulWidget {
  final Movie movie;
  const FavoriteButton({required this.movie, super.key});

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    loadFavorite();
  }

  void loadFavorite() async {
    final favs = await StorageService.getFavorites();
    setState(() {
      isFavorite = favs.contains(widget.movie.title);
    });
  }

  void toggleFavorite() async {
    final favs = await StorageService.getFavorites();
    if (isFavorite) {
      favs.remove(widget.movie.title);
    } else {
      favs.add(widget.movie.title);
    }
    await StorageService.saveFavorites(favs);
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: toggleFavorite,
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: AppTheme.primary,
          size: 20,
        ),
      ),
    );
  }
}
