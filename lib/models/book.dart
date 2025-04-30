/// Minimal data we need from Google Books.
/// (We cache this in Firestore later.)
class Book {
  final String id;
  final String title;
  final String authors;
  final String thumbnail;
  final String description;
  final double rating;

  Book({
    required this.id,
    required this.title,
    required this.authors,
    required this.thumbnail,
    required this.rating,
    required this.description,
  });
  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'authors': authors,
    'thumbnail': thumbnail,
    'rating': rating,
    'description': description,
  };

  /// Factory constructor that converts one Google-Books JSON item
  /// into our plain-Dart Book object.
  factory Book.fromGoogle(Map<String, dynamic> item) {
    final v = item['volumeInfo'] ?? {};
    return Book(
      id: item['id'],
      title: v['title'] ?? 'Unknown',
      authors: (v['authors'] ?? ['Unknown']).join(', '),
      thumbnail:
          (v['imageLinks']?['thumbnail']) ??
          'https://via.placeholder.com/128x198.png?text=No+Cover',
      rating: (v['averageRating'] ?? 0).toDouble(),
      description: v['description'] ?? '',
    );
  }
}
