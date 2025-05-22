import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moneywise/data/repo/auth_repo.dart';
import 'package:moneywise/ui/auth/auth_screen.dart';
import 'package:moneywise/ui/home/home_screen.dart';

class Navigation {
  static const initial = '/';
  static final AuthNotifier authNotifier = AuthNotifier();

  static final routes = GoRouter(
    initialLocation: '/',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final user = authNotifier.user;
      final loggingIn = state.matchedLocation == '/login';

      if (user == null && !loggingIn) return '/login';
      if (user != null && loggingIn) return '/';

      return null; // stay on current route
    },
    routes: [
      GoRoute(
        path: '/login',
        name: Screens.login.name,
        builder: (context, state) => AuthScreen(),
      ),
      GoRoute(
        path: '/',
        name: Screens.home.name,
        builder: (context, state) => HomeScreen(user: authNotifier.user),
      ),
    ],
  );
}

// This class is used to notify listeners when the authentication state changes
// (e.g., when a user logs in or out). It listens to the FirebaseAuth instance's
// authStateChanges stream and calls notifyListeners() when the user is null.
// This is useful for updating the UI when the authentication state changes.
class AuthNotifier extends ChangeNotifier {
  User? _user;
  final repo = Authrepo();

  AuthNotifier() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;
}

enum Screens { home, login }
