import 'package:cloud_firestore/cloud_firestore.dart';
import '/models/book.dart';

/// Centralised Firestore access so widgets don’t repeat path strings.
class FirestoreService {
  final _db = FirebaseFirestore.instance;
  FirebaseFirestore get db => _db;

  // helper to make Firestore‑safe document IDs
  String _safeId(String raw) => raw.replaceAll('/', '_');

  /* USER READING‑LIST */
 /// live stream of every item in the user’s reading list
 Stream<List<Map<String, dynamic>>> readingList(String uid) => _db
     .collection('users/$uid/readingList')
     .orderBy('addedAt', descending: true)
     .snapshots()
     .map((s) => s.docs
         .map((d) => d.data()..['id'] = d.id)   // keep the doc ID
         .toList());

  Future<void> addToReadingList(String uid, Book b, String status) =>
      _db.doc('users/$uid/readingList/${_safeId(b.id)}').set({
        'status': status,
        'addedAt': FieldValue.serverTimestamp(),
        ...b.toMap(),
      });

  Future<void> moveReadingList(String uid, String bookId, String newStatus) =>
      _db.doc('users/$uid/readingList/${_safeId(bookId)}')
         .update({'status': newStatus});

  Future<void> removeFromReadingList(String uid, String bookId) =>
      _db.doc('users/$uid/readingList/${_safeId(bookId)}').delete();

  /*BOOK REVIEWS */

  /// books/{bookId} keeps cached metadata (+avgRating, reviewCount)
  Future<void> cacheBook(Book b) =>
      _db.doc('books/${b.id}').set(b.toMap(), SetOptions(merge: true));

  Future<void> submitReview(
    String uid,
    String bookId, {
    required int rating,
    required String text,
  }) async {
    final reviewRef = _db.collection('books/$bookId/reviews').doc(); // auto-id
    await reviewRef.set({
      'uid': uid,
      'rating': rating,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Update aggregates atomically (avg rating & count)
    final bookRef = _db.doc('books/$bookId');
    await _db.runTransaction((txn) async {
      final snap = await txn.get(bookRef);
      final count = (snap.data()?['reviewCount'] ?? 0) as int;
      final avg = (snap.data()?['avgRating'] ?? 0.0) as double;
      final newCount = count + 1;
      final newAvg = ((avg * count) + rating) / newCount;
      txn.update(bookRef, {'avgRating': newAvg, 'reviewCount': newCount});
    });
  }

  Stream<List<Map<String, dynamic>>> reviews(String bookId) => _db
      .collection('books/$bookId/reviews')
      .orderBy('createdAt')
      .snapshots()
      .map((s) => s.docs.map((d) => d.data()..['id'] = d.id).toList());

  /*DISCUSSION BOARD */

  Future<void> addThread(String uid, String title) async =>
      _db.collection('threads').add({
        'title': title,
        'createdBy': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

  Stream<List<Map<String, dynamic>>> threads() => _db
      .collection('threads')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => d.data()..['id'] = d.id).toList());

  Future<void> addComment({
    required String uid,
    required String threadId,
    required String text,
  }) async => _db.collection('threads/$threadId/comments').add({
    'uid': uid,
    'text': text,
    'createdAt': FieldValue.serverTimestamp(),
  });

  Stream<List<Map<String, dynamic>>> comments(String threadId) => _db
      .collection('threads/$threadId/comments')
      .orderBy('createdAt')
      .snapshots()
      .map((s) => s.docs.map((d) => d.data()..['id'] = d.id).toList());
 
/// helpers for profile / statistics


// live counts for “want” / “current” / “finished”
Stream<Map<String, int>> readingCounts(String uid) => _db
    .collection('users/$uid/readingList')
    .snapshots()
    .map((s) {
      final map = <String, int>{'want': 0, 'current': 0, 'finished': 0};
      for (final d in s.docs) {
        final status = d['status'] ?? '';
        if (map.containsKey(status)) map[status] = map[status]! + 1;
      }
      return map;
    });

// all reviews written by this user (collection‑group query)
Stream<List<Map<String, dynamic>>> userReviews(String uid) => _db
    .collectionGroup('reviews')
    .where('uid', isEqualTo: uid)
    .orderBy('createdAt', descending: true)
    .snapshots()
    .map((s) => s.docs.map((d) {
          final data = d.data();
          // pull the bookId from the document path: books/{bookId}/reviews/{id}
          final bookId = d.reference.parent.parent!.id;
          data['bookId'] = bookId;
          data['id']     = d.id;
          return data;
        }).toList());

  
}
