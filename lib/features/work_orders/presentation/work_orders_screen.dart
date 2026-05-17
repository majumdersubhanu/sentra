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
import '../domain/work_order.dart';
import 'work_orders_view_model.dart';

@RoutePage()
class WorkOrdersScreen extends ConsumerStatefulWidget {
  const WorkOrdersScreen({super.key});
  @override
  ConsumerState<WorkOrdersScreen> createState() => _WorkOrdersScreenState();
}

class _WorkOrdersScreenState extends ConsumerState<WorkOrdersScreen>
    with
        FilterableListMixin<WorkOrder, WorkOrderStatus>,
        StatusColorMixin,
        DateFormatMixin {
  @override
  void setFilterState(VoidCallback fn) => setState(fn);
  @override
  bool searchMatch(WorkOrder item, String query) =>
      item.title.toLowerCase().contains(query) ||
      item.id.toLowerCase().contains(query) ||
      item.description.toLowerCase().contains(query);
  @override
  Enum? getItemStatus(WorkOrder item) => item.status;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(workOrdersViewModelProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(localWorkOrdersProvider);
    return Scaffold(
      backgroundColor: kSurface,
      appBar: AppBar(
        title: Text(
          'Work Orders',
          style: TextStyle(fontSize: 18.0.sp, fontWeight: FontWeight.w700),
        ),
        backgroundColor: kSurface,
        actions: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Center(child: SyncStatusIndicator()),
          ),
          IconButton(
            tooltip: 'Refresh work orders',
            icon: const Icon(LucideIcons.refreshCw),
            onPressed: () =>
                ref.read(workOrdersViewModelProvider.notifier).refresh(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Create work order',
        backgroundColor: kAccent,
        onPressed: () => context.router.push(const WorkOrderCreateRoute()),
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.0.w, 8.0.h, 16.0.w, 4.0.h),
            child: TextField(
              onChanged: updateSearch,
              style: TextStyle(color: kTextPrimary, fontSize: 14.0.sp),
              decoration: sentraSearchDecoration(hint: 'Search work orders...'),
            ),
          ),
          SizedBox(
            height: 44.0.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.0.w),
              children: [
                _buildChip(null, 'All'),
                ...WorkOrderStatus.values.map(
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
                      'Failed to load: $err',
                      style: const TextStyle(color: kTextPrimary),
                    ),
                  ],
                ),
              ),
              data: (orders) {
                final filtered = applyFilters(orders);
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.briefcaseBusiness,
                          color: kTextMuted,
                          size: 48.0.sp,
                        ),
                        SizedBox(height: 12.0.h),
                        StyledText(
                          searchQuery.isNotEmpty || statusFilter != null
                              ? 'No matching orders'
                              : 'No work orders found',
                          style: $emptyStateText(),
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  color: kAccent,
                  backgroundColor: kSurfaceElevated,
                  onRefresh: () async =>
                      ref.read(workOrdersViewModelProvider.notifier).refresh(),
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

  Widget _buildChip(WorkOrderStatus? status, String label) {
    final isActive = statusFilter == status;
    final color = status != null ? getStatusColor(status) : kAccent;
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

  Widget _buildCard(WorkOrder wo) {
    final statusColor = getStatusColor(wo.status);
    final priorityColor = getStatusColor(wo.priority);
    return Padding(
      padding: EdgeInsets.only(bottom: 14.0.h),
      child: GestureDetector(
        onTap: () =>
            context.router.push(WorkOrderDetailRoute(workOrderId: wo.id)),
        child: Box(
          style: $card().padding(.all(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StyledText(
                    wo.id,
                    style: TextStyler()
                        .color(kAccent.withValues(alpha: 0.8))
                        .fontWeight(.w600)
                        .fontSize(12.0.sp.toDouble()),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Box(
                        style: $badge(priorityColor),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              getStatusIcon(wo.priority),
                              color: priorityColor,
                              size: 10.0.sp,
                            ),
                            SizedBox(width: 3.0.w),
                            StyledText(
                              wo.priority.name.toUpperCase(),
                              style: $badgeText(priorityColor),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 6.0.w),
                      Box(
                        style: $badge(statusColor),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              getStatusIcon(wo.status),
                              color: statusColor,
                              size: 10.0.sp,
                            ),
                            SizedBox(width: 3.0.w),
                            StyledText(
                              wo.status.name.toUpperCase(),
                              style: $badgeText(statusColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10.0.h),
              Text(
                wo.title,
                style: TextStyle(
                  color: kTextPrimary,
                  fontSize: 15.0.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4.0.h),
              Text(
                wo.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: kTextMuted, fontSize: 12.0.sp),
              ),
              SizedBox(height: 12.0.h),
              Row(
                children: [
                  Icon(
                    LucideIcons.calendarDays,
                    color: kTextMuted,
                    size: 13.0.sp,
                  ),
                  SizedBox(width: 4.0.w),
                  Expanded(
                    child: Text(
                      formatDate(wo.scheduledDate),
                      style: TextStyle(color: kTextMuted, fontSize: 11.0.sp),
                    ),
                  ),
                  if (wo.assetId != null)
                    Text(
                      wo.assetId!,
                      style: TextStyle(
                        color: kEmerald500.withValues(alpha: 0.6),
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
