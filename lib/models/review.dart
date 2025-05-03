import 'package:cloud_firestore/cloud_firestore.dart';

/// Model class representing a user's review on a book.
class Review {
  // Unique identifier for the review
  final String id;

  // ID of the book this review is associated with
  final String bookId;

  // Review content (text written by the user)
  final String text;

  // Numeric rating (e.g., from 1 to 5)
  final int rating;

  // Timestamp of when the review was created (nullable)
  final DateTime? createdAt;

  /// Constructor for creating a new Review object
  Review({
    required this.id,
    required this.bookId,
    required this.text,
    required this.rating,
    required this.createdAt,
  });

  /// Factory constructor to build a Review from Firestore data
  factory Review.fromMap(Map<String, dynamic> m) => Review(
        id:        m['id']      as String,  // Review document ID
        bookId:    m['bookId']  as String,  // Associated book ID
        text:      m['text']    ?? '',      // Default to empty string if missing
        rating:    m['rating']  ?? 0,       // Default to 0 if missing
        createdAt: (m['createdAt'] is Timestamp)   // Convert Firestore Timestamp to DateTime
            ? (m['createdAt'] as Timestamp).toDate()
            : null, // Handle cases where createdAt might be null or missing
      );
}
