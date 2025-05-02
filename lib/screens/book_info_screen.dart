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

  Widget _buildBookCover(String? thumbnail) {
    return Center(
      child: SizedBox(
        height: 200,
        width: 150,
        child: thumbnail != null && thumbnail.isNotEmpty
            ? Image.network(
                thumbnail,
                fit: BoxFit.cover,
                errorBuilder: (context, object, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child:
                        const Center(child: Icon(Icons.image_not_supported)),
                  );
                },
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              )
            : Container(
                color: Colors.grey[300],
                child: const Center(child: Icon(Icons.book)),
              ),
      ),
    );
  }

  Widget _buildBookTitleAndAuthor(String title, String author) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          'by $author',
          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
        ),
      ],
    );
  }
