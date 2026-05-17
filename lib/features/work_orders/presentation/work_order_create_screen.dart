import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentra_ui/sentra_ui.dart';
import '../domain/work_order.dart';
import 'work_orders_view_model.dart';

@RoutePage()
class WorkOrderCreateScreen extends ConsumerStatefulWidget {
  const WorkOrderCreateScreen({super.key});
  @override
  ConsumerState<WorkOrderCreateScreen> createState() =>
      _WorkOrderCreateScreenState();
}

class _WorkOrderCreateScreenState extends ConsumerState<WorkOrderCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _assetCtrl = TextEditingController();
  var _priority = WorkOrderPriority.medium;
  final _date = DateTime.now().add(const Duration(hours: 2));

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
          backgroundColor: SentraColors.success,
        ),
      );
      context.router.maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New Work Order', style: SentraTypography.h3)),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(SentraSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SentraTextField(
                label: 'Work Title',
                hintText: 'e.g. HVAC Compressor Inspection',
                controller: _titleCtrl,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Title required' : null,
              ),
              const SizedBox(height: SentraSpacing.m),
              SentraTextField(
                label: 'Problem Description',
                hintText: 'Describe the work to be done...',
                controller: _descCtrl,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Description required'
                    : null,
              ),
              const SizedBox(height: SentraSpacing.m),
              SentraTextField(
                label: 'Asset ID (Optional)',
                hintText: 'e.g. AST-1002',
                controller: _assetCtrl,
              ),
              const SizedBox(height: SentraSpacing.m),
              Text('Priority Level', style: SentraTypography.label),
              const SizedBox(height: SentraSpacing.s),
              Wrap(
                spacing: SentraSpacing.s,
                children: WorkOrderPriority.values.map((p) {
                  final isSelected = _priority == p;
                  return ChoiceChip(
                    label: Text(p.name.toUpperCase()),
                    selected: isSelected,
                    onSelected: (val) => setState(() => _priority = p),
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
                  label: 'Create Work Order',
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
