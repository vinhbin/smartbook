import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:smartbook/screens/history_screen.dart';
import 'package:smartbook/screens/main_nav_scaffold.dart';
import 'package:smartbook/screens/reviews_screen.dart';
import 'package:smartbook/screens/stats_screen.dart';
import 'firebase_options.dart';

import 'providers/auth_provider.dart';
import 'providers/book_provider.dart';
import 'services/google_books_service.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/catalog_screen.dart';
import 'screens/book_info_screen.dart';
import 'screens/reading_list_screen.dart';
import 'screens/rate_and_review_screen.dart';
import 'screens/forum_screen.dart';
import 'screens/profile_screen.dart';

/// Entry point – make sure Firebase is ready before runApp().
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const SmartBookApp());
}

/// Root widget providing global state (Auth + Books) to the subtree.
class SmartBookApp extends StatelessWidget {
  const SmartBookApp({super.key});

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => BookProvider()),
    ],
    child: MaterialApp(
      title: 'SmartBook',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFFB6E4CA), // mint palette
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => SplashScreen(),
        '/login': (_) => LoginScreen(),
        '/register': (_) => RegisterScreen(),
        '/home': (_) => const MainNavScaffold(),
        '/catalog': (_) => CatalogScreen(),
        '/book_info': (_) => const BookInfoScreen(),
        '/reading_list': (_) => const ReadingListScreen(),
        '/rate_and_review': (_) => const RateAndReviewScreen(),
        '/forum': (_) => const ForumScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/stats':    (_) => const StatsScreen(),
        '/myreviews':(_) => const ReviewsScreen(),
        '/history':  (_) => const HistoryScreen(),

      },
    ),
  );
}