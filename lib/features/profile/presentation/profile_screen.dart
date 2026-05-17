import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/storage/app_preferences.dart';
import '../../../core/theme/sentra_tokens.dart';
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

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProfileProvider);

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
          SizedBox(height: 12.0.h),
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
                if (user != null && user.role.isSupervisorOrAbove) ...[
                  const Divider(height: 1, color: kBorder),
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
              ],
            ),
          ),
          SizedBox(height: 20.0.h),
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
        ],
      ),
    );
  }
}
