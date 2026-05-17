import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mix/mix.dart';
import '../../../core/mixins/status_color_mixin.dart';
import '../../../core/theme/sentra_styles.dart';
import '../../../core/theme/sentra_tokens.dart';
import '../domain/work_order.dart';
import 'work_orders_view_model.dart';

@RoutePage()
class WorkOrderCreateScreen extends ConsumerStatefulWidget {
  const WorkOrderCreateScreen({super.key});
  @override
  ConsumerState<WorkOrderCreateScreen> createState() =>
      _WorkOrderCreateScreenState();
}

class _WorkOrderCreateScreenState extends ConsumerState<WorkOrderCreateScreen>
    with StatusColorMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _assetCtrl = TextEditingController();
  var _priority = WorkOrderPriority.medium;
  var _date = DateTime.now().add(const Duration(hours: 2));

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _assetCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final wo = WorkOrder(
      id: 'WO-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      status: WorkOrderStatus.open,
      priority: _priority,
      scheduledDate: _date,
      createdAt: DateTime.now(),
      assetId: _assetCtrl.text.trim().isEmpty ? null : _assetCtrl.text.trim(),
    );
    await ref.read(workOrdersViewModelProvider.notifier).create(wo);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Work order ${wo.id} created'),
          backgroundColor: kSuccess,
        ),
      );
      context.router.maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      appBar: AppBar(
        backgroundColor: kSurface,
        title: Text(
          'New Work Order',
          style: TextStyle(fontSize: 18.0.sp, fontWeight: FontWeight.w700),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildField(
                'Title',
                TextFormField(
                  controller: _titleCtrl,
                  style: TextStyle(color: kTextPrimary, fontSize: 14.0.sp),
                  decoration: _fd('e.g. HVAC Compressor Inspection'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Title required' : null,
                ),
              ),
              SizedBox(height: 20.0.h),
              _buildField(
                'Description',
                TextFormField(
                  controller: _descCtrl,
                  style: TextStyle(color: kTextPrimary, fontSize: 14.0.sp),
                  maxLines: 4,
                  decoration: _fd('Describe the work...'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
              ),
              SizedBox(height: 20.0.h),
              _buildField(
                'Priority',
                Box(
                  style: $card().padding(.all(4)),
                  child: Row(
                    children: WorkOrderPriority.values.map((p) {
                      final sel = p == _priority;
                      final c = getStatusColor(p);
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _priority = p),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 10.0.h),
                            decoration: BoxDecoration(
                              color: sel
                                  ? c.withValues(alpha: 0.2)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8.0.r),
                            ),
                            child: Center(
                              child: Text(
                                p.name.toUpperCase(),
                                style: TextStyle(
                                  color: sel ? c : kTextMuted,
                                  fontSize: 11.0.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(height: 20.0.h),
              _buildField(
                'Scheduled Date & Time',
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null && context.mounted) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_date),
                      );
                      if (time != null) {
                        setState(() {
                          _date = DateTime(
                            picked.year,
                            picked.month,
                            picked.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    }
                  },
                  child: Box(
                    style: $card().padding(.horizontal(16).vertical(14)),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: kAccent,
                          size: 18.0.sp,
                        ),
                        SizedBox(width: 12.0.w),
                        Text(
                          '${_date.day}/${_date.month}/${_date.year}  ${_date.hour}:${_date.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: kTextPrimary,
                            fontSize: 14.0.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.0.h),
              _buildField(
                'Asset ID (optional)',
                TextFormField(
                  controller: _assetCtrl,
                  style: TextStyle(color: kTextPrimary, fontSize: 14.0.sp),
                  decoration: _fd('e.g. AST-502'),
                ),
              ),
              SizedBox(height: 32.0.h),
              SizedBox(
                width: double.infinity,
                height: 48.0.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0.r),
                    ),
                  ),
                  onPressed: _submit,
                  child: Text(
                    'Create Work Order',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.0.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, Widget child) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          color: kTextSecondary,
          fontSize: 13.0.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      SizedBox(height: 8.0.h),
      child,
    ],
  );

  InputDecoration _fd(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: kTextMuted, fontSize: 14.0.sp),
    filled: true,
    fillColor: kSurfaceMuted,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0.r),
      borderSide: const BorderSide(color: kBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0.r),
      borderSide: const BorderSide(color: kBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0.r),
      borderSide: const BorderSide(color: kAccent, width: 1.5),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 14.0.h),
  );
}
