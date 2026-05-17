import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentra_ui/sentra_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../auth/domain/user_profile.dart';
import 'user_view_model.dart';

@RoutePage()
class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Team', style: SentraTypography.h3),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.userPlus),
            onPressed: () => _showInviteDialog(context, ref),
          ),
        ],
      ),
      body: usersAsync.when(
        data: (users) => ListView.builder(
          padding: const EdgeInsets.all(SentraSpacing.m),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: SentraSpacing.m),
              child: SentraCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: SentraColors.gray100,
                          child: Text(
                            user.fullName.isNotEmpty
                                ? user.fullName[0].toUpperCase()
                                : '?',
                            style: SentraTypography.label.copyWith(
                              color: SentraColors.primary700,
                            ),
                          ),
                        ),
                        const SizedBox(width: SentraSpacing.m),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.fullName, style: SentraTypography.h3),
                              Text(
                                user.email,
                                style: SentraTypography.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        SentraBadge(
                          label: user.role.name.toUpperCase(),
                          type: _getRoleBadgeType(user.role),
                        ),
                      ],
                    ),
                    const SizedBox(height: SentraSpacing.m),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Change Role',
                          style: SentraTypography.label.copyWith(
                            color: SentraColors.gray500,
                          ),
                        ),
                        DropdownButton<UserRole>(
                          value: user.role,
                          underline: const SizedBox(),
                          icon: const Icon(LucideIcons.chevronDown, size: 16),
                          items: UserRole.values
                              .map(
                                (r) => DropdownMenuItem(
                                  value: r,
                                  child: Text(
                                    r.name.toUpperCase(),
                                    style: SentraTypography.bodySmall,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (newRole) {
                            if (newRole != null && newRole != user.role) {
                              ref
                                  .read(usersViewModelProvider.notifier)
                                  .updateRole(user.id, newRole);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  void _showInviteDialog(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    final nameController = TextEditingController();
    UserRole selectedRole = UserRole.technician;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Invite Team Member', style: SentraTypography.h3),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SentraTextField(label: 'Full Name', controller: nameController),
              const SizedBox(height: SentraSpacing.m),
              SentraTextField(
                label: 'Email Address',
                controller: emailController,
              ),
              const SizedBox(height: SentraSpacing.m),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Role', style: SentraTypography.label),
                  DropdownButton<UserRole>(
                    value: selectedRole,
                    items: UserRole.values
                        .map(
                          (r) => DropdownMenuItem(
                            value: r,
                            child: Text(r.name.toUpperCase()),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => selectedRole = val!),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            SentraButton(
              label: 'Send Invite',
              onPressed: () {
                if (emailController.text.isNotEmpty &&
                    nameController.text.isNotEmpty) {
                  ref
                      .read(usersViewModelProvider.notifier)
                      .inviteUser(
                        email: emailController.text,
                        fullName: nameController.text,
                        role: selectedRole,
                      );
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  SentraBadgeType _getRoleBadgeType(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return SentraBadgeType.error;
      case UserRole.supervisor:
        return SentraBadgeType.warning;
      case UserRole.technician:
        return SentraBadgeType.info;
    }
  }
}
