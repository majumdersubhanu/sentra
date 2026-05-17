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
      backgroundColor: kSurface,
      appBar: AppBar(
        title: Text(
          'Asset Inventory',
          style: TextStyle(fontSize: 18.0.sp, fontWeight: FontWeight.w700),
        ),
        backgroundColor: kSurface,
        actions: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Center(child: SyncStatusIndicator()),
          ),
          IconButton(
            tooltip: 'Refresh assets',
            icon: const Icon(LucideIcons.refreshCw),
            onPressed: () =>
                ref.read(assetsViewModelProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.0.w, 8.0.h, 16.0.w, 4.0.h),
            child: TextField(
              onChanged: updateSearch,
              style: TextStyle(color: kTextPrimary, fontSize: 14.0.sp),
              decoration: sentraSearchDecoration(hint: 'Search assets...'),
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
              data: (assets) {
                final filtered = applyFilters(assets);
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.package,
                          color: kTextMuted,
                          size: 48.0.sp,
                        ),
                        SizedBox(height: 12.0.h),
                        StyledText(
                          searchQuery.isNotEmpty || statusFilter != null
                              ? 'No matching assets'
                              : 'No assets registered',
                          style: $emptyStateText(),
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  color: kEmerald500,
                  backgroundColor: kSurfaceElevated,
                  onRefresh: () async =>
                      ref.read(assetsViewModelProvider.notifier).refresh(),
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            tooltip: 'Create asset manually',
            backgroundColor: kBrand.withValues(alpha: 0.85),
            heroTag: 'create-asset',
            child: const Icon(LucideIcons.plus, color: kSurface),
            onPressed: () => context.router.push(const AssetCreateRoute()),
          ),
          SizedBox(height: 12.0.h),
          FloatingActionButton(
            tooltip: 'Scan asset QR code',
            backgroundColor: kBrand,
            heroTag: 'scan-asset',
            child: const Icon(LucideIcons.scanQrCode, color: kSurface),
            onPressed: () => context.router.push(const AssetScannerRoute()),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(AssetOperationalStatus? status, String label) {
    final isActive = statusFilter == status;
    final color = status != null ? getStatusColor(status) : kEmerald500;
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

  Widget _buildCard(Asset asset) {
    final statusColor = getStatusColor(asset.status);
    final daysSince = DateTime.now().difference(asset.lastServicedDate).inDays;
    return Padding(
      padding: EdgeInsets.only(bottom: 14.0.h),
      child: GestureDetector(
        onTap: () => context.router.push(AssetDetailRoute(assetId: asset.id)),
        child: Box(
          style: $card().padding(.all(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StyledText(
                    asset.id,
                    style: TextStyler()
                        .color(kEmerald500.withValues(alpha: 0.8))
                        .fontWeight(.w600)
                        .fontSize(12.0.sp.toDouble()),
                  ),
                  Box(
                    style: $badge(statusColor),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          getStatusIcon(asset.status),
                          color: statusColor,
                          size: 12.0.sp,
                        ),
                        SizedBox(width: 4.0.w),
                        StyledText(
                          asset.status.name.toUpperCase(),
                          style: $badgeText(statusColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.0.h),
              Text(
                asset.name,
                style: TextStyle(
                  color: kTextPrimary,
                  fontSize: 15.0.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4.0.h),
              Text(
                '${asset.modelNumber}  •  ${asset.serialNumber}',
                style: TextStyle(color: kTextMuted, fontSize: 12.0.sp),
              ),
              SizedBox(height: 12.0.h),
              Row(
                children: [
                  Icon(LucideIcons.mapPin, color: kTextMuted, size: 14.0.sp),
                  SizedBox(width: 4.0.w),
                  Expanded(
                    child: Text(
                      asset.locationCoordinates,
                      style: TextStyle(color: kTextMuted, fontSize: 12.0.sp),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${daysSince}d ago',
                    style: TextStyle(
                      color: healthColor(
                        (1.0 - daysSince / 90).clamp(0.0, 1.0),
                      ),
                      fontSize: 11.0.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8.0.w),
                  Icon(
                    LucideIcons.chevronRight,
                    color: kTextMuted.withValues(alpha: 0.5),
                    size: 20.0.sp,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
