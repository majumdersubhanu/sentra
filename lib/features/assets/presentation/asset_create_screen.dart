import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentra_ui/sentra_ui.dart';
import 'package:uuid/uuid.dart';

import '../../../core/di/injection.dart';
import '../application/asset_coordinator.dart';
import '../domain/asset.dart';

@RoutePage()
class AssetCreateScreen extends ConsumerStatefulWidget {
  const AssetCreateScreen({super.key});

  @override
  ConsumerState<AssetCreateScreen> createState() => _AssetCreateScreenState();
}

class _AssetCreateScreenState extends ConsumerState<AssetCreateScreen> {
  late AssetCoordinator _coordinator;
  final _nameController = TextEditingController();
  final _modelController = TextEditingController();
  final _serialController = TextEditingController();
  final _locationController = TextEditingController();

  AssetOperationalStatus _selectedStatus = AssetOperationalStatus.online;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _coordinator = getIt<AssetCoordinator>();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _modelController.dispose();
    _serialController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _createAsset() async {
    if (_nameController.text.isEmpty) {
      setState(() => _error = 'Asset name is required');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final asset = Asset(
      id: 'AST-${const Uuid().v4().substring(0, 8).toUpperCase()}',
      name: _nameController.text,
      modelNumber: _modelController.text,
      serialNumber: _serialController.text,
      locationCoordinates: _locationController.text,
      status: _selectedStatus,
      lastServicedDate: DateTime.now(),
      createdAt: DateTime.now(),
    );

    final result = await _coordinator.createAsset(asset);

    if (mounted) {
      setState(() => _isLoading = false);
      result.fold(
        (failure) => setState(() => _error = failure.message),
        (_) => context.router.pop(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New Asset', style: SentraTypography.h3)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(SentraSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(SentraSpacing.s),
                margin: const EdgeInsets.only(bottom: SentraSpacing.m),
                decoration: BoxDecoration(
                  color: SentraColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _error!,
                  style: SentraTypography.bodySmall.copyWith(
                    color: SentraColors.error,
                  ),
                ),
              ),
            SentraTextField(
              label: 'Asset Name',
              hintText: 'e.g. Compressor 01',
              controller: _nameController,
            ),
            const SizedBox(height: SentraSpacing.m),
            Row(
              children: [
                Expanded(
                  child: SentraTextField(
                    label: 'Model #',
                    controller: _modelController,
                  ),
                ),
                const SizedBox(width: SentraSpacing.m),
                Expanded(
                  child: SentraTextField(
                    label: 'Serial #',
                    controller: _serialController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: SentraSpacing.m),
            SentraTextField(
              label: 'Location / Coordinates',
              hintText: 'e.g. Site A, Zone 2',
              controller: _locationController,
            ),
            const SizedBox(height: SentraSpacing.m),
            Text('Initial Status', style: SentraTypography.label),
            const SizedBox(height: SentraSpacing.s),
            Wrap(
              spacing: SentraSpacing.s,
              children: AssetOperationalStatus.values.map((status) {
                final isSelected = _selectedStatus == status;
                return ChoiceChip(
                  label: Text(status.name.toUpperCase()),
                  selected: isSelected,
                  onSelected: (val) => setState(() => _selectedStatus = status),
                  selectedColor: SentraColors.primary100,
                  labelStyle: SentraTypography.label.copyWith(
                    fontSize: 10,
                    color: isSelected
                        ? SentraColors.primary700
                        : SentraColors.gray500,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: SentraSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: SentraButton(
                label: _isLoading ? 'Creating...' : 'Register Asset',
                onPressed: _isLoading ? null : _createAsset,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
