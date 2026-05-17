import 'package:fpdart/fpdart.dart';
import '../../../core/error/failures.dart';
import 'user_profile.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, Unit>> signInWithEmailAndPassword(
    String email,
    String password,
  );
  Future<Either<Failure, Unit>> signUp({
    required String email,
    required String password,
    required String fullName,
    String? organizationName,
  });
  Future<Either<Failure, Unit>> signOut();
  Stream<bool> get authStateChanges;
  bool get isAuthenticated;
  UserProfile? get currentUserProfile;
}
