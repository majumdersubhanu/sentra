import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentra_ui/sentra_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../domain/inspection.dart';
import 'inspections_view_model.dart';
import '../../auth/presentation/auth_view_model.dart';

@RoutePage()
class TemplateBuilderScreen extends ConsumerStatefulWidget {
  const TemplateBuilderScreen({super.key});

  @override
  ConsumerState<TemplateBuilderScreen> createState() =>
      _TemplateBuilderScreenState();
}

class _TemplateBuilderScreenState extends ConsumerState<TemplateBuilderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final List<TextEditingController> _itemCtrls = [TextEditingController()];

  @override
  void dispose() {
    _nameCtrl.dispose();
    for (final ctrl in _itemCtrls) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _addItem() => setState(() => _itemCtrls.add(TextEditingController()));

  void _removeItem(int i) {
    if (_itemCtrls.length <= 1) return;
    setState(() {
      _itemCtrls[i].dispose();
      _itemCtrls.removeAt(i);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final inspectorName =
        ref.read(currentUserProfileProvider)?.fullName ?? 'Admin';

    final template = Inspection(
      id: 'TMP-${DateTime.now().millisecondsSinceEpoch}',
      templateName: _nameCtrl.text.trim(),
      workOrderId: '', // Template has no WO
      inspectorName: inspectorName,
      status: InspectionStatus.draft,
      createdAt: DateTime.now(),
      items: _itemCtrls
          .asMap()
          .entries
          .map(
            (e) => InspectionItem(
              id: '${e.key}',
              question: e.value.text.trim(),
              isPass: true,
            ),
          )
          .toList(),
    );

    await ref.read(inspectionsViewModelProvider.notifier).submit(template);
    if (mounted) context.router.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Template Builder', style: SentraTypography.h3),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(SentraSpacing.m),
          children: [
            SentraTextField(
              label: 'Template Name',
              hintText: 'e.g. Monthly Safety Audit',
              controller: _nameCtrl,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Name required' : null,
            ),
            const SizedBox(height: SentraSpacing.l),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Questions', style: SentraTypography.label),
                TextButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(LucideIcons.plusCircle, size: 16),
                  label: const Text('Add Question'),
                ),
              ],
            ),
            const SizedBox(height: SentraSpacing.s),
            ..._itemCtrls.asMap().entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: SentraSpacing.m),
                child: SentraCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: e.value,
                          decoration: const InputDecoration(
                            hintText: 'Enter question...',
                            border: InputBorder.none,
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _removeItem(e.key),
                        icon: const Icon(
                          LucideIcons.trash2,
                          color: SentraColors.error,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: SentraSpacing.xl),
            SentraButton(label: 'Save Template', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
