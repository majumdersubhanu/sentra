import 'package:fpdart/fpdart.dart';
import '../../../core/error/failures.dart';
import '../../auth/domain/user_profile.dart';

abstract interface class UserRepository {
  Future<Either<Failure, List<UserProfile>>> getTechnicians();
  Future<Either<Failure, List<UserProfile>>> getAllUsers();
  Future<Either<Failure, UserProfile>> getUserById(String id);
  Future<Either<Failure, Unit>> updateUserRole(String id, UserRole role);
}
