import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentra_ui/sentra_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/storage/database.dart';
import '../../../core/storage/database_providers.dart';
import 'package:sentra/routes/app_router.dart';

@RoutePage()
class ConflictListScreen extends ConsumerWidget {
  const ConflictListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conflictsAsync = ref.watch(unresolvedConflictsProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Data Conflicts', style: SentraTypography.h3)),
      body: conflictsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (conflictsList) {
          final conflicts = conflictsList.cast<ConflictEntry>();
          if (conflicts.isEmpty) {
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
                  Text('No pending conflicts', style: SentraTypography.h3),
                  Text(
                    'All local data is in sync.',
                    style: SentraTypography.bodySmall,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(SentraSpacing.m),
            itemCount: conflicts.length,
            itemBuilder: (context, index) {
              final conflict = conflicts[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: SentraSpacing.m),
                child: SentraCard(
                  onTap: () => context.router.push(
                    ConflictResolutionRoute(conflict: conflict),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: SentraColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          LucideIcons.refreshCcw,
                          color: SentraColors.error,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: SentraSpacing.m),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${conflict.entityType.toUpperCase()}: ${conflict.id}',
                              style: SentraTypography.label,
                            ),
                            Text(
                              'Conflict by ${conflict.conflictingUserName ?? "Unknown"}',
                              style: SentraTypography.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        LucideIcons.chevronRight,
                        size: 16,
                        color: SentraColors.gray500,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
