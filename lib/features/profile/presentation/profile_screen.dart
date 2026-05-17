import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentra_ui/sentra_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/sentra_theme_manager.dart';
import '../../auth/domain/user_profile.dart';
import '../../auth/presentation/auth_view_model.dart';
import '../../../routes/app_router.dart';

@RoutePage()
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProfileProvider);
    final themeConfig = ref.watch(themeConfigProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile & Settings', style: SentraTypography.h3),
      ),
      body: ListView(
        padding: const EdgeInsets.all(SentraSpacing.m),
        children: [
          // User Profile Card
          SentraCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: SentraColors.primary100,
                      child: const Icon(
                        LucideIcons.user,
                        color: SentraColors.primary700,
                      ),
                    ),
                    const SizedBox(width: SentraSpacing.m),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.fullName ?? 'Unknown User',
                            style: SentraTypography.h3,
                          ),
                          Text(
                            user?.email ?? 'No email available',
                            style: SentraTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    SentraBadge(
                      label: user?.role.name.toUpperCase() ?? 'UNKNOWN',
                      type: _getRoleBadgeType(user?.role),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: SentraSpacing.l),

          // Appearance Settings
          _sectionHeader('Appearance'),
          SentraCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(LucideIcons.moon),
                  title: Text('Dark Mode', style: SentraTypography.bodyMedium),
                  trailing: Switch(
                    value: themeConfig.mode == SentraThemeMode.dark,
                    onChanged: (val) {
                      ref
                          .read(themeConfigProvider.notifier)
                          .setThemeMode(
                            val ? SentraThemeMode.dark : SentraThemeMode.light,
                          );
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(LucideIcons.palette),
                  title: Text(
                    'Primary Color',
                    style: SentraTypography.bodyMedium,
                  ),
                  trailing: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color:
                          themeConfig.primaryColor ?? SentraColors.primary500,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: SentraSpacing.l),

          // Admin Options
          if (user != null && user.role.isAdmin) ...[
            _sectionHeader('Organization Management'),
            SentraCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(LucideIcons.users),
                    title: Text(
                      'Manage Team',
                      style: SentraTypography.bodyMedium,
                    ),
                    subtitle: Text(
                      'Invite users and assign roles',
                      style: SentraTypography.bodySmall,
                    ),
                    trailing: const Icon(LucideIcons.chevronRight),
                    onTap: () => context.router.push(const UsersRoute()),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(LucideIcons.building),
                    title: Text(
                      'Organization Settings',
                      style: SentraTypography.bodyMedium,
                    ),
                    trailing: const Icon(LucideIcons.chevronRight),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: SentraSpacing.l),
          ],

          // Sign Out
          SentraButton(
            label: 'Sign Out',
            onPressed: () {
              ref.read(authViewModelProvider.notifier).signOut().then((_) {
                if (context.mounted) {
                  context.router.replaceAll([const AuthRoute()]);
                }
              });
            },
            isPrimary: false,
          ),
          const SizedBox(height: SentraSpacing.xl),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: SentraTypography.label.copyWith(
          color: SentraColors.gray500,
          fontSize: 11,
        ),
      ),
    );
  }

  SentraBadgeType _getRoleBadgeType(UserRole? role) {
    switch (role) {
      case UserRole.admin:
        return SentraBadgeType.error;
      case UserRole.supervisor:
        return SentraBadgeType.warning;
      case UserRole.technician:
        return SentraBadgeType.info;
      default:
        return SentraBadgeType.neutral;
    }
  }
}
