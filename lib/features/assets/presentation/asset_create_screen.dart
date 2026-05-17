import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:uuid/uuid.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/sentra_styles.dart';
import '../../../core/theme/sentra_tokens.dart';
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

    try {
      final asset = Asset(
        id: const Uuid().v4(),
        name: _nameController.text,
        modelNumber: _modelController.text,
        serialNumber: _serialController.text,
        locationCoordinates: _locationController.text,
        status: _selectedStatus,
        lastServicedDate: DateTime.now(),
        createdAt: DateTime.now(),
      );

      final result = await _coordinator.createAsset(asset);

      result.fold(
        (failure) {
          setState(() {
            _error = 'Failed to create asset: $failure';
            _isLoading = false;
          });
        },
        (_) {
          if (mounted) {
            context.router.pop();
          }
        },
      );
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      appBar: AppBar(
        title: Text(
          'Create Asset',
          style: TextStyle(fontSize: 18.0.sp, fontWeight: FontWeight.w700),
        ),
        backgroundColor: kSurface,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Error message
            if (_error != null) ...[
              Container(
                padding: EdgeInsets.all(12.0.w),
                decoration: BoxDecoration(
                  color: kCritical.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kCritical.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.alertCircle, color: kCritical, size: 20.0.sp),
                    SizedBox(width: 12.0.w),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: kCritical, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0.h),
            ],

            // Asset Name
            FormSection(
              label: 'Asset Name',
              required: true,
              child: TextFormField(
                controller: _nameController,
                decoration: sentraFieldDecoration(
                  label: 'Name',
                  hint: 'e.g., Industrial Pump Unit',
                ),
                enabled: !_isLoading,
              ),
            ),
            SizedBox(height: 16.0.h),

            // Model Number
            FormSection(
              label: 'Model Number',
              child: TextFormField(
                controller: _modelController,
                decoration: sentraFieldDecoration(
                  label: 'Model',
                  hint: 'e.g., IPU-2000X',
                ),
                enabled: !_isLoading,
              ),
            ),
            SizedBox(height: 16.0.h),

            // Serial Number
            FormSection(
              label: 'Serial Number',
              child: TextFormField(
                controller: _serialController,
                decoration: sentraFieldDecoration(
                  label: 'Serial',
                  hint: 'e.g., SN-123456-A',
                ),
                enabled: !_isLoading,
              ),
            ),
            SizedBox(height: 16.0.h),

            // Location
            FormSection(
              label: 'Location',
              child: TextFormField(
                controller: _locationController,
                decoration: sentraFieldDecoration(
                  label: 'Location',
                  hint: 'e.g., Building A, Room 201',
                ),
                enabled: !_isLoading,
              ),
            ),
            SizedBox(height: 16.0.h),

            // Status Dropdown
            FormSection(
              label: 'Operational Status',
              child: DropdownButtonFormField<AssetOperationalStatus>(
                initialValue: _selectedStatus,
                decoration: sentraFieldDecoration(
                  label: 'Status',
                ),
                items: AssetOperationalStatus.values
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.name.toUpperCase()),
                        ))
                    .toList(),
                onChanged: _isLoading
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() => _selectedStatus = value);
                        }
                      },
              ),
            ),
            SizedBox(height: 24.0.h),

            // Create Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: sentraPrimaryButtonStyle(),
                onPressed: _isLoading ? null : _createAsset,
                child: _isLoading
                    ? SizedBox(
                        height: 20.0.sp,
                        width: 20.0.sp,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(kTextInverse),
                        ),
                      )
                    : Text(
                        'Create Asset',
                        style: TextStyle(
                          fontSize: 16.0.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 12.0.h),

            // Cancel Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: sentraSecondaryButtonStyle(),
                onPressed: _isLoading ? null : () => context.router.pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16.0.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
