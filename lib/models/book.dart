/// Book – minimal metadata we keep from Google Books (and cache in Firestore).
class Book {
  final String id;
  final String title;
  final String authors;
  final String thumbnail;
  final String description;
  final double rating;
  final String? category; // optional

  Book({
    required this.id,
    required this.title,
    required this.authors,
    required this.thumbnail,
    required this.rating,
    required this.description,
    this.category,
  });

  /*helpers*/

  // Upgrade http → https 
  static String _https(String? url) =>
      (url ?? '').replaceFirst('http://', 'https://');

  static const _noCover =
      'https://via.placeholder.com/128x198.png?text=No+Cover';

  /*Firestore round‑trip*/

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'authors': authors,
        'thumbnail': thumbnail,
        'rating': rating,
        'description': description,
        'category': category,
      };

  /// Factory for docs read back from Firestore (`users/…/readingList`, etc.).
  factory Book.fromMap(Map<String, dynamic> m) => Book(
        id:          m['id'] ?? '',
        title:       m['title'] ?? 'Unknown',
        authors:     m['authors'] ?? 'Unknown',
        thumbnail:   _https(m['thumbnail']).isEmpty
            ? _noCover
            : _https(m['thumbnail']),
        rating:      (m['rating'] ?? 0).toDouble(),
        description: m['description'] ?? '',
        category:    m['category'],
      );

  /*Google Books JSON*/

  /// Convert one Google‑Books API item into a `Book`.
  factory Book.fromGoogle(Map<String, dynamic> item) {
    final v = item['volumeInfo'] ?? <String, dynamic>{};

    // raw URL from the API (may be null or http://)
    final rawThumb = v['imageLinks']?['thumbnail'] as String?;

    return Book(
      id:          item['id'] ?? '',
      title:       v['title'] ?? 'Unknown',
      authors:     (v['authors'] ?? ['Unknown']).join(', '),
      thumbnail:   _https(rawThumb).isEmpty ? _noCover : _https(rawThumb),
      rating:      (v['averageRating'] ?? 0).toDouble(),
      description: v['description'] ?? '',
      category:    (v['categories'] as List?)?.first,
    );
  }
}
