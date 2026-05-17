enum UserRole {
  technician,
  supervisor,
  admin;

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'supervisor':
        return UserRole.supervisor;
      case 'admin':
        return UserRole.admin;
      case 'technician':
      default:
        return UserRole.technician;
    }
  }

  bool get isSupervisorOrAbove =>
      this == UserRole.supervisor || this == UserRole.admin;
  bool get isAdmin => this == UserRole.admin;
  bool get isTechnician => this == UserRole.technician;
}

class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final String? organizationId;

  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.organizationId,
  });
}
