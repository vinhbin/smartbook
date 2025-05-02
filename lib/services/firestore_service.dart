import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';

/// Centralised Firestore access so widgets don’t repeat path strings.
class FirestoreService {
  final _db = FirebaseFirestore.instance;
  FirebaseFirestore get db => _db;

  /* USER READING-LIST */

  /// users/{uid}/readingList/{bookId}  →  {status: want|current|finished}
  Future<void> addToReadingList(String uid, Book b, String status) async =>
      _db.doc('users/$uid/readingList/${b.id}').set({
        'status': status,
        'addedAt': FieldValue.serverTimestamp(),
        ...b.toMap(), // cache metadata for offline display
      });

  Future<void> moveReadingList(
    String uid,
    String bookId,
    String newStatus,
  ) async =>
      _db.doc('users/$uid/readingList/$bookId').update({'status': newStatus});

  Future<void> removeFromReadingList(String uid, String bookId) async =>
      _db.doc('users/$uid/readingList/$bookId').delete();

  Stream<List<Map<String, dynamic>>> readingList(String uid) => _db
      .collection('users/$uid/readingList')
      .snapshots()
      .map((s) => s.docs.map((d) => d.data()..['id'] = d.id).toList());

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
}
