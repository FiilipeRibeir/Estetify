import 'package:go_router/go_router.dart';
import 'package:estetify/index.dart';

class AppRouter {
  static GoRouter init() {
    return GoRouter(
      redirect: (context, state) {
        return null;
      },
      routes: [
        SplashRouter.routes(),
      ],
    );
  }
}
