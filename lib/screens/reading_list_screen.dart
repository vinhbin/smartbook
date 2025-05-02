import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../widgets/book_card.dart';
import '../models/book.dart';

class ReadingListScreen extends StatelessWidget {
  const ReadingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().user!.uid;
    final fs = FirestoreService();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Reading List'),
          bottom: const TabBar(tabs: [
            Tab(text: 'Want'),
            Tab(text: 'Current'),
            Tab(text: 'Finished'),
          ]),
        ),
        body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: fs.readingList(uid),
          builder: (_, snap) {
            if (!snap.hasData) return const Center(child: CircularProgressIndicator());
            final all = snap.data!;
            return TabBarView(
              children: ['want', 'current', 'finished'].map((status) {
                final books = all
                    .where((m) => m['status'] == status)
                    .map((m) => Book.fromGoogle(m))
                    .toList();
                if (books.isEmpty) {
                  return const Center(child: Text('Nothing here yet'));
                }
                return ListView.builder(
                  itemCount: books.length,
                  itemBuilder: (_, i) => Dismissible(
                    key: ValueKey(books[i].id),
                    background: Container(color: Colors.red),
                    onDismissed: (_) =>
                        fs.removeFromReadingList(uid, books[i].id),
                    child: GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, '/book_info',
                              arguments: books[i]),
                      child: BookCard(book: books[i]),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
