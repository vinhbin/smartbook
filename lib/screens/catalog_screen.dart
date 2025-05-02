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
  String _filter = 'All'; // Added filter state
  int _selectedIndex = 0; // Added for bottom navigation

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
  @override
    void initState() {
      super.initState();
      _performSearch("Flutter"); //initial search
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Catalog'),
        leading: IconButton( // Added Home button in AppBar
          icon: const Icon(Icons.home),
          onPressed: () {
            setState(() {
              _selectedIndex = 0;
              _navigateToHome(); // Call navigation function
            });
          },
        ),
        actions: [ // Added to move title to the center and keep home icon on the left.
          Container(),
        ],
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search for books',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _performSearch(_searchController.text);
                  },
                ),
              ),
              onSubmitted: (value) {
                _performSearch(value);
              },
            ),
          ),
          // Filter Dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButtonFormField<String>(
              value: _filter,
              onChanged: (String? newValue) {
                if (newValue != null) { // Null check
                  setState(() {
                    _filter = newValue;
                    _performSearch(_searchController.text); // Re-search with new filter
                  });
                }
              },
              items: <String>['All', 'Fiction', 'Non-Fiction', 'Sci-Fi', 'Romance'] // Example categories
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Filter by Category',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? Center(
                        child: Text(_errorMessage.isEmpty ? 'No results found.' : _errorMessage),
                      )
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          return BookCard(book: _searchResults[index]);
                        },
                      ),
          ),
        ],
        bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            _navigateToPage(index);
          });
        },
        items: const [
          BottomNavigationBarItem(
            label: 'Catalog',
            icon: Icon(Icons.search),
          ),
          BottomNavigationBarItem(
            label: 'Book Info',
            icon: Icon(Icons.textfields),
          ),
          BottomNavigationBarItem(
            label: 'Reading List',
            icon: Icon(Icons.bookmark),
          ),
          BottomNavigationBarItem(
            label: 'Rate & Review',
            icon: Icon(Icons.star),
          ),
	  BottomNavigationBarItem(
            label: 'Forum',
            icon: Icon(Icons.forum),
          ),
        ],
      ),
    );
  }