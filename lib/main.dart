import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Use a Future to hold the login check result
  late Future<bool> _loggedInFuture;

  @override
  void initState() {
    super.initState();
    _loggedInFuture = _checkLoginStatus();
  }

  Future<bool> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    // It's logged in if the token is not null and not empty
    return prefs.getString('token')?.isNotEmpty ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Momota Hall App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        // Define a nice input decoration theme for all text fields
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      // Use a FutureBuilder to decide which screen to show on startup
      home: FutureBuilder<bool>(
        future: _loggedInFuture,
        builder: (context, snapshot) {
          // Show a loading screen while checking
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          
          // If check is complete, decide the screen
          if (snapshot.hasData && snapshot.data == true) {
            return const MainScreen(); // User is logged in, go to main screen
          } else {
            return const LoginScreen(); // User is not logged in, go to login
          }
        },
      ),
    );
  }
}