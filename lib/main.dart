import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'providers/auth_provider.dart';
import 'providers/book_provider.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
/* import 'screens/catalog_screen.dart';
import 'screens/book_info_screen.dart';
import 'screens/reading_list_screen.dart';
import 'screens/rate_and_review_screen.dart';
import 'screens/forum_screen.dart';
import 'screens/profile_screen.dart'; */

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
        '/': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const HomeScreen(),
        /* '/catalog': (_) => const CatalogScreen(),
        '/book_info': (_) => const BookInfoScreen(),
        '/reading_list': (_) => const ReadingListScreen(),
        '/rate_and_review': (_) => const RateAndReviewScreen(),
        '/forum': (_) => const ForumScreen(),
        '/profile': (_) => const ProfileScreen(), */
      },
    ),
  );
}
