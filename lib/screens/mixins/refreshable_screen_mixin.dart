// lib/screens/mixins/refreshable_screen_mixin.dart
import 'package:flutter/material.dart';

// This mixin ensures that any screen using it will have a refreshData method.
mixin RefreshableScreenState<T extends StatefulWidget> on State<T> {
  Future<void> refreshData();
}