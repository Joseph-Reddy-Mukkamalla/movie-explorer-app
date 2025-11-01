class Movie {
  final String title;
  final String overview;
  final String releaseDate;
  final double popularity;
  final int voteCount;
  final double voteAverage;
  final String language;
  final List<String> genres;
  final String posterUrl;

  Movie({
    required this.title,
    required this.overview,
    required this.releaseDate,
    required this.popularity,
    required this.voteCount,
    required this.voteAverage,
    required this.language,
    required this.genres,
    required this.posterUrl,
  });

  factory Movie.fromCsv(List<String> row) {
    if (row.length < 9 || row[1].isEmpty || row[2].isEmpty || row[0].isEmpty) {
      throw FormatException("Invalid row");
    }
    return Movie(
      releaseDate: row[0],
      title: row[1],
      overview: row[2],
      popularity: double.tryParse(row[3]) ?? 0,
      voteCount: int.tryParse(row[4]) ?? 0,
      voteAverage: double.tryParse(row[5]) ?? 0,
      language: row[6],
      genres: row[7].split(",").map((e) => e.trim()).toList(),
      posterUrl: row[8],
    );
  }
}
