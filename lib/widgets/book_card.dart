import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/book.dart';

/// Reusable card used by Home, Catalog, and Reading-List screens.
/// Tapping is handled by the parent (GestureDetector) so the card
/// itself stays dumb/presentational.
class BookCard extends StatelessWidget {
  final Book book;
  const BookCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    surfaceTintColor:
        Theme.of(context).colorScheme.surfaceVariant, // Material 3 flair
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          /*Cover */
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: CachedNetworkImage(
              imageUrl: book.thumbnail,
              width: 60,
              height: 90,
              fit: BoxFit.cover,
              placeholder:
                  (_, __) => Container(
                    color: Colors.grey.shade300,
                    width: 60,
                    height: 90,
                  ),
              errorWidget:
                  (_, __, ___) => const Icon(Icons.broken_image, size: 60),
            ),
          ),
          const SizedBox(width: 12),

          /*Title + author + rating*/
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  book.authors,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(.7),
                  ),
                ),
                const SizedBox(height: 6),
                _Stars(rating: book.rating),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

/// Tiny helper widget that draws 0-5 filled stars
class _Stars extends StatelessWidget {
  final double rating;
  const _Stars({required this.rating});

  @override
  Widget build(BuildContext context) {
    final full = rating.floor();
    return Row(
      children: List.generate(5, (i) {
        return Icon(
          i < full ? Icons.star : Icons.star_border,
          size: 16,
          color: Colors.amber,
        );
      }),
    );
  }
}
