import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'permission_service.dart';

class AuthService with ChangeNotifier { // Using 'with ChangeNotifier' is often cleaner
  // Singleton Pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  String? _token;
  String? _userName;
  
  String? get token => _token;
  String? get userName => _userName;
  bool get isLoggedIn => _token != null;

  /// Loads token, user name, and permissions from storage into memory.
  /// This should be called once when the app starts.
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _userName = prefs.getString('user_name'); // Load the name from storage
    
    if (isLoggedIn) {
      await PermissionService().initialize();
    } else {
      await PermissionService().clearPermissions();
    }
    // No need to call notifyListeners() here as the app startup logic handles the initial build.
  }

  /// ** THE NEW, CORRECTED METHOD **
  /// Saves all authentication data to memory and local storage after a successful login.
  Future<void> saveAuthData({
    required String token,
    required Map<String, dynamic> user,
    required List<dynamic> permissions,
  }) async {
    // 1. Save to memory
    _token = token;
    _userName = user['name'];

    // 2. Save to local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('user_name', _userName!); // Save user name

    // 3. Save permissions
    await PermissionService().savePermissions(permissions);
    
    // 4. Notify the app that the user is now logged in
    notifyListeners();
  }
  
  /// Clears all authentication data from memory and storage on logout.
  Future<void> clearAuthData() async {
    // 1. Clear from memory
    _token = null;
    _userName = null;
    
    // 2. Clear from local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user_name');
    
    // 3. Clear permissions
    await PermissionService().clearPermissions();
    
    // 4. Notify the app that the user has logged out
    notifyListeners();
  }
}