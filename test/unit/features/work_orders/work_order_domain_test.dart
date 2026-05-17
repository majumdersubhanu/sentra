import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sentra/features/work_orders/domain/work_order.dart';
import 'package:sentra/features/work_orders/domain/work_order_repository.dart';
import 'package:sentra/core/error/failures.dart';

class MockWorkOrderRepository extends Mock implements WorkOrderRepository {}

void main() {
  late MockWorkOrderRepository mockRepository;

  setUp(() {
    mockRepository = MockWorkOrderRepository();
  });

  group('WorkOrder Domain Tests', () {
    test('WorkOrder model copyWith works correctly', () {
      final wo = WorkOrder(
        id: '1',
        title: 'Original',
        description: 'Desc',
        status: WorkOrderStatus.open,
        priority: WorkOrderPriority.medium,
        createdAt: DateTime(2026, 5, 17),
      );

      final updated = wo.copyWith(title: 'Updated');
      expect(updated.title, 'Updated');
      expect(updated.id, '1');
      expect(updated.createdAt, DateTime(2026, 5, 17));
    });

    test('WorkOrderStatus enums are correctly defined', () {
      expect(WorkOrderStatus.values.length, 7);
      expect(WorkOrderStatus.inProgress.name, 'inProgress');
    });

    test('WorkOrderMaterial creation works', () {
      const material = WorkOrderMaterial(
        id: 'M1',
        workOrderId: 'WO1',
        partNumber: 'PN-100',
        description: 'Part A',
      );
      expect(material.id, 'M1');
      expect(material.quantity, 1.0);
    });
    group('Enum Parsing', () {
      test('WorkOrderStatus enum names', () {
        expect(WorkOrderStatus.open.name, 'open');
        expect(WorkOrderStatus.completed.name, 'completed');
      });
    });
  });
}
