import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mix/mix.dart';

import '../../../core/storage/database.dart';
import '../../../core/storage/database_providers.dart';
import '../../../core/theme/sentra_styles.dart';
import '../../../core/theme/sentra_tokens.dart';
import 'package:sentra/routes/app_router.dart';

@RoutePage()
class ConflictListScreen extends ConsumerWidget {
  const ConflictListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conflictsAsync = ref.watch(unresolvedConflictsProvider);

    return Scaffold(
      backgroundColor: kSurface,
      appBar: AppBar(
        title: Text(
          'Data Conflicts',
          style: TextStyle(fontSize: 18.0.sp, fontWeight: FontWeight.w700),
        ),
        backgroundColor: kSurface,
        elevation: 0,
      ),
      body: conflictsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (conflictsList) {
          final conflicts = conflictsList.cast<ConflictEntry>();
          if (conflicts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: kSuccess,
                    size: 48.0.sp,
                  ),
                  SizedBox(height: 16.0.h),
                  Text(
                    'No pending conflicts',
                    style: TextStyle(
                      color: kTextPrimary,
                      fontSize: 16.0.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.0.h),
                  Text(
                    'All local data is in sync with the server.',
                    style: TextStyle(color: kTextMuted, fontSize: 14.0.sp),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.0.w),
            itemCount: conflicts.length,
            itemBuilder: (context, index) {
              final conflict = conflicts[index];
              return _ConflictCard(conflict: conflict);
            },
          );
        },
      ),
    );
  }
}

class _ConflictCard extends StatelessWidget {
  final ConflictEntry conflict;
  const _ConflictCard({required this.conflict});

  @override
  Widget build(BuildContext context) {
    return PressableBox(
      onPress: () =>
          context.router.push(ConflictResolutionRoute(conflict: conflict)),
      style: $sectionCard().marginOnly(bottom: 12.0.h).paddingAll(16.0.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.0.w),
            decoration: BoxDecoration(
              color: kDanger.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.0.r),
            ),
            child: Icon(Icons.sync_problem, color: kDanger, size: 20.0.sp),
          ),
          SizedBox(width: 16.0.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${conflict.entityType.toUpperCase()}: ${conflict.id}',
                  style: TextStyle(
                    color: kTextPrimary,
                    fontSize: 14.0.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.0.h),
                Text(
                  'Conflicting change by ${conflict.conflictingUserName ?? "Unknown User"}',
                  style: TextStyle(color: kTextSecondary, fontSize: 12.0.sp),
                ),
                SizedBox(height: 4.0.h),
                Text(
                  'Detected ${Jiffy.parseFromDateTime(conflict.createdAt).fromNow()}',
                  style: TextStyle(color: kTextMuted, fontSize: 11.0.sp),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: kTextMuted, size: 20.0.sp),
        ],
      ),
    );
  }
}
