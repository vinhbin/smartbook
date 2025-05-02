/// Minimal data we need from Google Books.
/// (We cache this in Firestore later.)
// Updated Book model to include category
class Book {
  final String id;
  final String title;
  final String authors;
  final String thumbnail;
  final String description;
  final double rating;
  final String? category; // Added category

  Book({
    required this.id,
    required this.title,
    required this.authors,
    required this.thumbnail,
    required this.rating,
    required this.description,
    this.category, // Added category to the constructor
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'authors': authors,
    'thumbnail': thumbnail,
    'rating': rating,
    'description': description,
    'category': category, // Added category to the map
  };

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
      category: v['categories'] != null && (v['categories'] as List).isNotEmpty
          ? v['categories'][0]
          : null, // Extract category, handle null/empty lists
    );
  }
}