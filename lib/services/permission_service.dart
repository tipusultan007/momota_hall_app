import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PermissionService {
  // --- Singleton Pattern ---
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();
  // -------------------------

  Set<String> _permissions = {};

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final permissionsString = prefs.getString('user_permissions');
    if (permissionsString != null) {
      final List<dynamic> permissionsList = jsonDecode(permissionsString);
      _permissions = permissionsList.map((p) => p.toString()).toSet();
      print('[PermissionService] Permissions loaded successfully: $_permissions'); // For debugging
    } else {
      print('[PermissionService] No permissions found in storage.');
    }
  }

    List<String> getAllPermissions() {
    var permissionsList = _permissions.toList();
    permissionsList.sort(); // Sort them alphabetically for a clean display
    return permissionsList;
  }

  /// Saves the user's permissions to local storage after login.
  Future<void> savePermissions(List<dynamic> permissionsList) async {
    _permissions = permissionsList.map((p) => p.toString()).toSet();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_permissions', jsonEncode(_permissions.toList()));
  }

  /// Clears permissions from memory and local storage on logout.
  Future<void> clearPermissions() async {
    _permissions = {};
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_permissions');
  }

  /// The main method to check if a user has a specific permission.
  bool can(String permission) {
    // A super-admin can do anything, regardless of specific permissions.
    if (_permissions.contains('super-admin')) return true;
    return _permissions.contains(permission);
  }
}