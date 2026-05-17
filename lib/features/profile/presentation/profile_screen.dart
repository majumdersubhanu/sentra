import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/storage/app_preferences.dart';
import '../../../core/theme/sentra_tokens.dart';
import '../../../core/theme/sentra_theme_manager.dart';
import '../../../core/theme/sentra_components.dart';
import '../../auth/presentation/auth_view_model.dart';
import '../../../routes/app_router.dart';

@RoutePage()
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _showOfflineBanner = true;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final value = await AppPreferences.instance.getShowOfflineBanner();
    if (!mounted) return;
    setState(() {
      _showOfflineBanner = value;
      _loaded = true;
    });
  }

  void _showColorPicker(WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _ColorPickerDialog(
        onColorSelected: (color) {
          ref.read(themeConfigProvider.notifier).setPrimaryColor(color);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProfileProvider);
    final themeConfig = ref.watch(themeConfigProvider);

    return Scaffold(
      backgroundColor: kSurface,
      appBar: AppBar(
        title: Text(
          'Profile & Settings',
          style: TextStyle(fontSize: 18.0.sp, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0.w),
        children: [
          // User Profile Card
          Card(
            color: kSurfaceElevated,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.0.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22.0.r,
                        backgroundColor: kAccent.withValues(alpha: 0.18),
                        child: const Icon(
                          LucideIcons.userRound,
                          color: kAccent,
                        ),
                      ),
                      SizedBox(width: 12.0.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.fullName ?? 'Unknown User',
                              style: TextStyle(
                                color: kTextPrimary,
                                fontSize: 16.0.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 2.0.h),
                            Text(
                              user?.email ?? 'No email available',
                              style: TextStyle(
                                color: kTextMuted,
                                fontSize: 12.0.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.0.h),
                  Text(
                    'Role: ${user?.role.name.toUpperCase() ?? "UNKNOWN"}',
                    style: TextStyle(
                      color: kTextSecondary,
                      fontSize: 12.0.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24.0.h),

          // Appearance Settings
          SectionHeader(
            icon: LucideIcons.palette,
            title: 'Appearance',
            subtitle: 'Customize how the app looks',
          ),
          Card(
            color: kSurfaceElevated,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0.r),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(LucideIcons.moon, color: kTextPrimary),
                  title: const Text('Theme Mode'),
                  subtitle: Text(
                    themeConfig.mode == SentraThemeMode.light ? 'Light' : 'Dark',
                  ),
                  trailing: SegmentedButton<SentraThemeMode>(
                    segments: [
                      ButtonSegment(
                        value: SentraThemeMode.light,
                        label: Text('Light', style: TextStyle(fontSize: 11.0.sp)),
                        icon: const Icon(LucideIcons.sun, size: 16),
                      ),
                      ButtonSegment(
                        value: SentraThemeMode.dark,
                        label: Text('Dark', style: TextStyle(fontSize: 11.0.sp)),
                        icon: const Icon(LucideIcons.moon, size: 16),
                      ),
                    ],
                    selected: {themeConfig.mode},
                    onSelectionChanged: (Set<SentraThemeMode> newSelection) {
                      ref
                          .read(themeConfigProvider.notifier)
                          .setThemeMode(newSelection.first);
                    },
                  ),
                ),
                const Divider(height: 1, color: kBorder),
                ListTile(
                  leading: const Icon(LucideIcons.palette, color: kTextPrimary),
                  title: const Text('Primary Color'),
                  subtitle: const Text('Choose your accent color'),
                  trailing: GestureDetector(
                    onTap: () => _showColorPicker(ref),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: themeConfig.primaryColor ?? kBrand,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: kBorder),
                      ),
                    ),
                  ),
                ),
                if (themeConfig.primaryColor != null)
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0.w),
                    title: const Text('Reset to Default'),
                    trailing: IconButton(
                      icon: const Icon(Icons.refresh, color: kTextSecondary),
                      onPressed: () {
                        ref.read(themeConfigProvider.notifier).resetColors();
                      },
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 24.0.h),

          // General Settings
          SectionHeader(
            icon: LucideIcons.settings,
            title: 'General Settings',
          ),
          Card(
            color: kSurfaceElevated,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0.r),
            ),
            child: Column(
              children: [
                if (_loaded)
                  SwitchListTile(
                    value: _showOfflineBanner,
                    title: const Text('Show offline banner'),
                    subtitle: const Text(
                      'Display a warning banner when device connectivity is unavailable.',
                    ),
                    onChanged: (value) async {
                      setState(() => _showOfflineBanner = value);
                      await AppPreferences.instance.setShowOfflineBanner(value);
                    },
                  )
                else
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: LinearProgressIndicator(),
                  ),
              ],
            ),
          ),
          SizedBox(height: 16.0.h),

          // Admin Options
          if (user != null && user.role.isSupervisorOrAbove) ...[
            SectionHeader(
              icon: LucideIcons.shield,
              title: 'Administration',
            ),
            Card(
              color: kSurfaceElevated,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0.r),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(LucideIcons.users, color: kTextPrimary),
                    title: const Text('Manage Users & Roles'),
                    subtitle: const Text('Configure team access levels'),
                    trailing: const Icon(LucideIcons.chevronRight, color: kTextMuted),
                    onTap: () {
                      context.router.push(const UsersRoute());
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.0.h),
          ],

          // Sign Out
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: kDanger,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 48.0.h),
            ),
            icon: const Icon(LucideIcons.logOut),
            label: const Text('Sign out'),
            onPressed: () {
              ref.read(authViewModelProvider.notifier).signOut().then((_) {
                if (context.mounted) {
                  context.router.replaceAll([const AuthRoute()]);
                }
              });
            },
          ),
          SizedBox(height: 20.0.h),
        ],
      ),
    );
  }
}

/// Color picker dialog for selecting primary theme color.
class _ColorPickerDialog extends StatefulWidget {
  final Function(Color) onColorSelected;

  const _ColorPickerDialog({required this.onColorSelected});

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  // Professional color palette inspired by design systems
  static const colors = [
    Color(0xFF1E40AF), // Blue 800 (Default brand)
    Color(0xFF0EA5E9), // Sky Blue
    Color(0xFF06B6D4), // Cyan
    Color(0xFF10B981), // Emerald
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEC4899), // Pink
    Color(0xFFEF4444), // Red
    Color(0xFFF97316), // Orange
    Color(0xFFFACC15), // Yellow
    Color(0xFF14B8A6), // Teal
  ];

  late Color _selectedColor = colors[0];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Primary Color',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: kTextPrimary,
              ),
            ),
            SizedBox(height: 20.h),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                spacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: colors.length,
              itemBuilder: (context, index) {
                final color = colors[index];
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedColor = color);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 3)
                          : Border.all(color: color.withValues(alpha: 0.3), width: 1),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                          )
                        : null,
                  ),
                );
              },
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: () {
                    widget.onColorSelected(_selectedColor);
                  },
                  child: const Text('Apply'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
