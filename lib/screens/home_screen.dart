import 'package:flutter/material.dart';
import 'package:smartbook/widgets/book_card.dart';
import 'package:smartbook/services/google_books_api.dart';
import 'package:smartbook/models/book.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For storing user preferences

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Book>> _recommendedBooks;
  final ScrollController _scrollController = ScrollController();
  int _startIndex = 0;
  final int _pageSize = 10;
  bool _isLoading = false;
  bool _hasMore = true;
  List<String> _userGenres = []; // User's favorite genres
  final List<String> _recentRatings = []; // Store IDs of recently rated books
  int _currentIndex = 0; // For bottom navigation
@override
  void initState() {
    super.initState();
    _loadUserPreferences(); // Load genres on init
    _recommendedBooks = _fetchRecommendedBooks();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userGenres = prefs.getStringList('userGenres') ?? ['fiction']; // Default genre
    });
  }

  Future<void> _saveUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('userGenres', _userGenres);
  }

  Future<List<Book>> _fetchRecommendedBooks({bool append = false}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Recommendation Logic
      String query = _buildRecommendationQuery();

      List<Book> newBooks = await GoogleBooksAPI.searchBooks(
          query, startIndex: _startIndex, pageSize: _pageSize);

      if (newBooks.isEmpty) {
        setState(() {
          _hasMore = false;
          _isLoading = false;
        });
        return append ? [] : [];
      }

      setState(() {
        _startIndex += _pageSize;
        _isLoading = false;
      });

      return append ? [...await _recommendedBooks, ...newBooks] : newBooks;
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to fetch books: $e');
    }
  }

  String _buildRecommendationQuery() {
    List<String> keywords = [..._userGenres];
    if (_recentRatings.isNotEmpty) {
      keywords.add('similar to: ${_recentRatings.last}');
    }
    return keywords.join(' ');
  }

  void _scrollListener() {
    if (_hasMore &&
        !_isLoading &&
        _scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadMoreBooks();
    }
  }

  Future<void> _loadMoreBooks() async {
    if (_hasMore && !_isLoading) {
      try {
        List<Book> additionalBooks = await _fetchRecommendedBooks(append: true);
        if (additionalBooks.isNotEmpty) {
          setState(() {
            _recommendedBooks = Future.value(additionalBooks);
          });
        } else {
          setState(() {
            _hasMore = false;
          });
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load more books: $e')),
        );
      }
    }
  }
  Future<void> _refreshBooks() async {
    setState(() {
      _startIndex = 0;
      _hasMore = true;
    });
    _recommendedBooks = _fetchRecommendedBooks();
  }
  void _rateBook(String bookId) {
    setState(() {
      _recentRatings.add(bookId);
      if (_recentRatings.length > 5) {
        _recentRatings.removeAt(0);
      }
      _recommendedBooks = _fetchRecommendedBooks();
    });
  }
  
  void _navigateToPage(int index) {
    setState(() {
      _currentIndex = index;
    });
    switch (index) {
      case 0:
        // Already on Home Screen
        break;
      case 1:
        Navigator.pushNamed(context, '/catalog');
        break;
      case 2:
        Navigator.pushNamed(context, '/book_detail');
        break;
      case 3:
        Navigator.pushNamed(context, '/reading_list');
        break;
      case 4:
        Navigator.pushNamed(context,'/rate_and_review');
        break;
      case 5:
        Navigator.pushNamed(context,'/forum');
        break;
      case 6:
        Navigator.pushNamed(context,'/profile');
        break;
    }
  }