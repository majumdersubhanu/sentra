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
      // In bypass mode, immediately emit authenticated state
      Future.delayed(Duration.zero, () {
        _authStateController.add(true);
      });
    } else {
      // Listen to real Supabase auth state changes
      _supabaseClient?.auth.onAuthStateChange.listen((event) async {
        final session = event.session;
        if (session != null) {
          try {
            final data = await _supabaseClient!
                .from('users')
                .select()
                .eq('id', session.user.id)
                .single();
            _cachedProfile = UserProfile(
              id: data['id'] as String,
              email: data['email'] as String,
              fullName: data['full_name'] as String,
              role: UserRole.fromString(data['role'] as String),
              organizationId: data['organization_id'] as String?,
            );
          } catch (e) {
            _cachedProfile = UserProfile(
              id: session.user.id,
              email: session.user.email ?? '',
              fullName: 'Unknown User',
              role: UserRole.technician,
            );
          }
        } else {
          _cachedProfile = null;
        }
        _authStateController.add(session != null);
      });
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
        id: 'mock-supervisor-id',
        email: 'supervisor@sentra.com',
        fullName: 'Subhanu (Supervisor)',
        role: UserRole.supervisor,
        organizationId: 'org-123',
      );
    }

    if (_cachedProfile != null) return _cachedProfile;

    // Return cached profile if available, otherwise null.
    // The profile is fetched asynchronously on login/init.
    return _cachedProfile;
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
      if (client == null) {
        return const Left(AuthFailure('Supabase client not initialized.'));
      }

      await client.auth.signInWithPassword(email: email, password: password);
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
      if (client == null) {
        return const Left(AuthFailure('Supabase client not initialized.'));
      }

      await client.auth.signOut();
      _cachedProfile = null;
      return const Right(unit);
    } catch (e) {
      return Left(AuthFailure('Sign out failed: ${e.toString()}'));
    }
  }
}
