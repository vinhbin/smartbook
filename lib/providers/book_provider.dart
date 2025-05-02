import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/book.dart';
import '../services/google_books_service.dart';

/// Centralised state for the home screen: handles recommendation queries,
/// paging, simple user preferences, and the "recently rated" similarity hint.
class BookProvider extends ChangeNotifier {
  // ────────────────────── public read‑only getters ──────────────────────
  List<Book> get books   => List.unmodifiable(_books);
  bool       get loading => _loading;
  bool       get hasMore => _hasMore;

  // ─────────────────────────── private state ────────────────────────────
  final _api   = GoogleBooksService();
  final _books = <Book>[];

  bool _loading = false; // ← MUST start false so first fetch can run
  bool _hasMore = true;

  int _start    = 0;     // cursor for paging
  final int _page = 10;  // page size

  List<String> _genres = ['fiction']; // simple user preference
  final _recent = <String>[];         // last five rated IDs

  // ───────────────────────────── lifecycle ──────────────────────────────
  BookProvider() {
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _genres = prefs.getStringList('userGenres') ?? ['fiction'];
    } catch (_) {
      // ignore – preferences are optional
    }
    await refresh();
  }

  // ─────────────────────────── public API ───────────────────────────────
  Future<void> refresh() async {
    _start   = 0;
    _books.clear();
    _hasMore = true;
    _loading = false; // ensure gate is open
    await _load();
  }

  Future<void> loadMore() => _load();

  void addRating(String id) {
    _recent..add(id);
    if (_recent.length > 5) _recent.removeAt(0);
    refresh();
  }

  // ──────────────────────────── internals ───────────────────────────────
  Future<void> _load() async {
    if (_loading || !_hasMore) return;

    _loading = true;
    notifyListeners();

    // Build query – if you're running offline with a stub, you can comment
    // out the logic below and just send an empty string.
    final query = [
      ..._genres,
      if (_recent.isNotEmpty) 'similar to:${_recent.last}',
    ].join(' ');

    try {
      final page = await _api.search(
        query,
        startIndex: _start,
        pageSize: _page,
      );

      _books.addAll(page);
      _hasMore = page.isNotEmpty;
      _start   += _page;
    } catch (e) {
      // network or parsing error – stop paging and surface nothing more.
      debugPrint('[BookProvider] fetch error: $e');
      _hasMore = false;
    }

    _loading = false;
    notifyListeners();
  }
}