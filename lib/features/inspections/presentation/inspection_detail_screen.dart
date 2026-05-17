import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentra_ui/sentra_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/mixins/date_format_mixin.dart';
import '../../../core/mixins/status_color_mixin.dart';
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
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
      data: (inspections) {
        final insp = inspections.where((i) => i.id == inspectionId).firstOrNull;
        if (insp == null) {
          return const Scaffold(body: Center(child: Text('Not found')));
        }

        final passed = insp.items.where((i) => i.isPass).length;
        final total = insp.items.length;

        return Scaffold(
          appBar: AppBar(
            title: Text(insp.id, style: SentraTypography.h3),
            actions: [
              if (insp.status == InspectionStatus.draft)
                SentraButton(
                  label: 'Submit',
                  onPressed: () {
                    final submitted = insp.copyWith(
                      status: InspectionStatus.completed,
                    );
                    ref
                        .read(inspectionsViewModelProvider.notifier)
                        .submit(submitted);
                  },
                ),
              const SizedBox(width: SentraSpacing.m),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(SentraSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SentraCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Status',
                            style: SentraTypography.label.copyWith(
                              color: SentraColors.gray500,
                            ),
                          ),
                          SentraBadge(
                            label: insp.status.name,
                            type: _getBadgeType(insp.status),
                          ),
                        ],
                      ),
                      const SizedBox(height: SentraSpacing.m),
                      _infoRow('Work Order', insp.workOrderId),
                      _infoRow('Inspector', insp.inspectorName),
                      _infoRow('Date', formatDate(insp.createdAt)),
                    ],
                  ),
                ),
                const SizedBox(height: SentraSpacing.m),
                Text(
                  'Checklist ($passed/$total Passed)',
                  style: SentraTypography.h3,
                ),
                const SizedBox(height: SentraSpacing.s),
                ...insp.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: SentraSpacing.s),
                    child: SentraCard(
                      child: Row(
                        children: [
                          Icon(
                            item.isPass
                                ? LucideIcons.checkCircle
                                : LucideIcons.xCircle,
                            color: item.isPass
                                ? SentraColors.success
                                : SentraColors.error,
                          ),
                          const SizedBox(width: SentraSpacing.m),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.question,
                                  style: SentraTypography.label,
                                ),
                                if (item.comments != null &&
                                    item.comments!.isNotEmpty)
                                  Text(
                                    item.comments!,
                                    style: SentraTypography.bodySmall,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: SentraTypography.bodySmall.copyWith(
              color: SentraColors.gray500,
            ),
          ),
          Text(value, style: SentraTypography.bodyMedium),
        ],
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
