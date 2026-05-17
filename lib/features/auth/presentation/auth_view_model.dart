import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fpdart/fpdart.dart';
import '../../../core/di/injection.dart';
import '../../../core/env/env.dart';
import '../../../core/error/failures.dart';
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

  Future<Either<Failure, Unit>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    state = const AsyncValue.loading();
    final result = await _coordinator.signIn(email, password);
    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (_) => const AsyncValue.data(null),
    );
    return result;
  }

  Future<Either<Failure, Unit>> signUp({
    required String email,
    required String password,
    required String fullName,
    String? organizationName,
  }) async {
    state = const AsyncValue.loading();
    final result = await _coordinator.signUp(
      email: email,
      password: password,
      fullName: fullName,
      organizationName: organizationName,
    );
    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (_) => const AsyncValue.data(null),
    );
    return result;
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    final result = await _coordinator.signOut();
    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (_) => const AsyncValue.data(null),
    );
  }
}
