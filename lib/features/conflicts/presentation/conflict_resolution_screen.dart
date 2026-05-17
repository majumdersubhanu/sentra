import 'dart:convert';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mix/mix.dart';

import '../../../core/storage/database.dart';
import '../../../core/theme/sentra_styles.dart';
import '../../../core/theme/sentra_tokens.dart';
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
            backgroundColor: kSuccess,
          ),
        );
        context.router.back();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: kDanger),
        );
      }
    } finally {
      if (mounted) setState(() => _isResolving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      appBar: AppBar(
        title: Text('Resolve Conflict', style: TextStyle(fontSize: 18.0.sp)),
        backgroundColor: kSurface,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16.0.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A conflict was detected for ${widget.conflict.entityType} ${widget.conflict.id}. Please choose which version to keep.',
                  style: TextStyle(color: kTextSecondary, fontSize: 14.0.sp),
                ),
                SizedBox(height: 24.0.h),
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
                    SizedBox(width: 16.0.w),
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
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, color: kTextPrimary),
        ),
        SizedBox(height: 12.0.h),
        Box(
          style: $sectionCard().paddingAll(12.0.w).color(kSurface),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.entries.map((e) {
              return Padding(
                padding: EdgeInsets.only(bottom: 8.0.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.key.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10.0.sp,
                        color: kTextMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      e.value.toString(),
                      style: TextStyle(fontSize: 12.0.sp, color: kTextPrimary),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 16.0.h),
        PressableBox(
          onPress: onSelect,
          style: BoxStyler()
              .paddingAll(10.0.w)
              .borderRadius(.circular(8.0.r))
              .color(isLocal ? kAccent : kInfo),
          child: StyledText(
            'Use This Version',
            style: TextStyler()
                .color(Colors.white)
                .fontWeight(FontWeight.bold)
                .textAlign(TextAlign.center),
          ),
        ),
      ],
    );
  }
}
