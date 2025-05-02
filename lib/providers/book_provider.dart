import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/google_books_service.dart';
import '../models/book.dart';

/// Handles:
///   • loading / refreshing recommendation list
///   • lazy-loading more books on scroll
///   • remembering user’s favourite genres in SharedPreferences
///   • injecting a “similar to:last-rated” keyword
class BookProvider extends ChangeNotifier {

  // In-memory list shown by HomeScreen.
  final List<Book> _books = [];
  List<Book> get books => _books;

  // Pagination flags.
  bool _loading = true, _hasMore = true;
  bool get loading => _loading;
  bool get hasMore => _hasMore;

  // Cursor and page size.
  int _start = 0, _page = 10;

  // Simple “preferences”: favourite genres + recently rated book IDs.
  List<String> _genres = ['fiction'];
  final List<String> _recent = [];

  BookProvider() {
    _bootstrap();
  }

  /*──────────────── bootstrap ────────────────*/
  Future<void> _bootstrap() async {
    // Load saved genres (if any) before the first API call.
    final prefs = await SharedPreferences.getInstance();
    _genres = prefs.getStringList('userGenres') ?? ['fiction'];

    await refresh(); // initial API hit
  }

  /*──────────────── external API ─────────────*/
  Future<void> refresh() async {
    _start = 0;
    _books.clear();
    _hasMore = true;
    await _load(); // first page
  }

  Future<void> loadMore() => _load(); // called by the scroll listener

  /// Add a book to the “recent ratings” list (max 5) and trigger a refresh
  /// so the query includes  “similar to:<that-id>”.
  void addRating(String id) {
    _recent..add(id);
    if (_recent.length > 5) _recent.removeAt(0);
    refresh();
  }

  /*──────────────── private ───────────────────*/
  Future<void> _load() async {
    if (!_hasMore || _loading) return;

    _loading = true;
    notifyListeners(); // show spinner

    // Build query: “fantasy mystery similar to:abc123”
    final q = [
      ..._genres,
      if (_recent.isNotEmpty) 'similar to:${_recent.last}',
    ].join(' ');

    final newPage = await GoogleBooksService.search(q, startIndex: _start, pageSize: _page);

    _books.addAll(newPage);
    _start += _page;
    _hasMore = newPage.isNotEmpty;
    _loading = false;
    notifyListeners();
  }
}