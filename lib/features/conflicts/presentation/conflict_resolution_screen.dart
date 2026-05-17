import 'dart:convert';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentra_ui/sentra_ui.dart';

import '../../../core/storage/database.dart';
import 'conflicts_view_model.dart';

@RoutePage()
class ConflictResolutionScreen extends ConsumerStatefulWidget {
  final ConflictEntry conflict;

  const ConflictResolutionScreen({super.key, required this.conflict});

  @override
  ConsumerState<ConflictResolutionScreen> createState() =>
      _ConflictResolutionScreenState();
}

class _ConflictResolutionScreenState
    extends ConsumerState<ConflictResolutionScreen> {
  late Map<String, dynamic> _localData;
  late Map<String, dynamic> _remoteData;
  bool _isResolving = false;

  @override
  void initState() {
    super.initState();
    _localData = jsonDecode(widget.conflict.localData);
    _remoteData = jsonDecode(widget.conflict.remoteData);
  }

  Future<void> _resolve(bool useLocal) async {
    setState(() => _isResolving = true);
    try {
      final vm = ref.read(conflictsViewModelProvider.notifier);
      if (useLocal) {
        await vm.resolveWithLocal(
          widget.conflict.id,
          widget.conflict.entityType,
        );
      } else {
        await vm.resolveWithRemote(
          widget.conflict.id,
          widget.conflict.entityType,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Conflict resolved using ${useLocal ? "Local" : "Remote"} data',
            ),
            backgroundColor: SentraColors.success,
          ),
        );
        context.router.back();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: SentraColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isResolving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resolve Conflict', style: SentraTypography.h3),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(SentraSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose which version to keep for ${widget.conflict.entityType} ${widget.conflict.id}.',
                  style: SentraTypography.bodyMedium,
                ),
                const SizedBox(height: SentraSpacing.l),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _DataColumn(
                        title: 'Local Version',
                        data: _localData,
                        isLocal: true,
                        onSelect: () => _resolve(true),
                      ),
                    ),
                    const SizedBox(width: SentraSpacing.m),
                    Expanded(
                      child: _DataColumn(
                        title: 'Remote Version',
                        data: _remoteData,
                        isLocal: false,
                        onSelect: () => _resolve(false),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_isResolving)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

class _DataColumn extends StatelessWidget {
  final String title;
  final Map<String, dynamic> data;
  final bool isLocal;
  final VoidCallback onSelect;

  const _DataColumn({
    required this.title,
    required this.data,
    required this.isLocal,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: SentraTypography.label),
        const SizedBox(height: SentraSpacing.s),
        SentraCard(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.entries.take(10).map((e) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.key.toUpperCase(),
                      style: SentraTypography.label.copyWith(
                        fontSize: 8,
                        color: SentraColors.gray500,
                      ),
                    ),
                    Text(
                      e.value.toString(),
                      style: SentraTypography.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: SentraSpacing.m),
        SentraButton(
          label: 'Use This',
          onPressed: onSelect,
          isPrimary: isLocal,
        ),
      ],
    );
  }
}
