import 'package:flutter/material.dart';
import 'dart:async';  // for the delay timer

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Tracks if component is mounted - fixing that nasty setState error
  bool _mounted = true;
  
  @override
  void initState() {
    super.initState();
    
    // Wait 3 secs before going to login
    // TODO: Maybe make this configurable?
    Timer(Duration(seconds: 3), () {
      // Had to add this check because of occasional navigation errors
      if (_mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });
  }

  @override 
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Using that mint theme from main.dart
    var bgColor = const Color(0xFFB6E4CA);
    
    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Container(
          // Added some padding to make it look nicer on different screens
          padding: EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            // Slightly darker shade for the container
            color: const Color(0xFF95F2D9),  
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Logo goes here
              Image.asset(
                'assets/images/logo/smartbook_logo.svg',
                width: 100.0,  // might need to adjust this
                height: 100.0,
                // errorBuilder: (context, error, stackTrace) {
                //   return Icon(Icons.error);  // backup plan if image fails
                // },
              ),
              
              // Quick spacing hack
              SizedBox(height: 16),
              
              // Welcome text - keeping it simple for now
              Text(
                "Welcome to SmartBook!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}