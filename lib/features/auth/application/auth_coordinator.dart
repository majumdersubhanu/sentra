import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../core/error/failures.dart';
import '../domain/auth_repository.dart';
import '../domain/user_profile.dart';

@lazySingleton
class AuthCoordinator {
  final AuthRepository _authRepository;

  AuthCoordinator(this._authRepository);

  bool get isAuthenticated => _authRepository.isAuthenticated;

  Stream<bool> get authStateChanges => _authRepository.authStateChanges;

  Future<Either<Failure, Unit>> signIn(String email, String password) {
    return _authRepository.signInWithEmailAndPassword(email, password);
  }

  Future<Either<Failure, Unit>> signOut() {
    return _authRepository.signOut();
  }

  UserProfile? getCurrentProfile() {
    return _authRepository.currentUserProfile;
  }
}
