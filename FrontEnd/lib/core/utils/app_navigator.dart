import 'package:flutter/material.dart';

/// Clé globale permettant de naviguer depuis
/// n'importe où sans BuildContext
/// (notamment depuis les intercepteurs Dio)
class AppNavigator {
  static final GlobalKey<NavigatorState> key =
  GlobalKey<NavigatorState>();

  static NavigatorState? get state => key.currentState;

  static Future<T?>? push<T>(Widget page) {
    return state?.push<T>(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  static Future<T?>? pushReplacement<T>(Widget page) {
    return state?.pushReplacement<T, dynamic>(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  static void pushAndRemoveAll(Widget page) {
    state?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => page),
          (route) => false,
    );
  }

  static void pop<T>([T? result]) {
    state?.pop<T>(result);
  }
}