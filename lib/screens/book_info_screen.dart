import 'package:flutter/material.dart';
import 'package:smartbook/models/book.dart';
import 'package:smartbook/services/google_books_service.dart';
import 'package:smartbook/widgets/rating_stars.dart'; // We will have a RatingStars widget

class BookInfoScreen extends StatelessWidget {
  const BookInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Book book = ModalRoute.of(context)!.settings.arguments as Book;

    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            _navigateToHome(context);
          },
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildBookCover(book.thumbnail),
          const SizedBox(height: 16),
          _buildBookTitleAndAuthor(book.title, book.authors),
          const SizedBox(height: 8),
          RatingStars(rating: book.rating),
          const SizedBox(height: 16),
          _buildDescription(book.description),
          const SizedBox(height: 24),
          _buildActionButtons(context, book),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Set the current index for Book Detail
        onTap: (index) {
          _navigateToPage(context, index, book);
        },
        items: const [
          BottomNavigationBarItem(
            label: 'Catalog',
            icon: Icon(Icons.search),
          ),
          BottomNavigationBarItem(
            label: 'Book Info',
            icon: Icon(Icons.text_fields),
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
