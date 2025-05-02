import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

/// Tiny wrapper around the public Google Books REST API.
/// We only need two endpoints:
///   • /volumes?q=…          (search)
///   • same with startIndex  (lazy-load pagination)
class GoogleBooksService {
  static const _base = 'https://www.googleapis.com/books/v1/volumes';

  /// Fetches [pageSize] books that match [query], starting at [startIndex].
  /// Returns an empty list on any non-200 status so the caller can
  /// decide what to show (spinner, snackbar, etc.).
  static Future<List<Book>> search(
    String query, {
    int startIndex = 0,
    int pageSize = 10,
  }) async {
    final uri = Uri.parse(
      '$_base?q=${Uri.encodeQueryComponent(query)}'
      '&startIndex=$startIndex&maxResults=$pageSize',
    );

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to load books: ${res.statusCode}');
    }

    final data = jsonDecode(res.body);
    final items = (data['items'] as List?) ?? [];
    return items.map((e) => Book.fromGoogle(e)).toList();
  }
}
