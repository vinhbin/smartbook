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
  List<String> _recentRatings = []; // Store IDs of recently rated books