import 'package:flutter/material.dart';

import '/models/book.dart';
import '/services/google_books_service.dart';


/// CatalogScreen – search & grid view
/// • Header: home icon (returns to dashboard), SmartBook title, settings gear
/// • Rounded search field with hamburger prefix + search icon suffix
/// • 2‑column grid of book covers
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _ctrl = TextEditingController();

  List<Book> _results = [];
  bool _loading = false;

  Future<void> _search(String q) async {
    if (q.trim().isEmpty) return;
    setState(() => _loading = true);
    _results = await GoogleBooksService.search(q.trim());
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFECFDFC), Color(0xFFC5F2D6)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header 
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.home),
                      onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                    ),
                    const Spacer(),
                    const Text('SmartBook',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00A480),
                        )),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () => Navigator.pushNamed(context, '/profile'),
                    ),
                  ],
                ),
              ),

              // Search Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SizedBox(
                  height: 46,
                  child: TextField(
                    controller: _ctrl,
                    textInputAction: TextInputAction.search,
                    onSubmitted: _search,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(.7),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      prefixIcon: const Icon(Icons.menu),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () => _search(_ctrl.text),
                      ),
                      hintText: 'Dog',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),

              if (_loading) const LinearProgressIndicator(),

              // Grid of covers
              Expanded(
                child: _results.isEmpty && !_loading
                    ? const Center(child: Text('Search something…'))
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: .68,
                        ),
                        itemCount: _results.length,
                        itemBuilder: (_, i) {
                          final b = _results[i];
                          return GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/book_info', arguments: b),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                b.thumbnail,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}