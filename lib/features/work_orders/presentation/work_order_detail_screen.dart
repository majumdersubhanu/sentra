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
import '../../auth/presentation/auth_view_model.dart';
import 'package:fpdart/fpdart.dart';

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
          appBar: _DetailAppBar(workOrderId: workOrderId, wo: wo),
          body: _DetailBody(workOrderId: workOrderId, wo: wo),
          bottomNavigationBar: _DetailBottomActions(wo: wo),
        );
      },
    );
  }
}

class _DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String workOrderId;
  final WorkOrder wo;
  const _DetailAppBar({required this.workOrderId, required this.wo});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(wo.id, style: SentraTypography.h3),
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.fileDown),
          onPressed: () => WorkOrderPdfService.generateAndPrint(wo),
        ),
        Consumer(
          builder: (context, ref, _) {
            return IconButton(
              icon: const Icon(LucideIcons.refreshCw),
              onPressed: () =>
                  ref.invalidate(workOrderByIdProvider(workOrderId)),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _DetailBody extends ConsumerWidget {
  final String workOrderId;
  final WorkOrder wo;
  const _DetailBody({required this.workOrderId, required this.wo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(SentraSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderCard(wo: wo),
          const SizedBox(height: SentraSpacing.m),
          _InfoGrid(wo: wo),
          const SizedBox(height: SentraSpacing.m),
          _SafetyCard(wo: wo),
          const SizedBox(height: SentraSpacing.m),
          _DescriptionCard(description: wo.description),
          const SizedBox(height: SentraSpacing.m),
          _AttachmentsSection(wo: wo),
          const SizedBox(height: SentraSpacing.m),
          WorkOrderCommentsSection(workOrderId: workOrderId),
          const SizedBox(height: SentraSpacing.xxl),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final WorkOrder wo;
  const _HeaderCard({required this.wo});

  @override
  Widget build(BuildContext context) {
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
              _MetaItem(
                icon: LucideIcons.tag,
                text: wo.workType?.name ?? 'General Work',
              ),
              const SizedBox(width: 16),
              _MetaItem(
                icon: LucideIcons.alertCircle,
                text: 'Priority: ${wo.priority.name}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MetaItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: SentraColors.gray500),
        const SizedBox(width: 4),
        Text(text, style: SentraTypography.bodySmall),
      ],
    );
  }
}

class _InfoGrid extends StatelessWidget {
  final WorkOrder wo;
  const _InfoGrid({required this.wo});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _InfoCard(
            title: 'Site Info',
            items: [
              _InfoItem(
                icon: LucideIcons.mapPin,
                text: wo.siteLocation ?? 'No location',
              ),
              _InfoItem(
                icon: LucideIcons.building,
                text: wo.businessUnit ?? 'No unit',
              ),
            ],
          ),
        ),
        const SizedBox(width: SentraSpacing.m),
        Expanded(
          child: _InfoCard(
            title: 'Schedule',
            items: [
              _InfoItem(
                icon: LucideIcons.calendar,
                text: wo.scheduledStart?.toString().split(' ')[0] ?? 'Not set',
              ),
              _InfoItem(
                icon: LucideIcons.clock,
                text:
                    'SLA: ${wo.slaTarget?.toString().split(' ')[1].substring(0, 5) ?? 'N/A'}',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> items;
  const _InfoCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return SentraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: title),
          const SizedBox(height: SentraSpacing.s),
          ...items,
        ],
      ),
    );
  }
}

class _SafetyCard extends StatelessWidget {
  final WorkOrder wo;
  const _SafetyCard({required this.wo});

  @override
  Widget build(BuildContext context) {
    return SentraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'Safety Management'),
          const SizedBox(height: SentraSpacing.s),
          Wrap(
            spacing: SentraSpacing.s,
            runSpacing: SentraSpacing.s,
            children: [
              _SafetyChip(label: 'Permit', active: wo.permitRequirement),
              _SafetyChip(
                label: 'Confined Space',
                active: wo.confinedSpaceEntry,
              ),
              _SafetyChip(label: 'Hot Work', active: wo.hotWorkRequired),
              _SafetyChip(label: 'LOTO', active: wo.lockoutTagoutRequired),
            ],
          ),
        ],
      ),
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  final String description;
  const _DescriptionCard({required this.description});

  @override
  Widget build(BuildContext context) {
    return SentraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'Problem Description'),
          const SizedBox(height: SentraSpacing.s),
          Text(description, style: SentraTypography.bodyMedium),
        ],
      ),
    );
  }
}

class _AttachmentsSection extends ConsumerWidget {
  final WorkOrder wo;
  const _AttachmentsSection({required this.wo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SentraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _SectionTitle(title: 'Attachments'),
              IconButton(
                icon: const Icon(
                  LucideIcons.plus,
                  color: SentraColors.primary500,
                ),
                onPressed: () => _pickAttachment(context),
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

  void _pickAttachment(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(SentraSpacing.m),
        child: AttachmentPicker(entityId: wo.id, entityType: 'work_order'),
      ),
    );
  }
}

class _DetailBottomActions extends ConsumerWidget {
  final WorkOrder wo;
  const _DetailBottomActions({required this.wo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProfileProvider);
    final canAssign = user?.role.isSupervisorOrAbove ?? false;

    return Container(
      padding: const EdgeInsets.all(SentraSpacing.m),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: SentraColors.gray200)),
      ),
      child: Row(
        children: [
          if (canAssign) ...[
            Expanded(
              child: SentraButton(
                label: 'Assign',
                onPressed: () => _showAssignmentDialog(context, ref, wo),
                isPrimary: false,
                icon: const Icon(
                  LucideIcons.userPlus,
                  size: 16,
                  color: SentraColors.primary700,
                ),
              ),
            ),
            const SizedBox(width: SentraSpacing.m),
          ],
          Expanded(
            child: SentraButton(
              label: wo.status == WorkOrderStatus.inProgress
                  ? 'Complete'
                  : 'Start Work',
              onPressed: () {
                final newStatus = wo.status == WorkOrderStatus.inProgress
                    ? WorkOrderStatus.completed
                    : WorkOrderStatus.inProgress;
                ref
                    .read(workOrdersViewModelProvider.notifier)
                    .updateStatus(wo, newStatus);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAssignmentDialog(
    BuildContext context,
    WidgetRef ref,
    WorkOrder wo,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(SentraSpacing.m),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Assign Technician', style: SentraTypography.h3),
            const SizedBox(height: SentraSpacing.m),
            ListTile(
              leading: const CircleAvatar(child: Text('JD')),
              title: const Text('John Doe'),
              onTap: () {
                ref.read(workOrdersViewModelProvider.notifier).mutate(() async {
                  return const Right(unit);
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: SentraTypography.label.copyWith(color: SentraColors.gray500),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
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
}

class _SafetyChip extends StatelessWidget {
  final String label;
  final bool active;
  const _SafetyChip({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: active
            ? SentraColors.error.withValues(alpha: 0.1)
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
