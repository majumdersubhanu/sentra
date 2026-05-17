import '../../../core/error/failures.dart';

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure([
    super.message = 'Invalid email or password.',
  ]);
}

class SessionExpiredFailure extends AuthFailure {
  const SessionExpiredFailure([super.message = 'User session has expired.']);
}
