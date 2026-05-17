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
import '../domain/upload_repository.dart';
import 'uploads_view_model.dart';

@RoutePage()
class UploadsScreen extends ConsumerStatefulWidget {
  const UploadsScreen({super.key});
  @override
  ConsumerState<UploadsScreen> createState() => _UploadsScreenState();
}

class _UploadsScreenState extends ConsumerState<UploadsScreen>
    with
        FilterableListMixin<UploadTask, UploadState>,
        StatusColorMixin,
        DateFormatMixin {
  @override
  void setFilterState(VoidCallback fn) => setState(fn);
  @override
  bool searchMatch(UploadTask item, String query) =>
      item.localPayloadPath.toLowerCase().contains(query) ||
      item.id.toLowerCase().contains(query);
  @override
  Enum? getItemStatus(UploadTask item) => item.state;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(uploadsViewModelProvider);
    return Scaffold(
      backgroundColor: SentraColors.gray50,
      appBar: AppBar(
        title: Text('Sync Queue', style: SentraTypography.h3),
        actions: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Center(child: SyncStatusIndicator()),
          ),
          IconButton(
            tooltip: 'Clear history',
            icon: const Icon(LucideIcons.trash2, size: 20),
            onPressed: () {
              // Implementation to clear history
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(SentraSpacing.m),
            child: SentraTextField(
              label: 'Search Tasks',
              hintText: 'Search payload or ID...',
              onChanged: updateSearch,
            ),
          ),
          SizedBox(
            height: 44.0.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: SentraSpacing.m),
              children: [
                _buildChip(null, 'All'),
                ...UploadState.values.map(
                  (s) => _buildChip(s, s.name.toUpperCase()),
                ),
              ],
            ),
          ),
          const SizedBox(height: SentraSpacing.s),
          Expanded(
            child: state.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (tasks) {
                final filtered = applyFilters(tasks);
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          LucideIcons.checkCircle,
                          color: SentraColors.success,
                          size: 48,
                        ),
                        const SizedBox(height: SentraSpacing.m),
                        Text('Sync Complete', style: SentraTypography.h3),
                        Text(
                          'All pending changes uploaded.',
                          style: SentraTypography.bodySmall,
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(SentraSpacing.m),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _buildCard(filtered[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(UploadState? state, String label) {
    final isActive = statusFilter == state;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isActive,
        onSelected: (_) => updateFilter(state),
        selectedColor: SentraColors.primary700,
        labelStyle: SentraTypography.label.copyWith(
          color: isActive ? Colors.white : SentraColors.gray700,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildCard(UploadTask task) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SentraSpacing.m),
      child: SentraCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  task.id,
                  style: SentraTypography.label.copyWith(
                    color: SentraColors.gray500,
                    fontSize: 10,
                  ),
                ),
                SentraBadge(
                  label: task.state.name,
                  type: _getBadgeType(task.state),
                ),
              ],
            ),
            const SizedBox(height: SentraSpacing.s),
            Text(
              task.localPayloadPath,
              style: SentraTypography.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            if (task.state == UploadState.inProgress)
              LinearProgressIndicator(
                color: SentraColors.primary500,
                backgroundColor: SentraColors.primary100,
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  LucideIcons.clock,
                  size: 12,
                  color: SentraColors.gray500,
                ),
                const SizedBox(width: 4),
                Text(
                  formatDate(task.queuedAt),
                  style: SentraTypography.bodySmall,
                ),
                const Spacer(),
                if (task.errorMessage != null)
                  const Icon(
                    LucideIcons.alertCircle,
                    size: 14,
                    color: SentraColors.error,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  SentraBadgeType _getBadgeType(UploadState state) {
    switch (state) {
      case UploadState.success:
        return SentraBadgeType.success;
      case UploadState.pending:
        return SentraBadgeType.warning;
      case UploadState.failed:
        return SentraBadgeType.error;
      case UploadState.inProgress:
        return SentraBadgeType.info;
    }
  }
}
