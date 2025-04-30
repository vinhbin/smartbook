import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/book_provider.dart'; // state for recs + paging
import '../widgets/book_card.dart'; // simple UI card
import '../models/book.dart'; // Book model

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();

    // Kick off the first page of recommendations.
    context.read<BookProvider>().refresh();

    // Lazy-load next page when the user nears the bottom (250 px threshold).
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 250) {
        context.read<BookProvider>().loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<BookProvider>();
    final books = prov.books; // current in-memory list
    final hasMore = prov.hasMore; // whether another page is available

    return Scaffold(
      appBar: AppBar(title: const Text('Recommended Books')),
      body: RefreshIndicator(
        onRefresh: () => context.read<BookProvider>().refresh(),
        child: ListView.builder(
          controller: _scrollCtrl,
          itemCount: books.length + (hasMore ? 1 : 0), // extra slot for spinner
          itemBuilder: (_, i) {
            // REAL book rows
            if (i < books.length) {
              final Book b = books[i];
              return GestureDetector(
                onTap: () async {
                  // open detail page; when user returns, mark it as “rated”
                  await Navigator.pushNamed(
                    context,
                    '/book_info',
                    arguments: b,
                  );
                  if (mounted) context.read<BookProvider>().addRating(b.id);
                },
                child: BookCard(book: b),
              );
            }

            // trailing loading indicator while fetching next page
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }
}
