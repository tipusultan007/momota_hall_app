import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'services/auth_service.dart';
import 'providers/auth_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'providers/locale_provider.dart'; // <-- 1. Import the new provider

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 2. Wrap your app in a MultiProvider to handle both Auth and Locale
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => LocaleProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthService _authService = AuthService(); // Create a single instance
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 3. Use Provider.of to get the AuthService instance and initialize it.
    // 'listen: false' is important here because we are in initState.
    await Provider.of<AuthService>(context, listen: false).initialize();
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

@override
  Widget build(BuildContext context) {
    // We use a Consumer for the LocaleProvider to get the current language.
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        // This MaterialApp will rebuild whenever the language changes.
        const Color primaryBlue = Color(0xFF2A3B4D);
        const Color accentGold = Color(0xFFC5A880);
        return MaterialApp(
          title: 'Momota Hall App',
          theme: ThemeData(
            useMaterial3: true,
        primaryColor: primaryBlue, // Main brand color
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBlue,
          primary: primaryBlue,
          secondary: accentGold,
        ),
        scaffoldBackgroundColor: const Color(0xFFFDFCF8), // Off-white background
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white, // Text/icon color on app bar
        ),
            fontFamily: 'Poppins', // Example of setting a default app font
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          
          // --- Localization Setup ---
          locale: localeProvider.locale, // Get the current locale from the provider
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          
          // --- Home Screen Logic ---
          home: !_isInitialized
              // Show a loading spinner while services are initializing
              ? const Scaffold(body: Center(child: CircularProgressIndicator()))
              // After initialization, use a Consumer to listen for LOGIN state changes
              : Consumer<AuthService>(
                  builder: (context, authService, child) {
                    // Decide which screen to show based on login status
                    if (authService.isLoggedIn) {
                      return const MainScreen();
                    } else {
                      return const LoginScreen();
                    }
                  },
                ),
        );
      },
    );
  }
}
