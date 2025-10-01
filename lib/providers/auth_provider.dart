// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends InheritedWidget {
  final AuthService authService;

  const AuthProvider({
    super.key,
    required this.authService,
    required super.child,
  });

  // This is the static method that descendant widgets will use to get the service
  static AuthService of(BuildContext context) {
    final AuthProvider? result = context.dependOnInheritedWidgetOfExactType<AuthProvider>();
    assert(result != null, 'No AuthProvider found in context');
    return result!.authService;
  }

  @override
  bool updateShouldNotify(AuthProvider oldWidget) {
    // This is important for performance. We won't rebuild the whole tree,
    // we'll rely on the ValueNotifier for targeted rebuilds.
    return false;
  }
}