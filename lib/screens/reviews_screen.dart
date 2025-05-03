import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/auth_provider.dart';
import '/services/firestore_service.dart';
import '/models/review.dart';

/// This screen displays the list of reviews submitted by the current user.
class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get current user's UID and Firestore service instance
    final uid = context.read<AuthProvider>().user!.uid;
    final fs  = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('My Reviews')),

      // Real-time stream of user's reviews from Firestore
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: fs.userReviews(uid),
        builder: (_, snap) {
          if (!snap.hasData) {
            // Show loading spinner while waiting for data
            return const Center(child: CircularProgressIndicator());
          }

          // Convert each Firestore map into a Review object
          final reviews = snap.data!.map((m) => Review.fromMap(m)).toList();

          // Show message if user hasn't submitted any reviews
          if (reviews.isEmpty) {
            return const Center(child: Text('No reviews yet'));
          }

          // Display each review in a scrollable list
          return ListView.separated(
            itemCount: reviews.length,
            separatorBuilder: (_, __) => const Divider(height: 0),
            itemBuilder: (_, i) {
              final r = reviews[i];
              return ListTile(
                leading: Text('★' * r.rating), // Show rating as stars
                title: Text(r.text),           // Review content
                subtitle: Text(
                  r.createdAt?.toLocal().toString() ?? '', // Format timestamp
                ),
              );
            },
          );
        },
      ),
    );
  }
}
