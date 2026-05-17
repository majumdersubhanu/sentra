sealed class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network connection failed.']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Invalid input data.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local cache access failed.']);
}

class SyncConflictFailure extends Failure {
  const SyncConflictFailure([
    super.message = 'Data synchronization conflict detected.',
  ]);
}

class UploadFailure extends Failure {
  const UploadFailure([super.message = 'Media or data upload failed.']);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure([super.message = 'Database operation failed.']);
}
