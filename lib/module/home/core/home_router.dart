import 'package:estetify/index.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeRouter {
  static const root = '/home';

  static GoRoute routes() {
    return GoRoute(
      path: root,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          child: const HomePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
      },
    );
  }
}
