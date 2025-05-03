import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/models/book.dart';
import '/providers/auth_provider.dart';
import '/services/firestore_service.dart';

/// RateAndReviewScreen allows the user to rate and write a review for a selected book.
/// UI includes a header, book cover, rating slider, review form, and submit button.
class RateAndReviewScreen extends StatefulWidget {
  const RateAndReviewScreen({super.key});

  @override
  State<RateAndReviewScreen> createState() => _RateAndReviewScreenState();
}

class _RateAndReviewScreenState extends State<RateAndReviewScreen> {
  // Global key to validate form inputs
  final _formKey   = GlobalKey<FormState>();

  // Controller for the main review text
  final _textCtrl  = TextEditingController();

  // Controller for the optional review title
  final _titleCtrl = TextEditingController();

  // Default slider value for rating
  int _rating      = 3;

  @override
  Widget build(BuildContext context) {
    // Get book passed from previous screen
    final Book book = ModalRoute.of(context)!.settings.arguments as Book;

    // Authenticated user's UID and FirestoreService instance
    final uid  = context.read<AuthProvider>().user!.uid;
    final fs   = FirestoreService();
    final t    = Theme.of(context); // Theme for consistent text styling

    return Scaffold(
      body: Container(
        // Gradient background
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
              /*  Header with Home and Settings  */
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    // Home button navigates to dashboard
                    IconButton(
                      icon: const Icon(Icons.home),
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/home'),
                    ),
                    const Spacer(),

                    // Title in center
                    Text(
                      'SmartBook',
                      style: t.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64C7A6),
                      ),
                    ),
                    const Spacer(),

                    // Placeholder for settings
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () {}, // (future implementation)
                    ),
                  ],
                ),
              ),

              /*  Main Scrollable Content  */
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Book cover
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(book.thumbnail,
                              height: 240, fit: BoxFit.cover),
                        ),
                        const SizedBox(height: 12),

                        // Rating label
                        Text('Rate',
                            style: t.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700)),

                        // Rating slider (1 to 5 stars)
                        Slider(
                          label: '$_rating',
                          divisions: 4,
                          min: 1,
                          max: 5,
                          value: _rating.toDouble(),
                          onChanged: (v) =>
                              setState(() => _rating = v.round()),
                        ),
                        const SizedBox(height: 4),

                        // Review input
                        TextFormField(
                          controller: _textCtrl,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Review',
                            hintText: 'What did you think?',
                            filled: true,
                          ),
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Please write something'
                              : null,
                        ),
                        const SizedBox(height: 12),

                        // Optional title field
                        TextFormField(
                          controller: _titleCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Title (optional)',
                            filled: true,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Submit button
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () async {
                              // Only submit if form input is valid
                              if (_formKey.currentState!.validate()) {
                                // Save review to Firestore
                                await fs.submitReview(
                                  uid,
                                  book.id,
                                  rating: _rating,
                                  text: _textCtrl.text.trim(),
                                  // NOTE: title is currently not saved in Firestore,
                                  // but you could extend FirestoreService to include it
                                );

                                // Navigate back to previous screen after submission
                                if (mounted) Navigator.pop(context);
                              }
                            },
                            child: const Text('Submit'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Clean up controllers to prevent memory leaks
  @override
  void dispose() {
    _textCtrl.dispose();
    _titleCtrl.dispose();
    super.dispose();
  }
}
