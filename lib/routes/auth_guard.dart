import 'package:auto_route/auto_route.dart';
import '../core/di/injection.dart';
import '../features/auth/application/auth_coordinator.dart';
import 'app_router.dart';

class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final authCoordinator = getIt<AuthCoordinator>();

    if (authCoordinator.isAuthenticated) {
      resolver.next(true);
    } else {
      router.push(const AuthRoute());
      resolver.next(false);
    }
  }
}
