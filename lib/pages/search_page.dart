import 'package:flutter/material.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import '../models/movie.dart';
import '../services/movie_service.dart';
import '../widgets/movie_card.dart';
import 'movie_details_page.dart';

enum SortBy { popularity, voteCount, voteAverage, releaseDate }

class SearchPage extends StatefulWidget {
  final MovieService movieService;
  const SearchPage({required this.movieService, super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String query = '';
  String? selectedGenre;
  String? selectedLanguage;
  String? selectedYear;
  SortBy sortBy = SortBy.voteCount;
  bool ascending = false;

  List<String> genres = [];
  List<String> languages = [];
  List<String> years = [];

  @override
  void initState() {
    super.initState();
    buildFilters();
  }

  void buildFilters() {
    final movies = widget.movieService.movies;
    final g = <String>{};
    final l = <String>{};
    final y = <String>{};

    for (var m in movies) {
      g.addAll(m.genres);
      l.add(m.language);
      if (m.releaseDate.isNotEmpty && m.releaseDate.length >= 4) {
        y.add(m.releaseDate.substring(0, 4));
      }
    }

    genres = g.toList()..sort();
    languages = l.toList()..sort();
    years = y.toList()..sort((a, b) => b.compareTo(a));
  }

  List<Movie> applyFilters() {
    var list = widget.movieService.movies;

    if (query.isNotEmpty) {
      list = list.where((m) => m.title.toLowerCase().contains(query.toLowerCase())).toList();
    }

    if (selectedGenre != null) {
      list = list.where((m) => m.genres.contains(selectedGenre)).toList();
    }

    if (selectedLanguage != null) {
      list = list.where((m) => m.language == selectedLanguage).toList();
    }

    if (selectedYear != null) {
      list = list.where((m) => m.releaseDate.startsWith(selectedYear!)).toList();
    }

    list.sort((a, b) {
      int cmp = 0;
      switch (sortBy) {
        case SortBy.popularity:
          cmp = a.popularity.compareTo(b.popularity);
          break;
        case SortBy.voteCount:
          cmp = a.voteCount.compareTo(b.voteCount);
          break;
        case SortBy.voteAverage:
          cmp = a.voteAverage.compareTo(b.voteAverage);
          break;
        case SortBy.releaseDate:
          cmp = a.releaseDate.compareTo(b.releaseDate);
          break;
      }
      return ascending ? cmp : -cmp;
    });

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final results = applyFilters();

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
                    'Search',
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
      body: Column(
        children: [
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
              onChanged: (v) => setState(() => query = v),
            ),
          ),

          /// FILTER DROPDOWNS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedGenre,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Genre')),
                      ...genres.map((g) => DropdownMenuItem(value: g, child: Text(g))),
                    ],
                    onChanged: (v) => setState(() => selectedGenre = v),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedLanguage,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Language')),
                      ...languages.map((l) => DropdownMenuItem(value: l, child: Text(l))),
                    ],
                    onChanged: (v) => setState(() => selectedLanguage = v),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedYear,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Year')),
                      ...years.map((y) => DropdownMenuItem(value: y, child: Text(y))),
                    ],
                    onChanged: (v) => setState(() => selectedYear = v),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// SORTING
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      query = '';
                      selectedGenre = null;
                      selectedLanguage = null;
                      selectedYear = null;
                      sortBy = SortBy.popularity;
                      ascending = false;
                    });
                  },
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear Filters'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white70,
                    backgroundColor: Colors.white10,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
                const Spacer(),
                const Text('Sort:', style: TextStyle(color: Colors.white)),
                const SizedBox(width: 8),
                DropdownButton<SortBy>(
                  value: sortBy,
                  dropdownColor: Colors.grey[900],
                  items: const [
                    DropdownMenuItem(value: SortBy.popularity, child: Text('Popularity')),
                    DropdownMenuItem(value: SortBy.voteCount, child: Text('Vote Count')),
                    DropdownMenuItem(value: SortBy.voteAverage, child: Text('Vote Average')),
                    DropdownMenuItem(value: SortBy.releaseDate, child: Text('Release Date')),
                  ],
                  onChanged: (v) => setState(() => sortBy = v ?? SortBy.voteCount),
                ),
                const SizedBox(width: 12),
                const Text('Order:', style: TextStyle(color: Colors.white)),
                const SizedBox(width: 8),
                ToggleButtons(
                  isSelected: [!ascending, ascending],
                  onPressed: (i) => setState(() => ascending = i == 1),
                  children: const [
                    Icon(Icons.arrow_downward),
                    Icon(Icons.arrow_upward),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          /// RESULTS GRID
          Expanded(
            child: results.isEmpty
                ? const Center(
                    child: Text(
                      'No results',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final cardWidth = 160.0;
                      final crossAxisCount =
                          max(2, (constraints.maxWidth / cardWidth).floor());

                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 0.55,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 20,
                        ),
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final movie = results[index];
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
                  ),
          ),
        ],
      ),
    );
  }
}
