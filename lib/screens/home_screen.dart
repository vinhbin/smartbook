import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/providers/book_provider.dart';
import '/widgets/book_card.dart';
import '/models/book.dart';

/// Home screen showing the user a scrollable, paginated list of book
/// recommendations.  All data and paging state come from [BookProvider].
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

    // Lazy‑load next page when the user nears the bottom (250 px threshold).
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
    return Consumer<BookProvider>(
      builder: (_, prov, __) {
        final books = prov.books;
        final hasMore = prov.hasMore;

        return Scaffold(
          appBar: AppBar(title: const Text('Recommended Books')),
          body: RefreshIndicator(
            onRefresh: prov.refresh,
            child: ListView.builder(
              controller: _scrollCtrl,
              itemCount: books.length + (hasMore ? 1 : 0), // extra slot for spinner
              itemBuilder: (_, i) {
                // Real book rows
                if (i < books.length) {
                  final Book b = books[i];
                  return GestureDetector(
                    onTap: () async {
                      // Open detail page; when user returns, mark it as "rated" so
                      // the next recommendation query can include a similarity hint.
                      await Navigator.pushNamed(
                        context,
                        '/book_info',
                        arguments: b,
                      );
                      if (mounted) prov.addRating(b.id);
                    },
                    child: BookCard(book: b),
                  );
                }

                // Trailing loading indicator while fetching next page
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
