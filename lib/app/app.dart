import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentra_ui/sentra_ui.dart';
import '../core/theme/sentra_theme_manager.dart';
import '../routes/app_router.dart';

class SentraApp extends ConsumerWidget {
  final _appRouter = AppRouter();

  SentraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeConfig = ref.watch(themeConfigProvider);

    return ScreenUtilInit(
      designSize: const Size(375, 812), // Standard mobile design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Sentra Field Platform',
          debugShowCheckedModeBanner: false,
          themeMode: themeConfig.mode == SentraThemeMode.light
              ? ThemeMode.light
              : ThemeMode.dark,
          theme: SentraTheme.light,
          darkTheme: SentraTheme.dark,
          routerConfig: _appRouter.config(),
        );
      },
    );
  }
}
