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

  Widget _buildActionButtons(BuildContext context, Book book) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            _showAddToReadingListDialog(context, book);
          },
          icon: const Icon(Icons.add),
          label: const Text('Add to List'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pushNamed(context, '/review', arguments: book);
          },
          icon: const Icon(Icons.rate_review),
          label: const Text('Write Review'),
        ),
      ],
    );
  }

  void _showAddToReadingListDialog(BuildContext context, Book book) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add to Reading List'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Want to Read'),
                onTap: () {
                  // Implement adding to "Want to Read" logic
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('${book.title} added to Want to Read')),
                  );
                  // Consider notifying a state management provider here
                },
              ),
              ListTile(
                title: const Text('Currently Reading'),
                onTap: () {
                  // Implement adding to "Currently Reading" logic
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('${book.title} added to Currently Reading')),
                  );
                  // Consider notifying a state management provider here
                },
              ),
              ListTile(
                title: const Text('Finished Reading'),
                onTap: () {
                  // Implement adding to "Finished Reading" logic
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('${book.title} added to Finished Reading')),
                  );
                  // Consider notifying a state management provider here
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
