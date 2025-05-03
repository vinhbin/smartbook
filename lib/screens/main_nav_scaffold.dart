import 'package:flutter/material.dart';
import 'package:smartbook/screens/reviews_screen.dart';

import '/screens/home_screen.dart';               // dashboard (default)
import '/screens/catalog_screen.dart';            // 🔍
import '/screens/reading_list_screen.dart';       // 📚
import '/screens/rate_and_review_screen.dart';    // ⭐ history (simple list wrapper for now)
import '/screens/forum_screen.dart';              // 💬
import '/screens/profile_screen.dart';            // 👤
 
/// MainNavScaffold – holds a persistent bottom‑navigation bar.
///   •  Every screen keeps the bottom bar visible.
///   •  Five bottom destinations in order: Catalog, Reading List, My Reviews,
///      Forum, Profile.
class MainNavScaffold extends StatefulWidget {
  const MainNavScaffold({super.key});

  @override
  State<MainNavScaffold> createState() => _MainNavScaffoldState();
}

class _MainNavScaffoldState extends State<MainNavScaffold> {
  // if true we show the dashboard regardless of [_idx]
  bool _showDashboard = true;

  int _idx = 0; // 0..4 for the five bottom tabs

  // keep tab pages alive
  final _tabs = const [
    CatalogScreen(),
    ReadingListScreen(),
    ReviewsScreen(),
    ForumScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _showDashboard ? const HomeScreen() : _tabs[_idx],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        onDestinationSelected: (i) => setState(() {
          _idx = i;
          _showDashboard = false; // leaving dashboard
        }),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.search),      label: 'Catalog'),
          NavigationDestination(icon: Icon(Icons.menu_book),   label: 'Reading'),
          NavigationDestination(icon: Icon(Icons.star_border), label: 'Reviews'),
          NavigationDestination(icon: Icon(Icons.forum),       label: 'Forum'),
          NavigationDestination(icon: Icon(Icons.person),      label: 'Profile'),
        ],
      ),
    );
  }

  // helper to return to dashboard; can be called from any AppBar leading icon
  void goHome() => setState(() => _showDashboard = true);
}

