import 'package:flutter_test/flutter_test.dart';
import 'package:sentra/features/inspections/domain/inspection.dart';

void main() {
  group('Inspection Domain Tests', () {
    test('Inspection creation and copyWith', () {
      final insp = Inspection(
        id: 'i1',
        workOrderId: 'w1',
        inspectorName: 'Inspector',
        createdAt: DateTime.now(),
        status: InspectionStatus.draft,
        items: [],
      );

      expect(insp.id, 'i1');
      expect(insp.status, InspectionStatus.draft);

      final updated = insp.copyWith(status: InspectionStatus.completed);
      expect(updated.status, InspectionStatus.completed);
    });

    test('InspectionItem update', () {
      final item = InspectionItem(id: 'it1', question: 'Q1', isPass: true);
      expect(item.isPass, isTrue);
      item.isPass = false;
      expect(item.isPass, isFalse);
    });
  });
}
