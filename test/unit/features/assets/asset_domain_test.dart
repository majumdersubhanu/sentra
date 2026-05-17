import 'package:flutter_test/flutter_test.dart';
import 'package:sentra/features/assets/domain/asset.dart';

void main() {
  group('Asset Domain Tests', () {
    test('Asset creation and copyWith', () {
      final asset = Asset(
        id: 'a1',
        name: 'Asset 1',
        status: AssetOperationalStatus.online,
        lastServicedDate: DateTime.now(),
        createdAt: DateTime.now(),
      );

      expect(asset.id, 'a1');
      expect(asset.status, AssetOperationalStatus.online);

      final updated = asset.copyWith(status: AssetOperationalStatus.offline);
      expect(updated.status, AssetOperationalStatus.offline);
    });
  });
}
