import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentra_ui/sentra_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../domain/work_order.dart';
import 'work_orders_view_model.dart';
import '../../../routes/app_router.dart';

@RoutePage()
class WorkOrdersScreen extends ConsumerStatefulWidget {
  const WorkOrdersScreen({super.key});

  @override
  ConsumerState<WorkOrdersScreen> createState() => _WorkOrdersScreenState();
}

class _WorkOrdersScreenState extends ConsumerState<WorkOrdersScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      ref
          .read(workOrdersViewModelProvider.notifier)
          .search(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workOrdersViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Work Orders', style: SentraTypography.h3),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus),
            onPressed: () => context.router.push(const WorkOrderCreateRoute()),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(SentraSpacing.m),
            child: SentraTextField(
              label: 'Search Orders',
              hintText: 'Search by title, ID, or location...',
              controller: _searchController,
              keyboardType: TextInputType.text,
              validator: null,
            ),
          ),
          const SizedBox(height: SentraSpacing.s),
          Expanded(
            child: state.when(
              data: (orders) => _buildOrderList(orders),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<WorkOrder> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Text('No work orders found', style: SentraTypography.bodyMedium),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: SentraSpacing.m),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final wo = orders[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: SentraSpacing.m),
          child: SentraCard(
            onTap: () =>
                context.router.push(WorkOrderDetailRoute(workOrderId: wo.id)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      wo.id,
                      style: SentraTypography.label.copyWith(
                        color: SentraColors.primary700,
                      ),
                    ),
                    SentraBadge(
                      label: wo.status.name,
                      type: _getBadgeType(wo.status),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(wo.title, style: SentraTypography.h3),
                const SizedBox(height: 4),
                Text(
                  wo.description,
                  style: SentraTypography.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      LucideIcons.mapPin,
                      size: 14,
                      color: SentraColors.gray500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      wo.siteLocation ?? 'No location',
                      style: SentraTypography.bodySmall,
                    ),
                    const Spacer(),
                    const Icon(
                      LucideIcons.calendar,
                      size: 14,
                      color: SentraColors.gray500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      wo.scheduledStart?.toString().split(' ')[0] ??
                          'Not scheduled',
                      style: SentraTypography.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  SentraBadgeType _getBadgeType(WorkOrderStatus status) {
    switch (status) {
      case WorkOrderStatus.completed:
      case WorkOrderStatus.verified:
        return SentraBadgeType.success;
      case WorkOrderStatus.inProgress:
        return SentraBadgeType.info;
      case WorkOrderStatus.onHold:
        return SentraBadgeType.warning;
      case WorkOrderStatus.cancelled:
        return SentraBadgeType.error;
      default:
        return SentraBadgeType.neutral;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
