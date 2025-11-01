import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import '../models/movie.dart';

class CsvParser {
  static Future<List<Movie>> loadMovies(String path) async {
    final data = await rootBundle.loadString(path);
    // Debug: log asset size
    // ignore: avoid_print
    print('CsvParser: loaded asset "$path" size=${data.length}');
    var rows = const CsvToListConverter().convert(data);
    // ignore: avoid_print
    print('CsvParser: parsed rows=${rows.length} using default eol');
    // If parsing produced only 1 row, try alternative EOLs (web build may alter line endings)
    if (rows.length <= 1) {
      try {
        rows = const CsvToListConverter(eol: '\r\n').convert(data);
        // ignore: avoid_print
        print('CsvParser: parsed rows=${rows.length} using eol=\r\n');
      } catch (_) {}
    }
    if (rows.length <= 1) {
      try {
        rows = const CsvToListConverter(eol: '\n').convert(data);
        // ignore: avoid_print
        print('CsvParser: parsed rows=${rows.length} using eol=\\n');
      } catch (_) {}
    }
    if (rows.length <= 1) {
      try {
        rows = const CsvToListConverter(eol: '\r').convert(data);
        // ignore: avoid_print
        print('CsvParser: parsed rows=${rows.length} using eol=\\r');
      } catch (_) {}
    }
    // As a last resort, split by any newline regex and try to parse each line separately
    if (rows.length <= 1) {
      try {
        final lines = data.split(RegExp(r'\r\n|\n|\r'));
        // ignore: avoid_print
        print('CsvParser: fallback split lines=${lines.length}');
        final temp = <List<dynamic>>[];
        for (var line in lines) {
          if (line.trim().isEmpty) continue;
          final parsed = const CsvToListConverter().convert(line);
          if (parsed.isNotEmpty) temp.add(parsed.first);
        }
        if (temp.isNotEmpty) {
          rows = temp;
          // ignore: avoid_print
          print('CsvParser: rebuilt rows=${rows.length} from line-splitting fallback');
        }
      } catch (e) {
        // ignore: avoid_print
        print('CsvParser: fallback parsing failed: $e');
      }
    }
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
