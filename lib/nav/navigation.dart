import 'package:go_router/go_router.dart';
import 'package:moneywise/ui/auth/login_screen.dart';
import 'package:moneywise/ui/auth/register_screen.dart';
import 'package:moneywise/ui/home/home_screen.dart';

class Navigation {
  static const initial = '/';

  static final routes = [
    GoRoute(
      path: '/',
      name: Screens.home.name,
      builder: (context, state) => const HomeScreen(),
    ),

    // Authentication routes
    GoRoute(
      path: '/login',
      name: Screens.login.name,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: Screens.register.name,
      builder: (context, state) => const RegisterScreen(),
    ),
  ];
}

enum Screens {
  home,
  login,
  register,
}