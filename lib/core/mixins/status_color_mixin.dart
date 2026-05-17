import 'package:flutter/material.dart';
import '../../features/work_orders/domain/work_order.dart';
import '../../features/inspections/domain/inspection.dart';
import '../../features/assets/domain/asset.dart';
import '../../features/uploads/domain/upload_repository.dart';

/// Mixin providing centralized color + icon resolution for all domain status enums.
/// Eliminates 4+ separate _getStatusColor / _getStatusIcon switch blocks.
mixin StatusColorMixin {
  /// Returns the semantic color for any domain status enum.
  Color getStatusColor(Enum status) {
    return switch (status) {
      // Work Order Statuses (full lifecycle)
      WorkOrderStatus.open => const Color(0xFFF59E0B),
      WorkOrderStatus.assigned => const Color(0xFF8B5CF6),
      WorkOrderStatus.inProgress => const Color(0xFF3B82F6),
      WorkOrderStatus.onHold => const Color(0xFF6B7280),
      WorkOrderStatus.completed => const Color(0xFF22C55E),
      WorkOrderStatus.verified => const Color(0xFF10B981),

      // Work Order Priorities
      WorkOrderPriority.low => const Color(0xFF6B7280),
      WorkOrderPriority.medium => const Color(0xFF3B82F6),
      WorkOrderPriority.high => const Color(0xFFF59E0B),
      WorkOrderPriority.urgent => const Color(0xFFEF4444),

      // Inspection Statuses
      InspectionStatus.draft => const Color(0xFF6B7280),
      InspectionStatus.submitted => const Color(0xFF3B82F6),
      InspectionStatus.approved => const Color(0xFF22C55E),
      InspectionStatus.flagged => const Color(0xFFEF4444),

      // Asset Statuses
      AssetOperationalStatus.online => const Color(0xFF22C55E),
      AssetOperationalStatus.maintenance => const Color(0xFFF59E0B),
      AssetOperationalStatus.offline => const Color(0xFFEF4444),
      AssetOperationalStatus.decommissioned => const Color(0xFF6B7280),

      // Upload States
      UploadState.pending => const Color(0xFFF59E0B),
      UploadState.inProgress => const Color(0xFF3B82F6),
      UploadState.failed => const Color(0xFFEF4444),
      UploadState.success => const Color(0xFF22C55E),

      _ => const Color(0xFF6B7280),
    };
  }

  /// Returns the semantic icon for any domain status enum.
  IconData getStatusIcon(Enum status) {
    return switch (status) {
      // Work Order Statuses (full lifecycle)
      WorkOrderStatus.open => Icons.fiber_new_outlined,
      WorkOrderStatus.assigned => Icons.person_outline,
      WorkOrderStatus.inProgress => Icons.play_circle_outline,
      WorkOrderStatus.onHold => Icons.pause_circle_outline,
      WorkOrderStatus.completed => Icons.check_circle_outline,
      WorkOrderStatus.verified => Icons.verified_outlined,

      WorkOrderPriority.low => Icons.arrow_downward,
      WorkOrderPriority.medium => Icons.remove,
      WorkOrderPriority.high => Icons.arrow_upward,
      WorkOrderPriority.urgent => Icons.priority_high,

      InspectionStatus.draft => Icons.edit_outlined,
      InspectionStatus.submitted => Icons.send_outlined,
      InspectionStatus.approved => Icons.verified_outlined,
      InspectionStatus.flagged => Icons.block_outlined,

      AssetOperationalStatus.online => Icons.check_circle_outline,
      AssetOperationalStatus.maintenance => Icons.build_outlined,
      AssetOperationalStatus.offline => Icons.power_off_outlined,
      AssetOperationalStatus.decommissioned => Icons.delete_outline,

      UploadState.pending => Icons.schedule,
      UploadState.inProgress => Icons.sync,
      UploadState.failed => Icons.error_outline,
      UploadState.success => Icons.cloud_done_outlined,

      _ => Icons.circle_outlined,
    };
  }

  /// Returns a health color based on a 0.0-1.0 ratio.
  Color healthColor(double ratio) {
    if (ratio >= 0.75) return const Color(0xFF22C55E);
    if (ratio >= 0.45) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}
