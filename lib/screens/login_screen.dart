import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'main_screen.dart';
import '../services/auth_service.dart';
import '../l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();

  bool _isLoading = false;
  bool _rememberMe = true; // Default to true for user convenience

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
    });

    // ** THE FIX: The variable 'loginResult' is now a Map, not a String **
    final Map<String, dynamic>? loginResult = await _apiService.login(
      _emailController.text,
      _passwordController.text,
    );

    if (mounted) {
      if (loginResult != null) {
        // Extract the data from the map
        final token = loginResult['access_token'];
        final user = loginResult['user'];
        final permissions = user['permissions'];

        // Now, call the AuthService with the correct, extracted data
        await AuthService().saveAuthDataBasedOnRememberMe(
          rememberMe: _rememberMe,
          token: token,
          user: user,
          permissions: permissions,
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login Failed. Please check your credentials.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
      // No need for a second setState here, the navigation handles it.
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define the new gradient and accent colors
    const Color gradientTop = Color(0xFF86B9B7);
    const Color gradientBottom = Color(0xFFB2D8B4);
    const Color darkAccent = Color(0xFF2A3B4D); // A dark color for contrast
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        // ** 1. THE NEW GRADIENT BACKGROUND **
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [gradientTop, gradientBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              
              // ** 2. BRING BACK THE GLASSMORPHISM EFFECT **
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      // Use a semi-transparent white for a light, airy glass feel
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ** 3. ADJUST CONTENT COLORS FOR READABILITY **
                        // Use the dark accent color for text on the light glass background
                        Image.asset('assets/icon/launcher_icon.png', height: 64, width: 64),
                        const SizedBox(height: 16),
                        const Text(
                          'Momota Hall',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: darkAccent),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.welcomeToLogin,
                          style: TextStyle(color: darkAccent.withOpacity(0.8), fontSize: 16),
                        ),
                        const SizedBox(height: 32),

                        // Form Fields styled for a light glass background
                        TextFormField(
                          controller: _emailController,
                          style: const TextStyle(color: darkAccent),
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(color: darkAccent.withOpacity(0.7)),
                            prefixIcon: const Icon(Icons.email_outlined, color: darkAccent),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: darkAccent.withOpacity(0.3))),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: darkAccent)),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          style: const TextStyle(color: darkAccent),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(color: darkAccent.withOpacity(0.7)),
                            prefixIcon: const Icon(Icons.lock_outline, color: darkAccent),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: darkAccent.withOpacity(0.3))),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: darkAccent)),
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 16),
                        
                        CheckboxListTile(
                          title: Text(l10n.stayLoggedIn, style: const TextStyle(color: darkAccent)),
                          value: _rememberMe,
                          onChanged: (newValue) => setState(() => _rememberMe = newValue ?? false),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          activeColor: darkAccent,
                        ),
                        const SizedBox(height: 24),
                        
                        _isLoading
                            ? const CircularProgressIndicator(color: darkAccent)
                            : SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: darkAccent, // Use the dark accent for the button
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 4,
                                  ),
                                  child: Text(l10n.login.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
