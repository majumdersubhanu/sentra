import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mix/mix.dart';
import '../../../core/mixins/date_format_mixin.dart';
import '../../../core/mixins/filterable_list_mixin.dart';
import '../../../core/mixins/status_color_mixin.dart';
import '../../../core/theme/sentra_styles.dart';
import '../../../core/theme/sentra_tokens.dart';
import '../../../shared/widgets/sync_status_indicator.dart';
import '../domain/upload_repository.dart';
import 'uploads_view_model.dart';

@RoutePage()
class UploadsScreen extends ConsumerStatefulWidget {
  const UploadsScreen({super.key});
  @override
  ConsumerState<UploadsScreen> createState() => _UploadsScreenState();
}

class _UploadsScreenState extends ConsumerState<UploadsScreen>
    with
        FilterableListMixin<UploadTask, UploadState>,
        StatusColorMixin,
        DateFormatMixin {
  @override
  void setFilterState(VoidCallback fn) => setState(fn);
  @override
  bool searchMatch(UploadTask item, String query) =>
      item.localPayloadPath.toLowerCase().contains(query) ||
      item.id.toLowerCase().contains(query);
  @override
  Enum? getItemStatus(UploadTask item) => item.state;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(uploadsViewModelProvider);
    return Scaffold(
      backgroundColor: kSurface,
      appBar: AppBar(
        title: Text(
          'Sync Queue',
          style: TextStyle(fontSize: 18.0.sp, fontWeight: FontWeight.w700),
        ),
        backgroundColor: kSurface,
        actions: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Center(child: SyncStatusIndicator()),
          ),
          IconButton(
            tooltip: 'Refresh sync queue',
            icon: const Icon(LucideIcons.refreshCw),
            onPressed: () =>
                ref.read(uploadsViewModelProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          state.whenOrNull(
                data: (tasks) {
                  final pending = tasks
                      .where((t) => t.state == UploadState.pending)
                      .length;
                  final active = tasks
                      .where((t) => t.state == UploadState.inProgress)
                      .length;
                  final failed = tasks
                      .where((t) => t.state == UploadState.failed)
                      .length;
                  final done = tasks
                      .where((t) => t.state == UploadState.success)
                      .length;
                  return Padding(
                    padding: EdgeInsets.fromLTRB(16.0.w, 8.0.h, 16.0.w, 8.0.h),
                    child: Box(
                      style: $statsBar(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _statItem('Pending', pending, kWarning),
                          _statItem('Active', active, kAccent),
                          _statItem('Failed', failed, kDanger),
                          _statItem('Done', done, kSuccess),
                        ],
                      ),
                    ),
                  );
                },
              ) ??
              const SizedBox.shrink(),

          Padding(
            padding: EdgeInsets.fromLTRB(16.0.w, 0, 16.0.w, 4.0.h),
            child: TextField(
              onChanged: updateSearch,
              style: TextStyle(color: kTextPrimary, fontSize: 14.0.sp),
              decoration: sentraSearchDecoration(hint: 'Search tasks...'),
            ),
          ),
          SizedBox(
            height: 44.0.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.0.w),
              children: [
                _buildChip(null, 'All'),
                ...UploadState.values.map(
                  (s) => _buildChip(s, s.name.toUpperCase()),
                ),
              ],
            ),
          ),
          SizedBox(height: 4.0.h),
          Expanded(
            child: state.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: kDanger, size: 48.0.sp),
                    SizedBox(height: 16.0.h),
                    Text(
                      'Failed: $err',
                      style: const TextStyle(color: kTextPrimary),
                    ),
                  ],
                ),
              ),
              data: (tasks) {
                final filtered = applyFilters(tasks);
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.cloudUpload,
                          color: kTextMuted,
                          size: 48.0.sp,
                        ),
                        SizedBox(height: 12.0.h),
                        StyledText(
                          searchQuery.isNotEmpty || statusFilter != null
                              ? 'No matching tasks'
                              : 'Sync queue is empty',
                          style: $emptyStateText(),
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  color: kPurple500,
                  backgroundColor: kSurfaceElevated,
                  onRefresh: () async =>
                      ref.read(uploadsViewModelProvider.notifier).refresh(),
                  child: ListView.builder(
                    padding: EdgeInsets.all(16.0.w),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => _buildCard(filtered[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, int count, Color color) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        count.toString(),
        style: TextStyle(
          color: color,
          fontSize: 18.0.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
      SizedBox(height: 2.0.h),
      Text(
        label,
        style: TextStyle(color: kTextMuted, fontSize: 10.0.sp),
      ),
    ],
  );

  Widget _buildChip(UploadState? status, String label) {
    final isActive = statusFilter == status;
    final color = status != null ? getStatusColor(status) : kPurple500;
    return Padding(
      padding: EdgeInsets.only(right: 8.0.w),
      child: GestureDetector(
        onTap: () => updateFilter(status),
        child: Box(
          style: isActive ? $filterChipActive(color) : $filterChip(),
          child: Center(
            child: StyledText(
              label,
              style: TextStyler()
                  .color(isActive ? color : kTextMuted)
                  .fontSize(11)
                  .fontWeight(.w600),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(UploadTask task) {
    final stateColor = getStatusColor(task.state);
    final isRetryable = task.state == UploadState.failed;
    final fileName = task.localPayloadPath.split('/').last;

    return Padding(
      padding: EdgeInsets.only(bottom: 14.0.h),
      child: Box(
        style: $card().padding(.all(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StyledText(
                  task.id,
                  style: TextStyler()
                      .color(kPurple500.withValues(alpha: 0.8))
                      .fontWeight(.w600)
                      .fontSize(12.0.sp.toDouble()),
                ),
                Box(
                  style: $badge(stateColor),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      task.state == UploadState.inProgress
                          ? SizedBox(
                              width: 12.0.sp,
                              height: 12.0.sp,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: stateColor,
                              ),
                            )
                          : Icon(
                              getStatusIcon(task.state),
                              color: stateColor,
                              size: 12.0.sp,
                            ),
                      SizedBox(width: 4.0.w),
                      StyledText(
                        task.state.name.toUpperCase(),
                        style: $badgeText(stateColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.0.h),
            Text(
              fileName,
              style: TextStyle(
                color: kTextPrimary,
                fontSize: 14.0.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 4.0.h),
            Text(
              'Type: ${task.type.name}',
              style: TextStyle(color: kTextMuted, fontSize: 12.0.sp),
            ),
            if (task.state == UploadState.inProgress) ...[
              SizedBox(height: 10.0.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(4.0.r),
                child: LinearProgressIndicator(
                  value: task.progress,
                  minHeight: 4.0.h,
                  backgroundColor: kSurfaceMuted,
                  color: stateColor,
                ),
              ),
              SizedBox(height: 4.0.h),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${(task.progress * 100).toInt()}%',
                  style: TextStyle(
                    color: stateColor,
                    fontSize: 10.0.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
            if (task.errorMessage != null && task.errorMessage!.isNotEmpty) ...[
              SizedBox(height: 8.0.h),
              Text(
                task.errorMessage!,
                style: TextStyle(color: kDanger, fontSize: 11.0.sp),
              ),
            ],
            SizedBox(height: 8.0.h),
            Row(
              children: [
                Icon(LucideIcons.clock3, color: kTextMuted, size: 13.0.sp),
                SizedBox(width: 4.0.w),
                Expanded(
                  child: Text(
                    formatRelative(task.queuedAt),
                    style: TextStyle(color: kTextMuted, fontSize: 11.0.sp),
                  ),
                ),
                if (isRetryable)
                  GestureDetector(
                    onTap: () => ref
                        .read(uploadsViewModelProvider.notifier)
                        .retry(task.id),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.0.w,
                        vertical: 6.0.h,
                      ),
                      decoration: BoxDecoration(
                        color: kDanger.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8.0.r),
                        border: Border.all(
                          color: kDanger.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.rotateCw,
                            color: kDanger,
                            size: 14.0.sp,
                          ),
                          SizedBox(width: 4.0.w),
                          Text(
                            'Retry',
                            style: TextStyle(
                              color: kDanger,
                              fontSize: 11.0.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
