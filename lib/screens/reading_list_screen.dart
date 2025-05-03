import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../models/book.dart';

/// Screen to display a user's reading list, categorized by Firebase data.
/// Each book is shown in a 2-column grid layout.
class ReadingListScreen extends StatelessWidget {
  const ReadingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Grab the current user ID from the AuthProvider
    final uid = context.read<AuthProvider>().user!.uid;

    // Get an instance of the Firestore service
    final fs  = FirestoreService();

    return Scaffold(
      // Background gradient
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8FFF2), Color(0xFFC8EFD9)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              /*  HEADER  */
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    // Home button (navigates back to dashboard)
                    IconButton(
                      icon: const Icon(Icons.home),
                      onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                    ),
                    const Spacer(),

                    // App title
                    Text(
                      'SmartBook',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64C7A6),
                      ),
                    ),
                    const Spacer(),

                    // Settings (not yet implemented)
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () {}, // TODO
                    ),
                  ],
                ),
              ),

              /*  TITLE SECTION  */
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.remove), // decorative minus icon
                    const SizedBox(width: 6),

                    // Main title
                    Text(
                      'My Reading List',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const Spacer(),
                    const Icon(Icons.add), // decorative plus icon
                  ],
                ),
              ),

              /*  BOOK GRID LIST  */
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: fs.readingList(uid), // fetch user's reading list in real-time
                  builder: (_, snap) {
                    // Show loading indicator if no data yet
                    if (!snap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snap.data!;
                    if (docs.isEmpty) {
                      return const Center(child: Text('Nothing here yet'));
                    }

                    // Convert map data into list of Book models
                    final books = docs.map((m) => Book.fromMap(m)).toList();

                    // Show books in a responsive 2-column grid
                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // two columns
                        mainAxisSpacing: 24,
                        crossAxisSpacing: 24,
                        childAspectRatio: .66, // taller than wide (book shape)
                      ),
                      itemCount: books.length,
                      itemBuilder: (_, i) => GestureDetector(
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/book_info',
                          arguments: books[i], // pass tapped book to info page
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            books[i].thumbnail,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
