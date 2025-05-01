import 'package:flutter/material.dart';
import 'package:smartbook/services/google_books_service.dart'; 
import 'package:smartbook/models/book.dart';
import 'package:smartbook/widgets/book_card.dart';

class CatalogScreen extends StatefulWidget {
  @override
  _CatalogScreenState createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _searchController = TextEditingController();
  List<Book> _searchResults = [];
  String _errorMessage = '';
  bool _isLoading = false; // Added to track loading state
