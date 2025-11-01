import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import '../models/movie.dart';

class CsvParser {
  static Future<List<Movie>> loadMovies(String path) async {
    final data = await rootBundle.loadString(path);
    // Debug: log asset size
    // ignore: avoid_print
    print('CsvParser: loaded asset "$path" size=${data.length}');
    // Normalize line endings to \n for web compatibility
    var normalizedData = data.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    
    // Split the data into lines manually
    var lines = normalizedData.split('\n');
    // ignore: avoid_print
    print('CsvParser: split into ${lines.length} lines');
    
    // Parse each line individually to handle any CSV formatting
    var rows = <List<dynamic>>[];
    for (var line in lines) {
      if (line.trim().isEmpty) continue;
      try {
        var parsed = const CsvToListConverter(shouldParseNumbers: false).convert(line);
        if (parsed.isNotEmpty) {
          rows.add(parsed.first);
        }
      } catch (e) {
        // ignore: avoid_print
        print('CsvParser: failed to parse line: $e');
        continue;
      }
    }
    
    // ignore: avoid_print
    print('CsvParser: successfully parsed ${rows.length} rows');
    List<Movie> movies = [];
    for (var i = 1; i < rows.length; i++) {
      try {
        movies.add(Movie.fromCsv(rows[i].map((e) => e.toString()).toList()));
      } catch (e, st) {
        // Debug: log the problematic row index and error
        // ignore: avoid_print
        print('CsvParser: failed to parse row $i, error=$e');
        // Optionally print the row data if short
        try {
          final rowData = rows[i];
          if (rowData is List && rowData.length <= 12) {
            // ignore: avoid_print
            print('CsvParser: row $i data=$rowData');
          }
        } catch (_) {}
        continue;
      }
    }
    // ignore: avoid_print
    print('CsvParser: movies parsed=${movies.length}');
    return movies;
  }
}
