import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/produtos/presentation/pages/feed_page.dart';

class AppRouter {
  static const login = '/login';
  static const cadastro = '/cadastro';
  static const feed = '/feed';

  static final GoRouter router = GoRouter(
    initialLocation: login,
    routes: [
      GoRoute(
        path: login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: cadastro,
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: feed,
        builder: (context, state) => const FeedPage(),
      ),
    ],
  );
}