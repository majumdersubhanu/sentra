import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentra_ui/sentra_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../domain/work_order.dart';
import 'widgets/work_order_comments_section.dart';
import 'work_orders_view_model.dart';
import '../application/work_order_pdf_service.dart';
import '../../uploads/presentation/widgets/attachment_picker.dart';
import '../../uploads/presentation/widgets/attachment_gallery.dart';
import '../../uploads/presentation/attachments_provider.dart';

@RoutePage()
class WorkOrderDetailScreen extends ConsumerWidget {
  final String workOrderId;

  const WorkOrderDetailScreen({
    super.key,
    @PathParam('id') required this.workOrderId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workOrderByIdProvider(workOrderId));

    return state.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
      data: (wo) {
        if (wo == null)
          return const Scaffold(body: Center(child: Text('Not found')));

        return Scaffold(
          appBar: AppBar(
            title: Text(wo.id, style: SentraTypography.h3),
            actions: [
              IconButton(
                icon: const Icon(LucideIcons.fileDown),
                onPressed: () => WorkOrderPdfService.generateAndPrint(wo),
              ),
              IconButton(
                icon: const Icon(LucideIcons.refreshCw),
                onPressed: () =>
                    ref.invalidate(workOrderByIdProvider(workOrderId)),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(SentraSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Card
                _buildHeaderCard(wo),
                const SizedBox(height: SentraSpacing.m),

                // 2. Info Grid
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildLocationCard(wo)),
                    const SizedBox(width: SentraSpacing.m),
                    Expanded(child: _buildScheduleCard(wo)),
                  ],
                ),
                const SizedBox(height: SentraSpacing.m),

                // 3. Safety Card
                _buildSafetyCard(wo),
                const SizedBox(height: SentraSpacing.m),

                // 4. Description
                SentraCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Problem Description'),
                      const SizedBox(height: SentraSpacing.s),
                      Text(wo.description, style: SentraTypography.bodyMedium),
                    ],
                  ),
                ),
                const SizedBox(height: SentraSpacing.m),

                // 5. Attachments
                _buildAttachmentsSection(context, ref, wo),
                const SizedBox(height: SentraSpacing.m),

                // 6. Comments
                WorkOrderCommentsSection(workOrderId: workOrderId),
                const SizedBox(height: SentraSpacing.xxl),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomActions(wo),
        );
      },
    );
  }

  Widget _buildHeaderCard(WorkOrder wo) {
    return SentraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(wo.title, style: SentraTypography.h2)),
              SentraBadge(
                label: wo.status.name,
                type: _getBadgeType(wo.status),
              ),
            ],
          ),
          const SizedBox(height: SentraSpacing.s),
          Row(
            children: [
              const Icon(
                LucideIcons.tag,
                size: 14,
                color: SentraColors.gray500,
              ),
              const SizedBox(width: 4),
              Text(
                wo.workType?.name ?? 'General Work',
                style: SentraTypography.bodySmall,
              ),
              const SizedBox(width: 16),
              const Icon(
                LucideIcons.alertCircle,
                size: 14,
                color: SentraColors.gray500,
              ),
              const SizedBox(width: 4),
              Text(
                'Priority: ${wo.priority.name}',
                style: SentraTypography.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(WorkOrder wo) {
    return SentraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Site Info'),
          const SizedBox(height: SentraSpacing.s),
          _infoItem(LucideIcons.mapPin, wo.siteLocation ?? 'No location'),
          _infoItem(LucideIcons.building, wo.businessUnit ?? 'No unit'),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(WorkOrder wo) {
    return SentraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Schedule'),
          const SizedBox(height: SentraSpacing.s),
          _infoItem(
            LucideIcons.calendar,
            wo.scheduledStart?.toString().split(' ')[0] ?? 'Not set',
          ),
          _infoItem(
            LucideIcons.clock,
            'SLA: ${wo.slaTarget?.toString().split(' ')[1].substring(0, 5) ?? 'N/A'}',
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyCard(WorkOrder wo) {
    return SentraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Safety Management'),
          const SizedBox(height: SentraSpacing.s),
          Wrap(
            spacing: SentraSpacing.s,
            runSpacing: SentraSpacing.s,
            children: [
              _safetyChip('Permit', wo.permitRequirement),
              _safetyChip('Confined Space', wo.confinedSpaceEntry),
              _safetyChip('Hot Work', wo.hotWorkRequired),
              _safetyChip('LOTO', wo.lockoutTagoutRequired),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentsSection(
    BuildContext context,
    WidgetRef ref,
    WorkOrder wo,
  ) {
    return SentraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionTitle('Attachments'),
              IconButton(
                icon: const Icon(
                  LucideIcons.plus,
                  color: SentraColors.primary500,
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => Padding(
                      padding: const EdgeInsets.all(SentraSpacing.m),
                      child: AttachmentPicker(
                        entityId: wo.id,
                        entityType: 'work_order',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          ref
              .watch(attachmentsProvider(wo.id))
              .when(
                data: (attachments) =>
                    AttachmentGallery(attachments: attachments),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Failed to load attachments'),
              ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(WorkOrder wo) {
    return Container(
      padding: const EdgeInsets.all(SentraSpacing.m),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: SentraColors.gray200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SentraButton(
              label: 'Update Status',
              onPressed: () {},
              isPrimary: false,
            ),
          ),
          const SizedBox(width: SentraSpacing.m),
          Expanded(
            child: SentraButton(label: 'Start Work', onPressed: () {}),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: SentraTypography.label.copyWith(color: SentraColors.gray500),
    );
  }

  Widget _infoItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: SentraColors.gray500),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: SentraTypography.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _safetyChip(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: active
            ? SentraColors.error.withOpacity(0.1)
            : SentraColors.gray100,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: active ? SentraColors.error : SentraColors.gray200,
        ),
      ),
      child: Text(
        label,
        style: SentraTypography.label.copyWith(
          fontSize: 10,
          color: active ? SentraColors.error : SentraColors.gray500,
        ),
      ),
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
}
