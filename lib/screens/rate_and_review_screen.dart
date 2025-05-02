import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';

class RateAndReviewScreen extends StatefulWidget {
  const RateAndReviewScreen({super.key});

  @override
  State<RateAndReviewScreen> createState() => _RateAndReviewScreenState();
}

class _RateAndReviewScreenState extends State<RateAndReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textCtrl = TextEditingController();
  int _rating = 3;

  @override
  Widget build(BuildContext context) {
    final Book book = ModalRoute.of(context)!.settings.arguments as Book;
    final uid = context.read<AuthProvider>().user!.uid;
    final fs = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: Text('Review ${book.title}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Slider(
                label: '$_rating',
                divisions: 4,
                min: 1,
                max: 5,
                value: _rating.toDouble(),
                onChanged: (v) => setState(() => _rating = v.round()),
              ),
              TextFormField(
                controller: _textCtrl,
                maxLines: 5,
                decoration:
                    const InputDecoration(labelText: 'Your review (required)'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Please write something' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await fs.submitReview(uid, book.id,
                          rating: _rating, text: _textCtrl.text.trim());
                      if (mounted) Navigator.pop(context);
                    }
                  },
                  child: const Text('Submit')),
            ],
          ),
        ),
      ),
    );
  }
}
