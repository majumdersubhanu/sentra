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
import '../domain/inspection.dart';
import 'inspections_view_model.dart';

@RoutePage()
class InspectionsScreen extends ConsumerStatefulWidget {
  const InspectionsScreen({super.key});
  @override
  ConsumerState<InspectionsScreen> createState() => _InspectionsScreenState();
}

class _InspectionsScreenState extends ConsumerState<InspectionsScreen>
    with
        FilterableListMixin<Inspection, InspectionStatus>,
        StatusColorMixin,
        DateFormatMixin {
  @override
  void setFilterState(VoidCallback fn) => setState(fn);
  @override
  bool searchMatch(Inspection item, String query) =>
      item.workOrderId.toLowerCase().contains(query) ||
      item.id.toLowerCase().contains(query) ||
      item.inspectorName.toLowerCase().contains(query);
  @override
  Enum? getItemStatus(Inspection item) => item.status;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(inspectionsViewModelProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(localInspectionsProvider);
    return Scaffold(
      backgroundColor: SentraColors.gray50,
      appBar: AppBar(
        title: Text('Inspections', style: SentraTypography.h3),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Center(child: SyncStatusIndicator()),
          ),
          IconButton(
            tooltip: 'Refresh inspections',
            icon: const Icon(
              LucideIcons.refreshCw,
              color: SentraColors.primary700,
            ),
            onPressed: () =>
                ref.read(inspectionsViewModelProvider.notifier).refresh(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Create inspection',
        backgroundColor: SentraColors.primary700,
        onPressed: () => context.router.push(const InspectionCreateRoute()),
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.0.w, 16.0.h, 16.0.w, 8.0.h),
            child: TextFormField(
              onChanged: updateSearch,
              style: SentraTypography.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Search inspections...',
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
                ...InspectionStatus.values.map(
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
              data: (inspections) {
                final filtered = applyFilters(inspections);
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.clipboardCheck,
                          color: SentraColors.gray500,
                          size: 48.0.sp,
                        ),
                        SizedBox(height: 12.0.h),
                        Text(
                          searchQuery.isNotEmpty || statusFilter != null
                              ? 'No matching inspections'
                              : 'No inspections recorded',
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
                      ref.read(inspectionsViewModelProvider.notifier).refresh(),
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
    );
  }

  Widget _buildChip(InspectionStatus? status, String label) {
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

  Widget _buildCard(Inspection insp) {
    final badgeType = _getBadgeType(insp.status);
    final passed = insp.items.where((i) => i.isPass).length;
    final total = insp.items.length;
    return Padding(
      padding: EdgeInsets.only(bottom: 12.0.h),
      child: SentraCard(
        onTap: () =>
            context.router.push(InspectionDetailRoute(inspectionId: insp.id)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  insp.id,
                  style: SentraTypography.label.copyWith(
                    color: SentraColors.primary700,
                    fontSize: 12,
                  ),
                ),
                SentraBadge(label: insp.status.name, type: badgeType),
              ],
            ),
            SizedBox(height: 12.0.h),
            Text(
              insp.workOrderId,
              style: SentraTypography.h3.copyWith(fontSize: 16),
            ),
            SizedBox(height: 4.0.h),
            Text(
              insp.inspectorName,
              style: SentraTypography.bodySmall.copyWith(
                color: SentraColors.gray500,
              ),
            ),
            SizedBox(height: 16.0.h),
            Row(
              children: [
                const Icon(
                  LucideIcons.checkCircle2,
                  color: SentraColors.success,
                  size: 14,
                ),
                SizedBox(width: 4.0.w),
                Text(
                  '$passed/$total passed',
                  style: SentraTypography.bodySmall.copyWith(
                    color: SentraColors.gray700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  formatDate(insp.createdAt),
                  style: SentraTypography.bodySmall.copyWith(
                    color: SentraColors.gray500,
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

  SentraBadgeType _getBadgeType(InspectionStatus status) {
    switch (status) {
      case InspectionStatus.completed:
        return SentraBadgeType.success;
      case InspectionStatus.inProgress:
        return SentraBadgeType.info;
      case InspectionStatus.draft:
        return SentraBadgeType.neutral;
    }
  }
}
