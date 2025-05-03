import 'package:firebase_core/firebase_core.dart';   // FirebaseException
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/models/book.dart';
import '/providers/auth_provider.dart';
import '/services/firestore_service.dart';

class BookInfoScreen extends StatelessWidget {
  const BookInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final book = ModalRoute.of(context)!.settings.arguments as Book;
    final uid  = context.read<AuthProvider>().user!.uid;
    final fs   = FirestoreService();
    final t    = Theme.of(context);

    return Scaffold(
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
              /* header */
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.home),
                      onPressed: () => Navigator.pushReplacementNamed(
                          context, '/home'),
                    ),
                    const Spacer(),
                    Text('SmartBook',
                        style: t.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64C7A6))),
                    const Spacer(),
                    IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    /* cover */
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(book.thumbnail, height: 240),
                      ),
                    ),
                    const SizedBox(height: 16),

                    /* title / author */
                    Text(book.title,
                        style: t.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    Text('by ${book.authors}',
                        style: t.textTheme.bodyMedium
                            ?.copyWith(fontStyle: FontStyle.italic)),
                    const SizedBox(height: 16),

                    /* description */
                    Text(book.description),
                  ],
                ),
              ),

              /* add to list + review buttons */
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.library_add),
                        label: const Text('Add to list'),
                        onPressed: () =>
                            _showListDialog(context, fs, uid, book),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.rate_review),
                      label: const Text('Review'),
                      onPressed: () => Navigator.pushNamed(
                          context, '/rate_and_review',
                          arguments: book),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  

  Future<void> _showListDialog(BuildContext ctx, FirestoreService fs,
      String uid, Book book) async {
    final status = await showDialog<String>(
      context: ctx,
      builder: (_) => SimpleDialog(
        title: const Text('Add to…'),
        children: [
          SimpleDialogOption(
            child: const Text('Want to Read'),
            onPressed: () => Navigator.pop(ctx, 'want'),
          ),
          SimpleDialogOption(
            child: const Text('Currently Reading'),
            onPressed: () => Navigator.pop(ctx, 'current'),
          ),
          SimpleDialogOption(
            child: const Text('Finished'),
            onPressed: () => Navigator.pop(ctx, 'finished'),
          ),
        ],
      ),
    );

    if (status != null) {
      try {
        await fs.cacheBook(book);
        await fs.addToReadingList(uid, book, status);
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text('Added to $status list')),
        );
      } on FirebaseException catch (e) {
        debugPrint('❌ addToReadingList → ${e.code}  ${e.message}');
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text('Error: ${e.code}')),
        );
      }
    }
  }
}
