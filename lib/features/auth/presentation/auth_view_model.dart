import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/di/injection.dart';
import '../../../core/env/env.dart';
import '../application/auth_coordinator.dart';
import '../domain/user_profile.dart';

part 'auth_view_model.g.dart';

@riverpod
Stream<bool> authState(Ref ref) {
  final coordinator = getIt<AuthCoordinator>();
  return coordinator.authStateChanges;
}

@riverpod
bool isAuthenticated(Ref ref) {
  if (Env.bypassAuth) return true;
  final coordinator = getIt<AuthCoordinator>();
  return coordinator.isAuthenticated;
}

@riverpod
UserProfile? currentUserProfile(Ref ref) {
  final coordinator = getIt<AuthCoordinator>();
  return coordinator.getCurrentProfile();
}

@riverpod
class AuthViewModel extends _$AuthViewModel {
  late final AuthCoordinator _coordinator;

  @override
  FutureOr<void> build() {
    _coordinator = getIt<AuthCoordinator>();
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    final result = await _coordinator.signIn(email, password);
    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (_) => state = const AsyncValue.data(null),
    );
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    final result = await _coordinator.signOut();
    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (_) => state = const AsyncValue.data(null),
    );
  }
}
