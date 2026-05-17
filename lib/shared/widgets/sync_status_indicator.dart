import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:sentra/core/sync/sync_providers.dart';
import 'package:sentra/core/theme/sentra_tokens.dart';

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

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0.w, vertical: 5.0.h),
      decoration: BoxDecoration(
        color: isOnline
            ? const Color(0xFF3B82F6).withValues(alpha: 0.15)
            : kDanger.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20.0.r),
        border: Border.all(
          color: isOnline
              ? const Color(0xFF3B82F6).withValues(alpha: 0.3)
              : kDanger.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOnline ? LucideIcons.refreshCw : LucideIcons.wifiOff,
            color: isOnline ? const Color(0xFF3B82F6) : kDanger,
            size: 14.0.sp,
          ),
          SizedBox(width: 4.0.w),
          Text(
            isOnline ? '$pendingCount pending' : 'Offline',
            style: TextStyle(
              color: isOnline ? const Color(0xFF3B82F6) : kDanger,
              fontSize: 11.0.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
