import 'package:flutter/material.dart';
import 'package:smartbook/screens/splash_screen.dart';
import 'package:smartbook/screens/login_screen.dart';
import 'package:smartbook/screens/register_screen.dart';
// Screens for main functionality
import 'package:smartbook/screens/home_screen.dart';
import 'package:smartbook/screens/search_screen.dart';
import 'package:smartbook/screens/book_detail_screen.dart';
// User specific screens
import 'package:smartbook/screens/reading_list_screen.dart';
import 'package:smartbook/screens/review_screen.dart';
import 'package:smartbook/screens/discussion_screen.dart';
import 'package:smartbook/screens/profile_screen.dart';
import 'package:firebase_core/firebase_core.dart';  // needed for Firebase stuff

// Had to make this async because Firebase setup needs it
void main() async {
  // This fixed that weird platform channel error I kept getting
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase - might need to add error handling here later
  await Firebase.initializeApp();
  
  runApp(SmartBookApp());
}

class SmartBookApp extends StatelessWidget {
  // Using that nice mint green color I found online
  final mainColor = const Color(0xFFB6E4CA);
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartBook',
      theme: ThemeData(
        primaryColor: mainColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: mainColor,
        // Might add more theme customization here later
      ),
      home: SplashScreen(),  // Starting with splash screen for now
      
      // All the app routes - keeping them organized here
      // Maybe should move these to a separate router file?
      routes: {
        '/login': (_) => LoginScreen(),
        '/register': (_) => RegisterScreen(),
        '/home': (_) => HomeScreen(),
        '/search': (_) => SearchScreen(),
        '/book_detail': (_) => BookDetailScreen(),
        '/reading_list': (_) => ReadingListScreen(),
        '/review': (_) => ReviewScreen(),
        '/discussion': (_) => DiscussionScreen(),
        '/profile': (_) => ProfileScreen(),
        // '/settings': (_) => SettingsScreen(),  // will add this later if need be
      },
    );
  }
}