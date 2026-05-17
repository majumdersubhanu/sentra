import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mix/mix.dart';
import '../../../core/mixins/date_format_mixin.dart';
import '../../../core/mixins/status_color_mixin.dart';
import '../../../core/theme/sentra_styles.dart';
import '../../../core/theme/sentra_tokens.dart';
import 'assets_view_model.dart';

@RoutePage()
class AssetDetailScreen extends ConsumerWidget
    with StatusColorMixin, DateFormatMixin {
  final String assetId;
  AssetDetailScreen({super.key, @PathParam('id') required this.assetId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(assetsViewModelProvider);
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
      data: (assets) {
        final asset = assets.where((a) => a.id == assetId).firstOrNull;
        if (asset == null) {
          return Scaffold(
            backgroundColor: kSurface,
            appBar: AppBar(backgroundColor: kSurface),
            body: const Center(
              child: Text('Not found', style: TextStyle(color: kTextSecondary)),
            ),
          );
        }

        final statusColor = getStatusColor(asset.status);
        final daysSince = DateTime.now()
            .difference(asset.lastServicedDate)
            .inDays;
        final healthRatio = (1.0 - (daysSince / 90)).clamp(0.0, 1.0);

        return Scaffold(
          backgroundColor: kSurface,
          appBar: AppBar(
            backgroundColor: kSurface,
            title: Text(
              asset.id,
              style: TextStyle(fontSize: 18.0.sp, fontWeight: FontWeight.w700),
            ),
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
                        getStatusIcon(asset.status),
                        color: statusColor,
                        size: 16.0.sp,
                      ),
                      SizedBox(width: 6.0.w),
                      StyledText(
                        asset.status.name.toUpperCase(),
                        style: $badgeText(statusColor).fontSize(12),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.0.h),
                Text(
                  asset.name,
                  style: TextStyle(
                    color: kTextPrimary,
                    fontSize: 22.0.sp,
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
                      _sectionHeader(Icons.qr_code_2, 'Identification'),
                      SizedBox(height: 16.0.h),
                      _detailRow('Asset ID', asset.id),
                      _detailRow('Model Number', asset.modelNumber),
                      _detailRow('Serial Number', asset.serialNumber),
                    ],
                  ),
                ),
                SizedBox(height: 16.0.h),

                Box(
                  style: $sectionCard(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionHeader(Icons.location_on_outlined, 'Location'),
                      SizedBox(height: 16.0.h),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.0.w),
                            decoration: BoxDecoration(
                              color: kEmerald500.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10.0.r),
                            ),
                            child: Icon(
                              Icons.pin_drop,
                              color: kEmerald500,
                              size: 22.0.sp,
                            ),
                          ),
                          SizedBox(width: 14.0.w),
                          Expanded(
                            child: Text(
                              asset.locationCoordinates,
                              style: TextStyle(
                                color: kTextPrimary,
                                fontSize: 14.0.sp,
                                fontWeight: FontWeight.w600,
                              ),
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
                      _sectionHeader(Icons.build_outlined, 'Maintenance'),
                      SizedBox(height: 16.0.h),
                      _detailRow(
                        'Last Serviced',
                        formatDate(asset.lastServicedDate),
                      ),
                      _detailRow('Days Since Service', '$daysSince days'),
                      SizedBox(height: 8.0.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6.0.r),
                        child: LinearProgressIndicator(
                          value: healthRatio,
                          minHeight: 8.0.h,
                          backgroundColor: kSurfaceMuted,
                          color: healthColor(healthRatio),
                        ),
                      ),
                      SizedBox(height: 6.0.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Service Health',
                            style: TextStyle(
                              color: kTextMuted,
                              fontSize: 11.0.sp,
                            ),
                          ),
                          Text(
                            daysSince < 30
                                ? 'Good'
                                : daysSince < 60
                                ? 'Due Soon'
                                : 'Overdue',
                            style: TextStyle(
                              color: healthColor(healthRatio),
                              fontSize: 11.0.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
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

  Widget _sectionHeader(IconData icon, String title) => Row(
    children: [
      Icon(icon, color: kEmerald500, size: 18.0.sp),
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
}
