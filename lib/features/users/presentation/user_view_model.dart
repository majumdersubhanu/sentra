import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../auth/domain/user_profile.dart';
import '../domain/user_repository.dart';
import '../../../core/di/injection.dart';

part 'user_view_model.g.dart';

@riverpod
Future<List<UserProfile>> technicians(Ref ref) async {
  final repo = getIt<UserRepository>();
  final result = await repo.getTechnicians();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (users) => users,
  );
}

@riverpod
class UsersViewModel extends _$UsersViewModel {
  @override
  FutureOr<List<UserProfile>> build() async {
    final repo = getIt<UserRepository>();
    final result = await repo.getAllUsers();
    return result.fold(
      (failure) => throw Exception(failure.message),
      (users) => users,
    );
  }

  Future<void> updateRole(String userId, UserRole newRole) async {
    final repo = getIt<UserRepository>();
    final result = await repo.updateUserRole(userId, newRole);
    result.fold(
      (failure) => throw Exception(failure.message),
      (_) {
        ref.invalidateSelf();
      },
    );
  }
}
