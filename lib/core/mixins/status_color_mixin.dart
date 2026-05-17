import 'package:flutter/material.dart';
import '../../features/work_orders/domain/work_order.dart';
import '../../features/inspections/domain/inspection.dart';
import '../../features/assets/domain/asset.dart';
import '../../features/uploads/domain/upload_repository.dart';

/// Mixin providing centralized color + icon resolution for all domain status enums.
mixin StatusColorMixin {
  /// Returns the semantic color for any domain status enum.
  Color getStatusColor(Enum status) {
    if (status is WorkOrderStatus) {
      return switch (status) {
        WorkOrderStatus.open => const Color(0xFFF59E0B),
        WorkOrderStatus.assigned => const Color(0xFF8B5CF6),
        WorkOrderStatus.inProgress => const Color(0xFF3B82F6),
        WorkOrderStatus.onHold => const Color(0xFF6B7280),
        WorkOrderStatus.completed => const Color(0xFF22C55E),
        WorkOrderStatus.verified => const Color(0xFF10B981),
        WorkOrderStatus.cancelled => const Color(0xFFEF4444),
      };
    }

    if (status is WorkOrderPriority) {
      return switch (status) {
        WorkOrderPriority.low => const Color(0xFF6B7280),
        WorkOrderPriority.medium => const Color(0xFF3B82F6),
        WorkOrderPriority.high => const Color(0xFFF59E0B),
        WorkOrderPriority.critical => const Color(0xFFEF4444),
      };
    }

    if (status is InspectionStatus) {
      return switch (status) {
        InspectionStatus.draft => const Color(0xFF6B7280),
        InspectionStatus.completed => const Color(0xFF22C55E),
        InspectionStatus.inProgress => const Color(0xFF3B82F6),
      };
    }

    if (status is AssetOperationalStatus) {
      return switch (status) {
        AssetOperationalStatus.online => const Color(0xFF22C55E),
        AssetOperationalStatus.maintenance => const Color(0xFFF59E0B),
        AssetOperationalStatus.offline => const Color(0xFFEF4444),
        AssetOperationalStatus.decommissioned => const Color(0xFF6B7280),
      };
    }

    if (status is UploadState) {
      return switch (status) {
        UploadState.pending => const Color(0xFFF59E0B),
        UploadState.inProgress => const Color(0xFF3B82F6),
        UploadState.failed => const Color(0xFFEF4444),
        UploadState.success => const Color(0xFF22C55E),
      };
    }

    return const Color(0xFF6B7280);
  }

  /// Returns the semantic icon for any domain status enum.
  IconData getStatusIcon(Enum status) {
    if (status is WorkOrderStatus) {
      return switch (status) {
        WorkOrderStatus.open => Icons.fiber_new_outlined,
        WorkOrderStatus.assigned => Icons.person_outline,
        WorkOrderStatus.inProgress => Icons.play_circle_outline,
        WorkOrderStatus.onHold => Icons.pause_circle_outline,
        WorkOrderStatus.completed => Icons.check_circle_outline,
        WorkOrderStatus.verified => Icons.verified_outlined,
        WorkOrderStatus.cancelled => Icons.cancel_outlined,
      };
    }

    if (status is AssetOperationalStatus) {
      return switch (status) {
        AssetOperationalStatus.online => Icons.check_circle_outline,
        AssetOperationalStatus.maintenance => Icons.build_outlined,
        AssetOperationalStatus.offline => Icons.power_off_outlined,
        AssetOperationalStatus.decommissioned => Icons.delete_outline,
      };
    }

    return Icons.circle_outlined;
  }
}
