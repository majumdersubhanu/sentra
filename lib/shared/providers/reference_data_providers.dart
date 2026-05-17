import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/assets/presentation/assets_view_model.dart';
import '../../features/auth/presentation/auth_view_model.dart';
import '../../features/inspections/presentation/inspections_view_model.dart';
import '../../features/users/presentation/user_view_model.dart';
import '../../features/work_orders/presentation/work_orders_view_model.dart';

class ReferenceOption {
  final String id;
  final String label;
  final String? subtitle;

  const ReferenceOption({required this.id, required this.label, this.subtitle});
}

final workOrderReferenceOptionsProvider =
    Provider<AsyncValue<List<ReferenceOption>>>((ref) {
      final workOrdersAsync = ref.watch(localWorkOrdersProvider);
      return workOrdersAsync.whenData(
        (workOrders) => workOrders
            .map(
              (wo) => ReferenceOption(
                id: wo.id,
                label: wo.title,
                subtitle: '${wo.id} • ${wo.status.name.toUpperCase()}',
              ),
            )
            .toList(),
      );
    });

final assetReferenceOptionsProvider =
    Provider<AsyncValue<List<ReferenceOption>>>((ref) {
      final assetsAsync = ref.watch(localAssetsProvider);
      return assetsAsync.whenData(
        (assets) => assets
            .map(
              (asset) => ReferenceOption(
                id: asset.id,
                label: asset.name,
                subtitle: '${asset.id} • ${asset.status.name.toUpperCase()}',
              ),
            )
            .toList(),
      );
    });

final technicianReferenceOptionsProvider =
    Provider<AsyncValue<List<ReferenceOption>>>((ref) {
      final techniciansAsync = ref.watch(techniciansProvider);
      final currentUser = ref.watch(currentUserProfileProvider);
      return techniciansAsync.whenData((technicians) {
        final merged = [
          if (currentUser != null &&
              technicians.every((u) => u.id != currentUser.id))
            currentUser,
          ...technicians,
        ];
        return merged
            .map(
              (user) => ReferenceOption(
                id: user.id,
                label: user.fullName,
                subtitle: user.email,
              ),
            )
            .toList();
      });
    });

final templateReferenceOptionsProvider =
    Provider<AsyncValue<List<ReferenceOption>>>((ref) {
      final inspectionsAsync = ref.watch(localInspectionsProvider);
      return inspectionsAsync.whenData((inspections) {
        final templates = inspections.where(
          (inspection) =>
              inspection.workOrderId == 'TEMPLATE' &&
              inspection.templateName.isNotEmpty,
        );
        return templates
            .map(
              (template) => ReferenceOption(
                id: template.id,
                label: template.templateName,
                subtitle: '${template.items.length} checklist item(s)',
              ),
            )
            .toList();
      });
    });
