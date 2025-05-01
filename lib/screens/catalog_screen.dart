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

  Future<void> _performSearch(String query) async {
    setState(() {
      _errorMessage = '';
      _isLoading = true; // Set loading to true before starting the search
      _searchResults = []; //Clear previous results
    });
    try {
      final results = await GoogleBooksService.searchBooks(query); // Corrected class name
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load books. Please try again. Error: $e'; // Improved error message
      });
    } finally {
      setState(() {
        _isLoading = false; // Set loading to false after search is complete
      });
    }
  }
