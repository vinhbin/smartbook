import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;

import '/models/book.dart';

 
/// GoogleBooksService

class GoogleBooksService {
  static const _base      = 'https://www.googleapis.com/books/v1/volumes';
  static const _proxyPre  = 'https://corsproxy.io/?'; // only used on web

  /// Fetches a page of books that match [query].
  ///
  /// Returns **empty list** on HTTP or parsing failure; throws only on
  /// network‑layer errors like time‑out or no connection.
  Future<List<Book>> search(
    String query, {
    int startIndex = 0,
    int pageSize   = 10,
  }) async {
    final encodedQ = Uri.encodeQueryComponent(query.trim());
    final uri = Uri.parse(
      '${kIsWeb ? _proxyPre : ''}$_base?q=$encodedQ&startIndex=$startIndex&maxResults=$pageSize',
    );

    http.Response res;
    try {
      res = await http.get(uri).timeout(const Duration(seconds: 8));
    } catch (e) {
      debugPrint('[GoogleBooks] network error → $e');
      rethrow; // let caller decide (usually BookProvider)
    }

    if (res.statusCode != 200) {
      debugPrint('[GoogleBooks] HTTP ${res.statusCode}: ${res.body}');
      return [];
    }

    try {
      final data  = jsonDecode(res.body) as Map<String, dynamic>;
      final items = (data['items'] as List?) ?? [];
      return items
    .cast<Map<String, dynamic>>()       // <‑‑ this makes the types line up
    .map<Book>(_fromGoogle)
    .toList();
    } catch (e) {
      debugPrint('[GoogleBooks] parse error → $e');
      return [];
    }
  }

  // Convert Google Books JSON → our Book object with safe fallbacks.
  Book _fromGoogle(Map<String, dynamic> item) {
    final v = item['volumeInfo'] ?? <String, dynamic>{};
    return Book(
      id:          item['id'] ?? 'missing_id',
      title:       v['title'] ?? 'Unknown',
      authors:     (v['authors'] ?? ['Unknown']).join(', '),
      thumbnail:   (v['imageLinks']?['thumbnail']) ??
                   'https://via.placeholder.com/128x198.png?text=No+Cover',
      rating:      (v['averageRating'] ?? 0).toDouble(),
      description: v['description'] ?? '',
    );
  }
}

