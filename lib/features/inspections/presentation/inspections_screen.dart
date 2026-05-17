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
      backgroundColor: kSurface,
      appBar: AppBar(
        title: Text(
          'Inspections',
          style: TextStyle(fontSize: 18.0.sp, fontWeight: FontWeight.w700),
        ),
        backgroundColor: kSurface,
        actions: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Center(child: SyncStatusIndicator()),
          ),
          IconButton(
            tooltip: 'Refresh inspections',
            icon: const Icon(LucideIcons.refreshCw),
            onPressed: () =>
                ref.read(inspectionsViewModelProvider.notifier).refresh(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Create inspection',
        backgroundColor: kWarning,
        onPressed: () => context.router.push(const InspectionCreateRoute()),
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.0.w, 8.0.h, 16.0.w, 4.0.h),
            child: TextField(
              onChanged: updateSearch,
              style: TextStyle(color: kTextPrimary, fontSize: 14.0.sp),
              decoration: sentraSearchDecoration(hint: 'Search inspections...'),
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
              data: (inspections) {
                final filtered = applyFilters(inspections);
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.clipboardCheck,
                          color: kTextMuted,
                          size: 48.0.sp,
                        ),
                        SizedBox(height: 12.0.h),
                        StyledText(
                          searchQuery.isNotEmpty || statusFilter != null
                              ? 'No matching inspections'
                              : 'No inspections recorded',
                          style: $emptyStateText(),
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  color: kWarning,
                  backgroundColor: kSurfaceElevated,
                  onRefresh: () async =>
                      ref.read(inspectionsViewModelProvider.notifier).refresh(),
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

  Widget _buildChip(InspectionStatus? status, String label) {
    final isActive = statusFilter == status;
    final color = status != null ? getStatusColor(status) : kWarning;
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

  Widget _buildCard(Inspection insp) {
    final statusColor = getStatusColor(insp.status);
    final passed = insp.items.where((i) => i.isPass).length;
    final total = insp.items.length;
    return Padding(
      padding: EdgeInsets.only(bottom: 14.0.h),
      child: GestureDetector(
        onTap: () =>
            context.router.push(InspectionDetailRoute(inspectionId: insp.id)),
        child: Box(
          style: $card().padding(.all(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StyledText(
                    insp.id,
                    style: TextStyler()
                        .color(kWarning.withValues(alpha: 0.8))
                        .fontWeight(.w600)
                        .fontSize(12.0.sp.toDouble()),
                  ),
                  Box(
                    style: $badge(statusColor),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          getStatusIcon(insp.status),
                          color: statusColor,
                          size: 10.0.sp,
                        ),
                        SizedBox(width: 3.0.w),
                        StyledText(
                          insp.status.name.toUpperCase(),
                          style: $badgeText(statusColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.0.h),
              Text(
                insp.workOrderId,
                style: TextStyle(
                  color: kTextPrimary,
                  fontSize: 15.0.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4.0.h),
              Text(
                insp.inspectorName,
                style: TextStyle(color: kTextMuted, fontSize: 12.0.sp),
              ),
              SizedBox(height: 12.0.h),
              Row(
                children: [
                  Icon(LucideIcons.circleCheck, color: kSuccess, size: 13.0.sp),
                  SizedBox(width: 4.0.w),
                  Text(
                    '$passed/$total passed',
                    style: TextStyle(color: kTextSecondary, fontSize: 11.0.sp),
                  ),
                  const Spacer(),
                  Text(
                    formatDate(insp.createdAt),
                    style: TextStyle(color: kTextMuted, fontSize: 11.0.sp),
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
