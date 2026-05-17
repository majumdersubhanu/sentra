import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mix/mix.dart';
import '../../../core/mixins/date_format_mixin.dart';
import '../../../core/mixins/status_color_mixin.dart';
import '../../../core/theme/sentra_styles.dart';
import '../../../core/theme/sentra_tokens.dart';
import '../domain/work_order.dart';
import 'widgets/work_order_comments_section.dart';
import 'work_orders_view_model.dart';
import '../../uploads/presentation/widgets/attachment_picker.dart';
import '../../uploads/presentation/widgets/attachment_gallery.dart';
import '../../uploads/presentation/attachments_provider.dart';

@RoutePage()
class WorkOrderDetailScreen extends ConsumerWidget
    with StatusColorMixin, DateFormatMixin {
  final String workOrderId;
  WorkOrderDetailScreen({
    super.key,
    @PathParam('id') required this.workOrderId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workOrderByIdProvider(workOrderId));
    return state.when(
      loading: () => const Scaffold(
        backgroundColor: kSurface,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        backgroundColor: kSurface,
        appBar: AppBar(backgroundColor: kSurface),
        body: Center(
          child: Text(
            'Error: $err',
            style: const TextStyle(color: kTextPrimary),
          ),
        ),
      ),
      data: (wo) {
        if (wo == null) {
          return Scaffold(
            backgroundColor: kSurface,
            appBar: AppBar(
              backgroundColor: kSurface,
              actions: [
                IconButton(
                  tooltip: 'Retry',
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    ref.invalidate(workOrderByIdProvider(workOrderId));
                    ref.read(workOrdersViewModelProvider.notifier).refresh();
                  },
                ),
              ],
            ),
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(20.0.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_off, color: kTextMuted, size: 42.0.sp),
                    SizedBox(height: 10.0.h),
                    Text(
                      'Work order not found',
                      style: TextStyle(
                        color: kTextPrimary,
                        fontSize: 15.0.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6.0.h),
                    Text(
                      'The record may still be syncing or may no longer exist.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: kTextMuted, fontSize: 12.0.sp),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final statusColor = getStatusColor(wo.status);
        final priorityColor = getStatusColor(wo.priority);

        return Scaffold(
          backgroundColor: kSurface,
          appBar: AppBar(
            backgroundColor: kSurface,
            title: Text(
              wo.id,
              style: TextStyle(fontSize: 18.0.sp, fontWeight: FontWeight.w700),
            ),
            actions: [
              PopupMenuButton<WorkOrderStatus>(
                icon: const Icon(Icons.more_vert),
                color: kSurfaceElevated,
                onSelected: (s) => ref
                    .read(workOrdersViewModelProvider.notifier)
                    .updateStatus(wo, s),
                itemBuilder: (_) => WorkOrderStatus.values
                    .where((s) => s != wo.status)
                    .map(
                      (s) => PopupMenuItem(
                        value: s,
                        child: Row(
                          children: [
                            Icon(
                              getStatusIcon(s),
                              color: getStatusColor(s),
                              size: 16,
                            ),
                            SizedBox(width: 8.0.w),
                            Text(
                              s.name.toUpperCase(),
                              style: TextStyle(
                                color: kTextPrimary,
                                fontSize: 12.0.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(20.0.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Box(
                      style: $badge(statusColor),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            getStatusIcon(wo.status),
                            color: statusColor,
                            size: 14.0.sp,
                          ),
                          SizedBox(width: 4.0.w),
                          StyledText(
                            wo.status.name.toUpperCase(),
                            style: $badgeText(statusColor).fontSize(11),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.0.w),
                    Box(
                      style: $badge(priorityColor),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            getStatusIcon(wo.priority),
                            color: priorityColor,
                            size: 14.0.sp,
                          ),
                          SizedBox(width: 4.0.w),
                          StyledText(
                            wo.priority.name.toUpperCase(),
                            style: $badgeText(priorityColor).fontSize(11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.0.h),
                Text(
                  wo.title,
                  style: TextStyle(
                    color: kTextPrimary,
                    fontSize: 20.0.sp,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 20.0.h),
                Box(
                  style: $sectionCard(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionHeader(Icons.description_outlined, 'Description'),
                      SizedBox(height: 12.0.h),
                      Text(
                        wo.description,
                        style: TextStyle(
                          color: kTextSecondary,
                          fontSize: 14.0.sp,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.0.h),
                Box(
                  style: $sectionCard(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionHeader(Icons.info_outline, 'Details'),
                      SizedBox(height: 16.0.h),
                      _detailRow('Work Order ID', wo.id),
                      _detailRow('Created', formatDateTime(wo.createdAt)),
                      _detailRow('Scheduled', formatDateTime(wo.scheduledDate)),
                      _detailRow('Asset', wo.assetId ?? 'Unassigned'),
                      _detailRow('Assigned To', wo.assignedTo ?? 'Unassigned'),
                      _detailRow('Status', wo.status.name.toUpperCase()),
                      _detailRow('Priority', wo.priority.name.toUpperCase()),
                    ],
                  ),
                ),
                SizedBox(height: 16.0.h),
                Box(
                  style: $sectionCard(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionHeader(Icons.timeline, 'Activity'),
                      SizedBox(height: 16.0.h),
                      _timelineItem('Created', formatDate(wo.createdAt), kInfo),
                      if (wo.assignedTo != null)
                        _timelineItem(
                          'Assigned',
                          formatDate(wo.createdAt),
                          const Color(0xFF8B5CF6),
                        ),
                      _timelineItem(
                        'Scheduled',
                        formatDate(wo.scheduledDate),
                        kWarning,
                      ),
                      if (wo.status == WorkOrderStatus.completed ||
                          wo.status == WorkOrderStatus.verified)
                        _timelineItem(
                          'Completed',
                          formatDate(DateTime.now()),
                          kSuccess,
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 16.0.h),
                Box(
                  style: $sectionCard(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _sectionHeader(Icons.attach_file, 'Attachments'),
                          IconButton(
                            icon: const Icon(Icons.add_a_photo, color: kBrand),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (_) => Padding(
                                  padding: EdgeInsets.all(16.0.w),
                                  child: AttachmentPicker(
                                    entityId: wo.id,
                                    entityType: 'work_order',
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0.h),
                      ref
                          .watch(attachmentsProvider(wo.id))
                          .when(
                            data: (attachments) =>
                                AttachmentGallery(attachments: attachments),
                            loading: () => const CircularProgressIndicator(),
                            error: (err, stackTrace) =>
                                const Text('Failed to load attachments'),
                          ),
                    ],
                  ),
                ),
                SizedBox(height: 16.0.h),
                // Comments section
                WorkOrderCommentsSection(workOrderId: workOrderId),
                SizedBox(height: 32.0.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionHeader(IconData icon, String title) => Row(
    children: [
      Icon(icon, color: kAccent, size: 18.0.sp),
      SizedBox(width: 8.0.w),
      Text(
        title,
        style: TextStyle(
          color: kTextPrimary,
          fontSize: 14.0.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );

  Widget _detailRow(String label, String value) => Padding(
    padding: EdgeInsets.only(bottom: 10.0.h),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        StyledText(label, style: $detailLabel()),
        Flexible(child: StyledText(value, style: $detailValue())),
      ],
    ),
  );

  Widget _timelineItem(String event, String date, Color color) => Padding(
    padding: EdgeInsets.only(bottom: 12.0.h),
    child: Row(
      children: [
        Container(
          width: 8.0.w,
          height: 8.0.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 12.0.w),
        Expanded(
          child: Text(
            event,
            style: TextStyle(
              color: kTextPrimary,
              fontSize: 13.0.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          date,
          style: TextStyle(color: kTextMuted, fontSize: 11.0.sp),
        ),
      ],
    ),
  );
}
