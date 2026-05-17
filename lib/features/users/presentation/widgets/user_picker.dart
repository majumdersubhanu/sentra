import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mix/mix.dart';

import 'package:sentra/features/auth/domain/user_profile.dart';
import 'package:sentra/features/users/presentation/user_view_model.dart';
import 'package:sentra/core/theme/sentra_styles.dart';
import 'package:sentra/core/theme/sentra_tokens.dart';

class UserPicker extends ConsumerWidget {
  final String? selectedUserId;
  final ValueChanged<UserProfile> onSelected;

  const UserPicker({super.key, this.selectedUserId, required this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final techniciansAsync = ref.watch(techniciansProvider);

    return Box(
      style: $sectionCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_search_outlined, color: kAccent, size: 18.sp),
              SizedBox(width: 8.w),
              Text(
                'Assign Technician',
                style: TextStyle(
                  color: kTextPrimary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.0.h),
          techniciansAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) =>
                Text('Error: $err', style: const TextStyle(color: kDanger)),
            data: (technicians) {
              if (technicians.isEmpty) {
                return const Text(
                  'No technicians available',
                  style: TextStyle(color: kTextMuted),
                );
              }

              return Column(
                children: technicians.map((user) {
                  final isSelected = user.id == selectedUserId;
                  return PressableBox(
                    onPress: () => onSelected(user),
                    style: BoxStyler()
                        .paddingAll(12.0.w)
                        .marginOnly(bottom: 8.0.h)
                        .borderRadiusAll($radiusMd())
                        .borderAll(
                          color: isSelected ? kAccent : kBorder,
                          width: isSelected ? 2 : 1,
                        )
                        .color(
                          isSelected
                              ? kAccent.withValues(alpha: 0.05)
                              : kSurface,
                        ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16.r,
                          backgroundColor: kAccent.withValues(alpha: 0.1),
                          child: Text(
                            user.fullName[0].toUpperCase(),
                            style: TextStyle(
                              color: kAccent,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.fullName,
                                style: TextStyle(
                                  color: kTextPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                user.email,
                                style: TextStyle(
                                  color: kTextSecondary,
                                  fontSize: 11.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle, color: kAccent, size: 20.sp),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
