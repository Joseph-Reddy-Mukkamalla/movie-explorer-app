import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/movie.dart';
import '../services/movie_service.dart';
import '../widgets/movie_card.dart';
import 'movie_details_page.dart';
import 'favorites_page.dart';
import 'search_page.dart';

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
  late PageController _trendingPageController;
  int _trendingCurrentPage = 0; // stores REAL index (0..len-1)
  Timer? _trendingAutoTimer;
  double _trendingViewportFraction = 0.56;
  List<Movie> _trendingMovies = [];
  late List<Movie> _randomPicks;
  double _lastCarouselWidth = 0.0;

  @override
  void initState() {
    super.initState();
    allMovies = widget.movieService.movies;
    pickRandomGenres();
    _trendingMovies = getTrendingMovies();
    _randomPicks = getRandomMovies();

    // Initialize in the MIDDLE copy to enable seamless looping.
    // If empty, keep initialPage = 0.
    final initPage = _trendingMovies.isEmpty ? 0 : _trendingMovies.length;

    _trendingPageController = PageController(
      viewportFraction: _trendingViewportFraction,
      initialPage: initPage,
    );

    // current page should reflect the REAL index (0..len-1)
    _trendingCurrentPage = 500000000;

    _startTrendingAutoSlide();
  }

  void _startTrendingAutoSlide() {
    _trendingAutoTimer?.cancel();

    _trendingAutoTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted ||
          !_trendingPageController.hasClients ||
          _trendingMovies.isEmpty) return;

      // Always animate to the next REAL page, but target the middle-copy index.
      final next = _trendingCurrentPage + 1;
      _trendingPageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
      _trendingCurrentPage = next;

    });
  }

  // Reset the auto-slide timer (used for ANY manual interaction).
  void _resetAutoSlideTimer() {
    _trendingAutoTimer?.cancel();
    _startTrendingAutoSlide();
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

  void _ensureTrendingController(double viewportFraction) {
    if ((_trendingViewportFraction - viewportFraction).abs() > 0.001) {
      final len = _trendingMovies.length;
      final currentReal = len == 0 ? 0 : _trendingCurrentPage % len;
      try {
        _trendingPageController.dispose();
      } catch (_) {}
      _trendingViewportFraction = viewportFraction;
      _trendingPageController = PageController(
        viewportFraction: _trendingViewportFraction,
        // Always re-center on the middle copy for seamless loop
        initialPage: len == 0 ? 0 : currentReal + len,
      );
    }
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: Container(
          color: Colors.black,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
              child: Row(
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/movie_reel.svg',
                        width: 32,
                        height: 32,
                        colorFilter: const ColorFilter.mode(
                          Colors.deepPurpleAccent,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'MovieExplorer',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FavoritesPage(
                                    movieService: widget.movieService),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.favorite_border,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    SearchPage(movieService: widget.movieService),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.search_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
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
                          final crossAxisCount =
                              max(2, (constraints.maxWidth / cardWidth).floor());
                          return GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
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
                          buildTrendingCarousel(getTrendingMovies()),
                          buildSection("Random Picks", _randomPicks),
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

  @override
  void dispose() {
    _trendingAutoTimer?.cancel();
    _trendingPageController.dispose();
    super.dispose();
  }

  double _getProgressiveScale(int index) {
    // Calculate how far this card is from the center
    final currentPage = _trendingCurrentPage % _trendingMovies.length;
    final itemPosition = index % _trendingMovies.length;
    final distance = (itemPosition - currentPage).abs();

    // Apply progressively smaller scale based on distance from center
    if (distance == 1) return 0.90;
    if (distance == 2) return 0.75;
    return 0.70; // For cards further away
  }

  Widget buildTrendingCarousel(List<Movie> movies) {
    if (movies.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 380,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final int visibleCount =
              (width / 220).floor().clamp(1, 8); // Reduced base width to show more posters
          final viewportFraction = 1 / visibleCount;
          final desiredCardWidth =
              (width * viewportFraction) * 0.9; // Increased to show larger center card

          if ((width - _lastCarouselWidth).abs() > 4.0 ||
              (_trendingViewportFraction - viewportFraction).abs() > 0.001) {
            _lastCarouselWidth = width;
            _ensureTrendingController(viewportFraction);
          }

          return Stack(
            children: [
              // Wrap with GestureDetector to catch ANY user touch and reset timer.
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanDown: (_) {
                  _resetAutoSlideTimer(); // manual swipe starts → reset
                },
                child: PageView.builder(
                  controller: _trendingPageController,
                  // 3 copies for seamless loop (prev/middle/next)
                  itemCount: 10000000,  // effectively infinite
                  onPageChanged: (index) {
                    final real = index % _trendingMovies.length;
                    setState(() => _trendingCurrentPage = index);
                  },
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final len = _trendingMovies.length;
                    final realIndex = index % _trendingMovies.length;
                    final movie = _trendingMovies[realIndex];
                    final bool isCentered =
                        (index % len) == (_trendingCurrentPage % len);

                    return AnimatedPadding(
                      duration: const Duration(milliseconds: 300),
                      padding: EdgeInsets.symmetric(
                        vertical: isCentered ? 0 : 16,
                        horizontal: 8,
                      ),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            if (!isCentered) {
                              final targetPage = index;
                              _trendingPageController.animateToPage(
                                targetPage,
                                duration: const Duration(milliseconds: 450),
                                curve: Curves.easeInOut,
                              );
                              _resetAutoSlideTimer(); // manual tap → reset
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MovieDetailsPage(
                                    movie: movie,
                                    movieService: widget.movieService,
                                  ),
                                ),
                              );
                            }
                          },
                          child: AnimatedScale(
                            scale: isCentered ? 1.0 : _getProgressiveScale(index),
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: desiredCardWidth,
                                      maxHeight: 300, // Increased height for posters
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Stack(
                                        children: [
                                          Image.network(
                                            movie.posterUrl,
                                            fit: BoxFit.contain,
                                            alignment: Alignment.center,
                                            errorBuilder: (context, error, stackTrace) =>
                                                Container(
                                              color: Colors.black26,
                                              child: Center(
                                                child: Text(
                                                  movie.title,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      color: Colors.white60,
                                                      fontSize: 14),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.black54,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.star,
                                                      color: Colors.amber, size: 14),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    movie.voteAverage.toStringAsFixed(1),
                                                    style: const TextStyle(
                                                        color: Colors.white, fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: desiredCardWidth,
                                  child: Text(
                                    movie.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Left Arrow
              Positioned(
                left: 6,
                top: 0,
                bottom: 32,
                child: Center(
                  child: Container(
                    decoration: const BoxDecoration(
                        color: Colors.black45, shape: BoxShape.circle),
                    child: IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.white),
                      onPressed: () {
                        if (_trendingMovies.isEmpty) return;
                        final len = _trendingMovies.length;
                        final prev = (_trendingCurrentPage - 1) % len;
                        final target = prev < 0 ? prev + len : prev;
                        _trendingPageController.animateToPage(
                          target + len, // middle copy
                          duration: const Duration(milliseconds: 450),
                          curve: Curves.easeInOut,
                        );
                        _resetAutoSlideTimer(); // manual arrow → reset
                      },
                    ),
                  ),
                ),
              ),

              // Right Arrow
              Positioned(
                right: 6,
                top: 0,
                bottom: 32,
                child: Center(
                  child: Container(
                    decoration: const BoxDecoration(
                        color: Colors.black45, shape: BoxShape.circle),
                    child: IconButton(
                      icon: const Icon(Icons.chevron_right, color: Colors.white),
                      onPressed: () {
                        if (_trendingMovies.isEmpty) return;
                        final len = _trendingMovies.length;
                        final next = _trendingCurrentPage + 1;
                        _trendingPageController.animateToPage(
                          next,
                          duration: const Duration(milliseconds: 450),
                          curve: Curves.easeInOut,
                        );
                        _trendingCurrentPage = next;
                        _resetAutoSlideTimer();

                      },
                    ),
                  ),
                ),
              ),

              // Dots Indicator
              Positioned(
                left: 0,
                right: 0,
                bottom: 6,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(_trendingMovies.length, (i) {
                      final active = i == (_trendingCurrentPage % _trendingMovies.length);
                      return MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                      onTap: () {
                        final realCurrent = _trendingCurrentPage % _trendingMovies.length;
                        final delta = i - realCurrent;
                        final targetPage = _trendingCurrentPage + delta;

                        _trendingPageController.animateToPage(
                          targetPage,
                          duration: const Duration(milliseconds: 450),
                          curve: Curves.easeInOut,
                        );

                        _resetAutoSlideTimer();
                      },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: active ? 12 : 8,
                            height: active ? 12 : 8,
                            decoration: BoxDecoration(
                              color: active ? Colors.white : Colors.white24,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  //
  // --- METHODS MOVED BACK INSIDE THE CLASS ---
  //

  Widget buildSection(String title, List<Movie> movies) {
    if (movies.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
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

  List<Movie> getTrendingMovies() {
    final list = List<Movie>.from(allMovies);
    list.sort((a, b) => b.popularity.compareTo(a.popularity));
    return list.take(10).toList();
  }

  List<Movie> getRandomMovies() {
    final list = List<Movie>.from(allMovies)..shuffle();
    return list.take(10).toList();
  }
}
