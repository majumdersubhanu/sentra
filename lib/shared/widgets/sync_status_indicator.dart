import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sentra_ui/sentra_ui.dart';

import 'package:sentra/core/sync/sync_providers.dart';

/// Compact sync status indicator for app bars.
/// Shows pending count and connectivity state with a pulsing animation.
class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);
    final pendingAsync = ref.watch(pendingSyncCountProvider);

    final pendingCount = pendingAsync.asData?.value ?? 0;

    if (isOnline && pendingCount == 0) {
      return const SizedBox.shrink(); // Nothing to show when fully synced
    }

    final color = isOnline ? SentraColors.info : SentraColors.error;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0.w, vertical: 4.0.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOnline ? LucideIcons.refreshCw : LucideIcons.wifiOff,
            color: color,
            size: 12.0.sp,
          ),
          SizedBox(width: 4.0.w),
          Text(
            isOnline ? '$pendingCount pending' : 'Offline',
            style: SentraTypography.label.copyWith(
              color: color,
              fontSize: 10.0.sp,
            ),
          ),
        ],
      ),
    );
  }
}
