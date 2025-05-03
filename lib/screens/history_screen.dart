import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/auth_provider.dart';
import '/services/firestore_service.dart';
import '/models/book.dart';

/// Displays the user's reading history with timestamps and status
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get current user's UID from authentication provider
    final uid = context.read<AuthProvider>().user!.uid;

    // Initialize Firestore service
    final fs = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Reading History')),

      // Listen to changes in the reading list collection for the user
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: fs.readingList(uid), // Live stream of books user added
        builder: (_, snap) {
          if (!snap.hasData) {
            // Show spinner while loading
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data!;
          if (docs.isEmpty) return const Center(child: Text('Nothing yet'));

          // Sort books by most recent using their 'addedAt' timestamp
          docs.sort((a, b) =>
              (b['addedAt'] ?? Timestamp.now()).compareTo(a['addedAt'] ?? 0));

          // Build a vertical list of reading history items
          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 0),
            itemBuilder: (_, i) {
              final m = docs[i];
              final b = Book.fromMap(m); // Convert map to Book model

              // List tile with cover, title, and reading status
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    b.thumbnail,
                    width: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(b.title),
                subtitle: Text(m['status']),
                // On tap → navigate to detailed book view
                onTap: () => Navigator.pushNamed(
                  context,
                  '/book_info',
                  arguments: b,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
