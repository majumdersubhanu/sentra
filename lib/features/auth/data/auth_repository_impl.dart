import 'dart:async';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/env/env.dart';
import '../../../core/error/failures.dart';
import '../domain/auth_repository.dart';
import '../domain/user_profile.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final _authStateController = StreamController<bool>.broadcast();
  UserProfile? _cachedProfile;

  AuthRepositoryImpl() {
    if (Env.bypassAuth) {
      Future.delayed(Duration.zero, () {
        _authStateController.add(true);
      });
    } else {
      _supabaseClient?.auth.onAuthStateChange.listen((event) async {
        final session = event.session;
        if (session != null) {
          await _refreshProfile(session.user.id, session.user.email ?? '');
        } else {
          _cachedProfile = null;
        }
        _authStateController.add(session != null);
      });
    }
  }

  Future<void> _refreshProfile(String userId, String email) async {
    try {
      final data = await _supabaseClient!
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      _cachedProfile = UserProfile(
        id: data['id'] as String,
        email: data['email'] as String,
        fullName: data['full_name'] as String? ?? 'Unknown User',
        role: UserRole.fromString(data['role'] as String),
        organizationId: data['organization_id'] as String?,
      );
    } catch (e) {
      _cachedProfile = UserProfile(
        id: userId,
        email: email,
        fullName: 'Unknown User',
        role: UserRole.technician,
      );
    }
  }

  SupabaseClient? get _supabaseClient {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  @override
  bool get isAuthenticated {
    if (Env.bypassAuth) return true;
    return _supabaseClient?.auth.currentSession != null;
  }

  @override
  Stream<bool> get authStateChanges => _authStateController.stream;

  @override
  UserProfile? get currentUserProfile {
    if (Env.bypassAuth) {
      return const UserProfile(
        id: 'mock-admin-id',
        email: 'admin@sentra.com',
        fullName: 'Subhanu (Admin)',
        role: UserRole.admin,
        organizationId: 'org-123',
      );
    }
    return _cachedProfile;
  }

  @override
  Future<Either<Failure, Unit>> signUp({
    required String email,
    required String password,
    required String fullName,
    String? organizationName,
  }) async {
    if (Env.bypassAuth) {
      _authStateController.add(true);
      return const Right(unit);
    }

    try {
      final client = _supabaseClient;
      if (client == null)
        return const Left(AuthFailure('Supabase client not initialized.'));

      final response = await client.auth.signUp(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) return const Left(AuthFailure('Signup failed.'));

      String? orgId;
      UserRole role = UserRole.technician;

      if (organizationName != null && organizationName.isNotEmpty) {
        // Create organization
        final orgResponse = await client
            .from('organizations')
            .insert({'name': organizationName})
            .select()
            .single();
        orgId = orgResponse['id'] as String;
        role = UserRole.admin;
      }

      // Create user profile in public.users
      await client.from('users').insert({
        'id': user.id,
        'email': email,
        'full_name': fullName,
        'role': role.name,
        'organization_id': orgId,
      });

      await _refreshProfile(user.id, email);
      return const Right(unit);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Signup failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    if (Env.bypassAuth) {
      _authStateController.add(true);
      return const Right(unit);
    }

    try {
      final client = _supabaseClient;
      if (client == null)
        return const Left(AuthFailure('Supabase client not initialized.'));

      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        await _refreshProfile(response.user!.id, response.user!.email ?? '');
      }
      return const Right(unit);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Authentication failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    if (Env.bypassAuth) {
      _authStateController.add(false);
      return const Right(unit);
    }

    try {
      final client = _supabaseClient;
      if (client == null)
        return const Left(AuthFailure('Supabase client not initialized.'));

      await client.auth.signOut();
      _cachedProfile = null;
      return const Right(unit);
    } catch (e) {
      return Left(AuthFailure('Sign out failed: ${e.toString()}'));
    }
  }
}
