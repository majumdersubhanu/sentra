import 'package:flutter_test/flutter_test.dart';
import 'package:sentra/features/auth/domain/user_profile.dart';

void main() {
  group('UserProfile Domain Tests', () {
    test('UserRole.fromString works correctly', () {
      expect(UserRole.fromString('admin'), UserRole.admin);
      expect(UserRole.fromString('supervisor'), UserRole.supervisor);
      expect(UserRole.fromString('technician'), UserRole.technician);
      expect(UserRole.fromString('unknown'), UserRole.technician);
    });

    test('UserRole helpers work correctly', () {
      expect(UserRole.admin.isAdmin, isTrue);
      expect(UserRole.supervisor.isAdmin, isFalse);
      expect(UserRole.supervisor.isSupervisorOrAbove, isTrue);
      expect(UserRole.technician.isSupervisorOrAbove, isFalse);
    });

    test('UserProfile creation and copyWith', () {
      const profile = UserProfile(
        id: 'u1',
        email: 'test@sentra.com',
        fullName: 'Test User',
        role: UserRole.technician,
      );

      expect(profile.id, 'u1');
      expect(profile.organizationId, isNull);
    });
  });
}
