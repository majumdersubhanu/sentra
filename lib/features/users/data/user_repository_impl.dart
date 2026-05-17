import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/failures.dart';
import '../../../core/network/connectivity_service.dart';
import '../../../core/storage/database.dart';
import '../../auth/domain/user_profile.dart';
import '../domain/user_repository.dart';

@LazySingleton(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  final SupabaseClient _supabase;
  final SentraDatabase _db;
  final ConnectivityService _connectivity;

  UserRepositoryImpl(this._supabase, this._db, this._connectivity);

  @override
  Future<Either<Failure, List<UserProfile>>> getTechnicians() async {
    try {
      if (_connectivity.isOnline) {
        final response = await _supabase
            .from('users')
            .select()
            .eq('role', 'technician');

        final users = (response as List).map((u) => _mapToProfile(u)).toList();

        // Cache in Drift
        await _db.userDao.upsertUsers(
          users.map((u) => _mapToCompanion(u)).toList(),
        );

        return Right(users);
      } else {
        // Offline: fetch from Drift
        final cached = await _db.userDao.watchUsersByRole('technician').first;
        return Right(cached.map((c) => _mapFromEntry(c)).toList());
      }
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserProfile>>> getAllUsers() async {
    try {
      if (_connectivity.isOnline) {
        final response = await _supabase
            .from('users')
            .select()
            .order('full_name', ascending: true);

        final users = (response as List).map((u) => _mapToProfile(u)).toList();

        // Cache in Drift
        await _db.userDao.upsertUsers(
          users.map((u) => _mapToCompanion(u)).toList(),
        );

        return Right(users);
      } else {
        // Offline: fetch all users from local cache
        final cached = await _db.select(_db.userEntries).get();
        return Right(cached.map((c) => _mapFromEntry(c)).toList());
      }
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateUserRole(String id, UserRole role) async {
    try {
      if (_connectivity.isOnline) {
        await _supabase.from('users').update({'role': role.name}).eq('id', id);
        
        final cached = await _db.userDao.getUserById(id);
        if (cached != null) {
          await _db.userDao.upsertUsers([
            UserEntriesCompanion(id: Value(id), role: Value(role.name))
          ]);
        }
        return const Right(unit);
      } else {
        return const Left(DatabaseFailure('Must be online to update roles.'));
      }
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> getUserById(String id) async {
    try {
      if (_connectivity.isOnline) {
        final response = await _supabase
            .from('users')
            .select()
            .eq('id', id)
            .single();
        return Right(_mapToProfile(response));
      } else {
        final cached = await _db.userDao.getUserById(id);
        if (cached != null) return Right(_mapFromEntry(cached));
        return const Left(DatabaseFailure('User not found in cache.'));
      }
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  UserProfile _mapToProfile(Map<String, dynamic> data) {
    return UserProfile(
      id: data['id'],
      email: data['email'],
      fullName: data['full_name'] ?? '',
      role: UserRole.fromString(data['role']),
      organizationId: data['organization_id'],
    );
  }

  UserEntriesCompanion _mapToCompanion(UserProfile profile) {
    return UserEntriesCompanion(
      id: Value(profile.id),
      email: Value(profile.email),
      fullName: Value(profile.fullName),
      role: Value(profile.role.name),
      organizationId: Value(profile.organizationId),
    );
  }

  UserProfile _mapFromEntry(UserEntry entry) {
    return UserProfile(
      id: entry.id,
      email: entry.email,
      fullName: entry.fullName,
      role: UserRole.fromString(entry.role),
      organizationId: entry.organizationId,
    );
  }
}
