import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/sentra_tokens.dart';
import '../../auth/domain/user_profile.dart';
import 'user_view_model.dart';

@RoutePage()
class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersViewModelProvider);

    return Scaffold(
      backgroundColor: kSurface,
      appBar: AppBar(
        title: Text(
          'Manage Users',
          style: TextStyle(fontSize: 18.0.sp, fontWeight: FontWeight.w700),
        ),
      ),
      body: usersAsync.when(
        data: (users) => ListView.separated(
          padding: EdgeInsets.all(16.0.w),
          itemCount: users.length,
          separatorBuilder: (_, _) => SizedBox(height: 12.0.h),
          itemBuilder: (context, index) {
            final user = users[index];
            return Card(
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
                          radius: 20.0.r,
                          backgroundColor: kAccent.withValues(alpha: 0.18),
                          child: Text(
                            user.fullName.isNotEmpty
                                ? user.fullName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(color: kAccent),
                          ),
                        ),
                        SizedBox(width: 12.0.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.fullName,
                                style: TextStyle(
                                  color: kTextPrimary,
                                  fontSize: 16.0.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                user.email,
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
                    SizedBox(height: 16.0.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Role',
                          style: TextStyle(
                            color: kTextSecondary,
                            fontSize: 13.0.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        DropdownButton<UserRole>(
                          value: user.role,
                          dropdownColor: kSurfaceElevated,
                          style: TextStyle(
                            color: kTextPrimary,
                            fontSize: 14.0.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          underline: const SizedBox(),
                          items: UserRole.values
                              .map(
                                (r) => DropdownMenuItem(
                                  value: r,
                                  child: Text(r.name.toUpperCase()),
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
        error: (err, _) => Center(
          child: Text('Error: $err', style: const TextStyle(color: kDanger)),
        ),
      ),
    );
  }
}
