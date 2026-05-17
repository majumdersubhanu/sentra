import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mix/mix.dart';
import '../../../core/mixins/date_format_mixin.dart';
import '../../../core/mixins/status_color_mixin.dart';
import '../../../core/theme/sentra_styles.dart';
import '../../../core/theme/sentra_tokens.dart';
import '../domain/inspection.dart';
import 'inspections_view_model.dart';

@RoutePage()
class InspectionDetailScreen extends ConsumerWidget
    with StatusColorMixin, DateFormatMixin {
  final String inspectionId;
  InspectionDetailScreen({
    super.key,
    @PathParam('id') required this.inspectionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(inspectionsViewModelProvider);
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
      data: (inspections) {
        final insp = inspections.where((i) => i.id == inspectionId).firstOrNull;
        if (insp == null) {
          return Scaffold(
            backgroundColor: kSurface,
            appBar: AppBar(backgroundColor: kSurface),
            body: const Center(
              child: Text('Not found', style: TextStyle(color: kTextSecondary)),
            ),
          );
        }

        final statusColor = getStatusColor(insp.status);
        final passed = insp.items.where((i) => i.isPass).length;
        final total = insp.items.length;
        final score = total > 0 ? passed / total : 0.0;

        return Scaffold(
          backgroundColor: kSurface,
          appBar: AppBar(
            backgroundColor: kSurface,
            title: Text(
              insp.id,
              style: TextStyle(fontSize: 18.0.sp, fontWeight: FontWeight.w700),
            ),
            actions: [
              if (insp.status == InspectionStatus.submitted)
                TextButton(
                  onPressed: () {
                    final approved = insp.copyWith(
                      status: InspectionStatus.approved,
                    );
                    ref
                        .read(inspectionsViewModelProvider.notifier)
                        .submit(approved);
                  },
                  child: Text(
                    'Approve',
                    style: TextStyle(
                      color: kSuccess,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(20.0.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Box(
                  style: $badge(
                    statusColor,
                  ).padding(.horizontal(12).vertical(8)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        getStatusIcon(insp.status),
                        color: statusColor,
                        size: 14.0.sp,
                      ),
                      SizedBox(width: 6.0.w),
                      StyledText(
                        insp.status.name.toUpperCase(),
                        style: $badgeText(statusColor).fontSize(12),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.0.h),
                Text(
                  'Inspection for ${insp.workOrderId}',
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
                      Row(
                        children: [
                          Icon(
                            Icons.verified_outlined,
                            color: kWarning,
                            size: 18.0.sp,
                          ),
                          SizedBox(width: 8.0.w),
                          Text(
                            'Compliance Score',
                            style: TextStyle(
                              color: kTextPrimary,
                              fontSize: 14.0.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0.h),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6.0.r),
                              child: LinearProgressIndicator(
                                value: score,
                                minHeight: 10.0.h,
                                backgroundColor: kSurfaceMuted,
                                color: healthColor(score),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.0.w),
                          Text(
                            '${(score * 100).toInt()}%',
                            style: TextStyle(
                              color: healthColor(score),
                              fontSize: 16.0.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.0.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$passed of $total items passed',
                            style: TextStyle(
                              color: kTextMuted,
                              fontSize: 11.0.sp,
                            ),
                          ),
                          Text(
                            score >= 0.8 ? 'COMPLIANT' : 'NON-COMPLIANT',
                            style: TextStyle(
                              color: score >= 0.8 ? kSuccess : kDanger,
                              fontSize: 11.0.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
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
                        children: [
                          Icon(
                            Icons.person_outline,
                            color: kAccent,
                            size: 18.0.sp,
                          ),
                          SizedBox(width: 8.0.w),
                          Text(
                            'Details',
                            style: TextStyle(
                              color: kTextPrimary,
                              fontSize: 14.0.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0.h),
                      _detailRow('Inspector', insp.inspectorName),
                      _detailRow('Date', formatDate(insp.createdAt)),
                      _detailRow('Work Order', insp.workOrderId),
                      _detailRow('Items', '$total checklist items'),
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
                        children: [
                          Icon(
                            Icons.checklist_outlined,
                            color: kEmerald500,
                            size: 18.0.sp,
                          ),
                          SizedBox(width: 8.0.w),
                          Text(
                            'Checklist',
                            style: TextStyle(
                              color: kTextPrimary,
                              fontSize: 14.0.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0.h),
                      ...insp.items.map(_buildChecklistItem),
                    ],
                  ),
                ),
                SizedBox(height: 32.0.h),
              ],
            ),
          ),
        );
      },
    );
  }

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

  Widget _buildChecklistItem(InspectionItem item) {
    final passColor = item.isPass ? kSuccess : kDanger;
    return Padding(
      padding: EdgeInsets.only(bottom: 12.0.h),
      child: Box(
        style: BoxStyler()
            .color(passColor.withValues(alpha: 0.06))
            .borderRadius(.circular(10))
            .padding(.all(12)),
        child: Row(
          children: [
            Icon(
              item.isPass ? Icons.check_circle : Icons.cancel,
              color: passColor,
              size: 20.0.sp,
            ),
            SizedBox(width: 12.0.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.question,
                    style: TextStyle(
                      color: kTextPrimary,
                      fontSize: 13.0.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (item.comments != null && item.comments!.isNotEmpty) ...[
                    SizedBox(height: 4.0.h),
                    Text(
                      item.comments!,
                      style: TextStyle(color: kTextMuted, fontSize: 11.0.sp),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
