import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sentra_ui/sentra_ui.dart';
import '../../../core/mixins/date_format_mixin.dart';
import '../../../core/mixins/filterable_list_mixin.dart';
import '../../../core/mixins/status_color_mixin.dart';
import '../../../shared/widgets/sync_status_indicator.dart';
import '../../../routes/app_router.dart';
import '../domain/asset.dart';
import 'assets_view_model.dart';

@RoutePage()
class AssetsScreen extends ConsumerStatefulWidget {
  const AssetsScreen({super.key});
  @override
  ConsumerState<AssetsScreen> createState() => _AssetsScreenState();
}

class _AssetsScreenState extends ConsumerState<AssetsScreen>
    with
        FilterableListMixin<Asset, AssetOperationalStatus>,
        StatusColorMixin,
        DateFormatMixin {
  @override
  void setFilterState(VoidCallback fn) => setState(fn);
  @override
  bool searchMatch(Asset item, String query) =>
      item.name.toLowerCase().contains(query) ||
      item.id.toLowerCase().contains(query) ||
      item.modelNumber.toLowerCase().contains(query) ||
      item.serialNumber.toLowerCase().contains(query);
  @override
  Enum? getItemStatus(Asset item) => item.status;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(assetsViewModelProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(localAssetsProvider);
    return Scaffold(
      backgroundColor: SentraColors.gray50,
      appBar: AppBar(
        title: Text('Asset Inventory', style: SentraTypography.h3),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Center(child: SyncStatusIndicator()),
          ),
          IconButton(
            tooltip: 'Refresh assets',
            icon: const Icon(
              LucideIcons.refreshCw,
              color: SentraColors.primary700,
            ),
            onPressed: () =>
                ref.read(assetsViewModelProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.0.w, 16.0.h, 16.0.w, 8.0.h),
            child: TextFormField(
              onChanged: updateSearch,
              style: SentraTypography.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Search assets...',
                prefixIcon: const Icon(LucideIcons.search, size: 18),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: SentraSpacing.m,
                  vertical: SentraSpacing.s,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SentraSpacing.xs),
                  borderSide: const BorderSide(color: SentraColors.gray200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SentraSpacing.xs),
                  borderSide: const BorderSide(color: SentraColors.gray200),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 44.0.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.0.w),
              children: [
                _buildChip(null, 'All'),
                ...AssetOperationalStatus.values.map(
                  (s) => _buildChip(s, s.name.toUpperCase()),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.0.h),
          Expanded(
            child: state.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.alertCircle,
                      color: SentraColors.error,
                      size: 48.0.sp,
                    ),
                    SizedBox(height: 16.0.h),
                    Text('Failed: $err', style: SentraTypography.bodyMedium),
                  ],
                ),
              ),
              data: (assets) {
                final filtered = applyFilters(assets);
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.package,
                          color: SentraColors.gray500,
                          size: 48.0.sp,
                        ),
                        SizedBox(height: 12.0.h),
                        Text(
                          searchQuery.isNotEmpty || statusFilter != null
                              ? 'No matching assets'
                              : 'No assets registered',
                          style: SentraTypography.bodyLarge.copyWith(
                            color: SentraColors.gray500,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  color: SentraColors.primary700,
                  onRefresh: () async =>
                      ref.read(assetsViewModelProvider.notifier).refresh(),
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.0.w),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => _buildCard(filtered[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            tooltip: 'Create asset manually',
            backgroundColor: SentraColors.primary700.withValues(alpha: 0.85),
            heroTag: 'create-asset',
            child: const Icon(LucideIcons.plus, color: Colors.white),
            onPressed: () => context.router.push(const AssetCreateRoute()),
          ),
          SizedBox(height: 12.0.h),
          FloatingActionButton(
            tooltip: 'Scan asset QR code',
            backgroundColor: SentraColors.primary700,
            heroTag: 'scan-asset',
            child: const Icon(LucideIcons.scanQrCode, color: Colors.white),
            onPressed: () => context.router.push(const AssetScannerRoute()),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(AssetOperationalStatus? status, String label) {
    final isActive = statusFilter == status;
    return Padding(
      padding: EdgeInsets.only(right: 8.0.w),
      child: ChoiceChip(
        label: Text(label),
        selected: isActive,
        onSelected: (_) => updateFilter(status),
        selectedColor: SentraColors.primary700,
        labelStyle: SentraTypography.label.copyWith(
          color: isActive ? Colors.white : SentraColors.gray700,
          fontSize: 10,
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SentraSpacing.xxl),
          side: BorderSide(
            color: isActive ? SentraColors.primary700 : SentraColors.gray200,
          ),
        ),
      ),
    );
  }

  Widget _buildCard(Asset asset) {
    final badgeType = _getBadgeType(asset.status);
    final daysSince = DateTime.now().difference(asset.lastServicedDate).inDays;
    return Padding(
      padding: EdgeInsets.only(bottom: 12.0.h),
      child: SentraCard(
        onTap: () => context.router.push(AssetDetailRoute(assetId: asset.id)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  asset.id,
                  style: SentraTypography.label.copyWith(
                    color: SentraColors.primary700,
                    fontSize: 12,
                  ),
                ),
                SentraBadge(label: asset.status.name, type: badgeType),
              ],
            ),
            SizedBox(height: 12.0.h),
            Text(asset.name, style: SentraTypography.h3.copyWith(fontSize: 16)),
            SizedBox(height: 4.0.h),
            Text(
              '${asset.modelNumber}  •  ${asset.serialNumber}',
              style: SentraTypography.bodySmall.copyWith(
                color: SentraColors.gray500,
              ),
            ),
            SizedBox(height: 16.0.h),
            Row(
              children: [
                const Icon(
                  LucideIcons.mapPin,
                  color: SentraColors.gray500,
                  size: 14,
                ),
                SizedBox(width: 4.0.w),
                Expanded(
                  child: Text(
                    asset.locationCoordinates,
                    style: SentraTypography.bodySmall.copyWith(
                      color: SentraColors.gray500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${daysSince}d ago',
                  style: SentraTypography.label.copyWith(
                    color: daysSince > 90
                        ? SentraColors.error
                        : SentraColors.success,
                    fontSize: 11,
                  ),
                ),
                SizedBox(width: 4.0.w),
                const Icon(
                  LucideIcons.chevronRight,
                  color: SentraColors.gray200,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

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
}
