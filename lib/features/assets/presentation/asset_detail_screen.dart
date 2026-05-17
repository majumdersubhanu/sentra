import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sentra_ui/sentra_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/mixins/date_format_mixin.dart';
import '../../../core/mixins/status_color_mixin.dart';
import 'assets_view_model.dart';
import '../../auth/presentation/auth_view_model.dart';
import '../domain/asset.dart';

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
        backgroundColor: SentraColors.gray50,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        backgroundColor: SentraColors.gray50,
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
        body: Center(
          child: Text('Error: $err', style: SentraTypography.bodyMedium),
        ),
      ),
      data: (assets) {
        final asset = assets.where((a) => a.id == assetId).firstOrNull;
        if (asset == null) {
          return Scaffold(
            backgroundColor: SentraColors.gray50,
            appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
            body: Center(
              child: Text('Not found', style: SentraTypography.bodyLarge),
            ),
          );
        }

        final badgeType = _getBadgeType(asset.status);
        final daysSince = DateTime.now()
            .difference(asset.lastServicedDate)
            .inDays;
        final healthRatio = (1.0 - (daysSince / 90)).clamp(0.0, 1.0);

        return Scaffold(
          backgroundColor: SentraColors.gray50,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(asset.id, style: SentraTypography.h3),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(20.0.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SentraBadge(label: asset.status.name, type: badgeType),
                SizedBox(height: 20.0.h),
                Text(asset.name, style: SentraTypography.h1),
                SizedBox(height: 24.0.h),

                SentraCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionHeader(LucideIcons.fingerprint, 'Identification'),
                      SizedBox(height: 16.0.h),
                      _detailRow('Asset ID', asset.id),
                      _detailRow('Model Number', asset.modelNumber),
                      _detailRow('Serial Number', asset.serialNumber),
                    ],
                  ),
                ),
                SizedBox(height: 16.0.h),

                SentraCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionHeader(LucideIcons.mapPin, 'Location'),
                      SizedBox(height: 16.0.h),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.0.w),
                            decoration: BoxDecoration(
                              color: SentraColors.primary50,
                              borderRadius: BorderRadius.circular(
                                SentraSpacing.xs,
                              ),
                            ),
                            child: const Icon(
                              LucideIcons.navigation,
                              color: SentraColors.primary700,
                              size: 20,
                            ),
                          ),
                          SizedBox(width: 16.0.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  asset.locationCoordinates,
                                  style: SentraTypography.bodyLarge,
                                ),
                                Text(
                                  'Coordinates',
                                  style: SentraTypography.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.0.h),

                SentraCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionHeader(
                        LucideIcons.activity,
                        'Maintenance Health',
                      ),
                      SizedBox(height: 16.0.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: healthRatio,
                          minHeight: 8,
                          backgroundColor: SentraColors.gray100,
                          valueColor: AlwaysStoppedAnimation(
                            healthColor(healthRatio),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.0.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Last Serviced: ${formatDate(asset.lastServicedDate)}',
                            style: SentraTypography.bodySmall,
                          ),
                          Text(
                            '${(healthRatio * 100).toInt()}%',
                            style: SentraTypography.label.copyWith(
                              color: healthColor(healthRatio),
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
          bottomNavigationBar: Consumer(
            builder: (context, ref, child) {
              final user = ref.watch(currentUserProfileProvider);
              if (user?.role.isSupervisorOrAbove ?? false) {
                return Container(
                  padding: const EdgeInsets.all(SentraSpacing.m),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: SentraColors.gray200),
                    ),
                  ),
                  child: SentraButton(
                    label: 'Decommission Asset',
                    onPressed: () {},
                    isPrimary: false,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }

  Widget _sectionHeader(IconData icon, String title) => Row(
    children: [
      Icon(icon, size: 16, color: SentraColors.primary500),
      SizedBox(width: 8.0.w),
      Text(
        title.toUpperCase(),
        style: SentraTypography.label.copyWith(
          color: SentraColors.gray500,
          fontSize: 11,
        ),
      ),
    ],
  );

  Widget _detailRow(String label, String value) => Padding(
    padding: EdgeInsets.symmetric(vertical: 8.0.h),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: SentraTypography.bodySmall),
        Text(value, style: SentraTypography.label),
      ],
    ),
  );

  SentraBadgeType _getBadgeType(AssetOperationalStatus status) {
    switch (status) {
      case AssetOperationalStatus.online:
        return SentraBadgeType.success;
      case AssetOperationalStatus.maintenance:
        return SentraBadgeType.warning;
      case AssetOperationalStatus.offline:
        return SentraBadgeType.error;
      case AssetOperationalStatus.decommissioned:
        return SentraBadgeType.neutral;
    }
  }

  Color healthColor(double ratio) {
    if (ratio >= 0.75) return SentraColors.success;
    if (ratio >= 0.45) return SentraColors.warning;
    return SentraColors.error;
  }
}
