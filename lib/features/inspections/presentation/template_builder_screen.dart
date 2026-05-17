import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mix/mix.dart';
import '../../../core/theme/sentra_styles.dart';
import '../../../core/theme/sentra_tokens.dart';
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
      id: 'TMPL-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      templateName: _nameCtrl.text.trim(),
      workOrderId: 'TEMPLATE', // Special marker
      inspectorName: inspectorName,
      createdAt: DateTime.now(),
      status: InspectionStatus.draft,
      items: _itemCtrls
          .asMap()
          .entries
          .map(
            (e) => InspectionItem(
              id: 'TI-${DateTime.now().microsecondsSinceEpoch}-${e.key}',
              question: e.value.text.trim(),
              isPass: true,
              sortOrder: e.key,
            ),
          )
          .toList(),
    );

    await ref.read(inspectionsViewModelProvider.notifier).submit(template);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Template saved successfully'),
          backgroundColor: kPositive,
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
          'Template Builder',
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
              Text(
                'Template Name',
                style: TextStyle(
                  color: kTextSecondary,
                  fontSize: 13.0.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.0.h),
              TextFormField(
                controller: _nameCtrl,
                style: TextStyle(color: kTextPrimary, fontSize: 14.0.sp),
                decoration: sentraSearchDecoration(
                  hint: 'e.g. Daily Forklift Inspection',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              SizedBox(height: 24.0.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Checklist Items',
                    style: TextStyle(
                      color: kTextSecondary,
                      fontSize: 13.0.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: _addItem,
                    child: Row(
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          color: kBrand,
                          size: 18.0.sp,
                        ),
                        SizedBox(width: 4.0.w),
                        Text(
                          'Add Item',
                          style: TextStyle(
                            color: kBrand,
                            fontSize: 12.0.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.0.h),
              ...List.generate(_itemCtrls.length, _buildChecklistItem),
              SizedBox(height: 32.0.h),
              SizedBox(
                width: double.infinity,
                child: Box(
                  style: $primaryButton(),
                  child: GestureDetector(
                    onTap: _submit,
                    child: Text(
                      'Save Template',
                      style: TextStyle(
                        color: kSurface,
                        fontSize: 15.0.sp,
                        fontWeight: FontWeight.w700,
                      ),
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

  Widget _buildChecklistItem(int index) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.0.h),
      child: Box(
        style: $card().padding(.all(14)),
        child: Row(
          children: [
            Icon(Icons.drag_indicator, color: kTextMuted, size: 20.0.sp),
            SizedBox(width: 12.0.w),
            Expanded(
              child: TextFormField(
                controller: _itemCtrls[index],
                style: TextStyle(color: kTextPrimary, fontSize: 13.0.sp),
                decoration: InputDecoration(
                  hintText: 'Check item ${index + 1}...',
                  hintStyle: TextStyle(color: kTextMuted, fontSize: 13.0.sp),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
            ),
            if (_itemCtrls.length > 1)
              GestureDetector(
                onTap: () => _removeItem(index),
                child: Icon(
                  Icons.remove_circle_outline,
                  color: kCritical,
                  size: 20.0.sp,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
