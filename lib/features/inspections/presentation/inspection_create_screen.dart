import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mix/mix.dart';

import '../../../core/theme/sentra_styles.dart';
import '../../../core/theme/sentra_tokens.dart';
import '../../../shared/providers/reference_data_providers.dart';
import '../../auth/presentation/auth_view_model.dart';
import '../domain/inspection.dart';
import 'inspections_view_model.dart';

@RoutePage()
class InspectionCreateScreen extends ConsumerStatefulWidget {
  const InspectionCreateScreen({super.key});
  @override
  ConsumerState<InspectionCreateScreen> createState() =>
      _InspectionCreateScreenState();
}

class _InspectionCreateScreenState
    extends ConsumerState<InspectionCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _workOrderSearchCtrl = TextEditingController();
  final List<_ChecklistEntry> _items = [_ChecklistEntry()];

  String? _selectedWorkOrderId;
  String? _selectedInspectorId;
  String? _selectedInspectorName;
  String? _selectedTemplateId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final currentUser = ref.read(currentUserProfileProvider);
      if (currentUser == null || !mounted) return;
      setState(() {
        _selectedInspectorId = currentUser.id;
        _selectedInspectorName = currentUser.fullName;
      });
    });
  }

  @override
  void dispose() {
    _workOrderSearchCtrl.dispose();
    for (final item in _items) {
      item.questionCtrl.dispose();
      item.commentsCtrl.dispose();
    }
    super.dispose();
  }

  void _addItem() => setState(() => _items.add(_ChecklistEntry()));

  void _removeItem(int i) {
    if (_items.length <= 1) return;
    setState(() {
      _items[i].questionCtrl.dispose();
      _items[i].commentsCtrl.dispose();
      _items.removeAt(i);
    });
  }

  void _applyTemplate(Inspection template) {
    for (final item in _items) {
      item.questionCtrl.dispose();
      item.commentsCtrl.dispose();
    }

    final nextItems = template.items.isEmpty
        ? [_ChecklistEntry()]
        : template.items
              .map(
                (item) => _ChecklistEntry(
                  question: item.question,
                  comments: item.comments,
                  isPass: true,
                ),
              )
              .toList();

    setState(() {
      _items
        ..clear()
        ..addAll(nextItems);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedWorkOrderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a work order from suggestions.'),
          backgroundColor: kDanger,
        ),
      );
      return;
    }
    if (_selectedInspectorName == null || _selectedInspectorName!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an inspector.'),
          backgroundColor: kDanger,
        ),
      );
      return;
    }

    final inspection = Inspection(
      id: 'INS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      workOrderId: _selectedWorkOrderId!,
      inspectorName: _selectedInspectorName!,
      createdAt: DateTime.now(),
      status: InspectionStatus.draft,
      submittedBy: _selectedInspectorId,
      templateName: _selectedTemplateId ?? '',
      items: _items
          .asMap()
          .entries
          .map(
            (entry) => InspectionItem(
              id: 'CI-${DateTime.now().microsecondsSinceEpoch}-${entry.key}',
              question: entry.value.questionCtrl.text.trim(),
              isPass: entry.value.isPass,
              comments: entry.value.commentsCtrl.text.trim().isEmpty
                  ? null
                  : entry.value.commentsCtrl.text.trim(),
              sortOrder: entry.key,
            ),
          )
          .toList(),
    );

    await ref.read(inspectionsViewModelProvider.notifier).submit(inspection);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Inspection ${inspection.id} submitted'),
        backgroundColor: kSuccess,
      ),
    );
    context.router.maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final workOrdersAsync = ref.watch(workOrderReferenceOptionsProvider);
    final techniciansAsync = ref.watch(technicianReferenceOptionsProvider);
    final templatesAsync = ref.watch(templateReferenceOptionsProvider);
    final inspectionsAsync = ref.watch(localInspectionsProvider);

    return Scaffold(
      backgroundColor: kSurface,
      appBar: AppBar(
        backgroundColor: kSurface,
        title: Text(
          'New Inspection',
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
                'Work Order',
                workOrdersAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (err, _) => Text(
                    'Failed to load work orders: $err',
                    style: TextStyle(color: kDanger, fontSize: 12.0.sp),
                  ),
                  data: _buildWorkOrderTypeahead,
                ),
              ),
              SizedBox(height: 20.0.h),
              _buildField(
                'Inspector',
                techniciansAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (err, _) => Text(
                    'Failed to load users: $err',
                    style: TextStyle(color: kDanger, fontSize: 12.0.sp),
                  ),
                  data: (technicians) => DropdownButtonFormField<String>(
                    initialValue: _selectedInspectorId,
                    decoration: _fd('Select inspector'),
                    dropdownColor: kSurface,
                    items: technicians
                        .map(
                          (t) => DropdownMenuItem<String>(
                            value: t.id,
                            child: Text(
                              '${t.label} (${t.subtitle ?? t.id})',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      final picked = technicians
                          .where((t) => t.id == value)
                          .firstOrNull;
                      setState(() {
                        _selectedInspectorId = value;
                        _selectedInspectorName = picked?.label;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Inspector is required' : null,
                  ),
                ),
              ),
              SizedBox(height: 20.0.h),
              _buildField(
                'Template (optional)',
                templatesAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (err, _) => Text(
                    'Failed to load templates: $err',
                    style: TextStyle(color: kDanger, fontSize: 12.0.sp),
                  ),
                  data: (templates) => DropdownButtonFormField<String>(
                    initialValue: _selectedTemplateId,
                    decoration: _fd('Choose a template'),
                    dropdownColor: kSurface,
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('No template'),
                      ),
                      ...templates.map(
                        (template) => DropdownMenuItem<String>(
                          value: template.id,
                          child: Text(
                            template.label,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedTemplateId = value);
                      if (value == null) return;
                      final templatesData =
                          inspectionsAsync.asData?.value ?? const [];
                      final selectedTemplate = templatesData
                          .where((insp) => insp.id == value)
                          .firstOrNull;
                      if (selectedTemplate != null) {
                        _applyTemplate(selectedTemplate);
                      }
                    },
                  ),
                ),
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
                          color: kWarning,
                          size: 18.0.sp,
                        ),
                        SizedBox(width: 4.0.w),
                        Text(
                          'Add Item',
                          style: TextStyle(
                            color: kWarning,
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
              ...List.generate(_items.length, _buildChecklistItem),
              SizedBox(height: 32.0.h),
              SizedBox(
                width: double.infinity,
                height: 48.0.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kWarning,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0.r),
                    ),
                  ),
                  onPressed: _submit,
                  child: Text(
                    'Submit Inspection',
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

  Widget _buildWorkOrderTypeahead(List<ReferenceOption> workOrders) {
    if (workOrders.isEmpty) {
      return Text(
        'No work orders available yet.',
        style: TextStyle(color: kTextMuted, fontSize: 12.0.sp),
      );
    }

    return Autocomplete<ReferenceOption>(
      displayStringForOption: (option) => '${option.id} — ${option.label}',
      optionsBuilder: (textEditingValue) {
        final query = textEditingValue.text.trim().toLowerCase();
        if (query.isEmpty) {
          return workOrders.take(8);
        }
        return workOrders.where((option) {
          final label = option.label.toLowerCase();
          final subtitle = option.subtitle?.toLowerCase() ?? '';
          return option.id.toLowerCase().contains(query) ||
              label.contains(query) ||
              subtitle.contains(query);
        });
      },
      onSelected: (selection) {
        setState(() {
          _selectedWorkOrderId = selection.id;
          _workOrderSearchCtrl.text = '${selection.id} — ${selection.label}';
        });
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        if (controller.text != _workOrderSearchCtrl.text) {
          controller.text = _workOrderSearchCtrl.text;
          controller.selection = TextSelection.fromPosition(
            TextPosition(offset: controller.text.length),
          );
        }
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          style: TextStyle(color: kTextPrimary, fontSize: 14.0.sp),
          decoration: _fd('Search by ID or title'),
          onChanged: (_) {
            if (_selectedWorkOrderId != null) {
              setState(() => _selectedWorkOrderId = null);
            }
            _workOrderSearchCtrl.text = controller.text;
          },
          validator: (_) =>
              _selectedWorkOrderId == null ? 'Select a valid work order' : null,
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(10.0.r),
            color: kSurface,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 220.0.h,
                maxWidth: MediaQuery.sizeOf(context).width - 40.0.w,
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    title: Text(option.id),
                    subtitle: Text(option.label),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChecklistItem(int index) {
    final entry = _items[index];
    return Padding(
      padding: EdgeInsets.only(bottom: 12.0.h),
      child: Box(
        style: $card().padding(.all(14)),
        child: Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => entry.isPass = !entry.isPass),
                  child: Container(
                    width: 36.0.w,
                    height: 36.0.w,
                    decoration: BoxDecoration(
                      color: (entry.isPass ? kSuccess : kDanger).withValues(
                        alpha: 0.15,
                      ),
                      borderRadius: BorderRadius.circular(8.0.r),
                    ),
                    child: Icon(
                      entry.isPass ? Icons.check : Icons.close,
                      color: entry.isPass ? kSuccess : kDanger,
                      size: 18.0.sp,
                    ),
                  ),
                ),
                SizedBox(width: 12.0.w),
                Expanded(
                  child: TextFormField(
                    controller: entry.questionCtrl,
                    style: TextStyle(color: kTextPrimary, fontSize: 13.0.sp),
                    decoration: InputDecoration(
                      hintText: 'Check item ${index + 1}...',
                      hintStyle: TextStyle(
                        color: kTextMuted,
                        fontSize: 13.0.sp,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                ),
                if (_items.length > 1)
                  GestureDetector(
                    onTap: () => _removeItem(index),
                    child: Icon(
                      Icons.remove_circle_outline,
                      color: kDanger.withValues(alpha: 0.6),
                      size: 20.0.sp,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8.0.h),
            TextFormField(
              controller: entry.commentsCtrl,
              style: TextStyle(color: kTextMuted, fontSize: 12.0.sp),
              decoration: InputDecoration(
                hintText: 'Comments (optional)',
                hintStyle: TextStyle(
                  color: kTextMuted.withValues(alpha: 0.5),
                  fontSize: 12.0.sp,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
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
      borderSide: const BorderSide(color: kWarning, width: 1.5),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 14.0.h),
  );
}

class _ChecklistEntry {
  final TextEditingController questionCtrl;
  final TextEditingController commentsCtrl;
  bool isPass;

  _ChecklistEntry({String question = '', String? comments, this.isPass = true})
    : questionCtrl = TextEditingController(text: question),
      commentsCtrl = TextEditingController(text: comments ?? '');
}
