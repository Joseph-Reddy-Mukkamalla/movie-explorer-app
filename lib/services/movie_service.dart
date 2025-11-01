import '../models/movie.dart';

class MovieService {
  final List<Movie> movies;
  MovieService(this.movies);

  List<Movie> getTrending() {
    movies.sort((a, b) => b.popularity.compareTo(a.popularity));
    return movies.take(10).toList();
  }

  List<Movie> getRandom(int count) {
    movies.shuffle();
    return movies.take(count).toList();
  }

  List<Movie> filterByGenre(String genre) {
    return movies.where((m) => m.genres.contains(genre)).toList();
  }

  List<Movie> filterByLanguage(String lang) {
    return movies.where((m) => m.language == lang).toList();
  }

  List<Movie> filterByYear(String year) {
    return movies.where((m) => m.releaseDate.startsWith(year)).toList();
  }

  List<Movie> search(String query) {
    return movies
        .where((m) => m.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
