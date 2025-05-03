import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/providers/book_provider.dart';
import '/providers/auth_provider.dart';
import '/models/book.dart';

 
/// HomeScreen – Main Dashboard
 
/// Displays:
///   - Welcome message for the user
///   - Continue Reading section (first current book or fallback)
///   - Just for You section (first 10 books)
///   - Trending section (last 10 books)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookProv = context.watch<BookProvider>();      // Book state provider
    final user = context.watch<AuthProvider>().user;     // Authenticated user
    final name = user?.email?.split('@').first ?? 'Reader'; // Extract name from email

    // Fetch books if list is empty and not already loading
    if (bookProv.books.isEmpty && !bookProv.loading) {
      context.read<BookProvider>().refresh();
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFECFDFC), Color(0xFFC5F2D6)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ─── Header Row ───
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('SmartBook',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF00A480),
                        )),
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () => Navigator.pushNamed(context, '/profile'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ─── Welcome Text ───
                Text('Welcome back, $name!',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    )),
                const SizedBox(height: 24),

                // ─── Continue Reading Section ───
                const _SectionTitle('Continue Reading'),
                const SizedBox(height: 8),
                _ContinueReadingTile(book: bookProv.books.isNotEmpty ? bookProv.books.first : null),
                const SizedBox(height: 24),

                // ─── Just for You Section ───
                const _SectionTitle('Just for You'),
                const SizedBox(height: 8),
                _HorizontalCovers(books: bookProv.books.take(10).toList()),
                const SizedBox(height: 24),

                // ─── Trending Section ───
                const _SectionTitle('Trending'),
                const SizedBox(height: 8),
                _HorizontalCovers(books: bookProv.books.reversed.take(10).toList()),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

 
/// _SectionTitle – Reusable title widget for sections
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      );
}

 
/// ContinueReadingTile – Large visual tile for "Continue Reading"
 
class _ContinueReadingTile extends StatelessWidget {
  final Book? book;
  const _ContinueReadingTile({this.book});

  @override
  Widget build(BuildContext context) {
    if (book == null) {
      // Show placeholder tile if no book
      return Container(
        height: 160,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
        ),
      );
    }

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/book_info', arguments: book),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            // Book cover background
            Image.network(book!.thumbnail,
                height: 160, width: double.infinity, fit: BoxFit.cover),

            // Book title + author overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.black.withOpacity(.6),
                child: Text(
                  'Title: ${book!.title}\nAuthor: ${book!.authors}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),

            // Continue button on bottom-right
            Positioned(
              bottom: 8,
              right: 8,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(.7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onPressed: () => Navigator.pushNamed(context, '/book_info', arguments: book),
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

 
/// HorizontalCovers – Scrollable horizontal list of book covers
 
class _HorizontalCovers extends StatelessWidget {
  final List<Book> books;
  const _HorizontalCovers({required this.books});

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) {
      return const SizedBox(height: 120, child: Center(child: Text('…loading…')));
    }

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: books.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/book_info', arguments: books[i]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              books[i].thumbnail,
              width: 80,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
