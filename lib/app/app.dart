import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mix/mix.dart';
import '../core/theme/sentra_tokens.dart';
import '../routes/app_router.dart';

class SentraApp extends StatefulWidget {
  const SentraApp({super.key});

  @override
  State<SentraApp> createState() => _SentraAppState();
}

class _SentraAppState extends State<SentraApp> {
  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Tablet/Desktop uses larger design size, mobile uses 375x812
        final isLarge = constraints.maxWidth > 600;
        return ScreenUtilInit(
          designSize: isLarge ? const Size(768, 1024) : const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MixScope(
              colors: braidLightColors,
              spaces: braidSpaces,
              radii: braidRadii,
              child: MaterialApp.router(
                title: 'Sentra Field Platform',
                debugShowCheckedModeBanner: false,
                themeMode: ThemeMode.light,
                theme: ThemeData(
                  useMaterial3: true,
                  brightness: Brightness.light,
                  textTheme: GoogleFonts.interTextTheme(
                    ThemeData(brightness: Brightness.light).textTheme,
                  ),
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: kBrand,
                    brightness: Brightness.light,
                    surface: kBody,
                  ),
                  scaffoldBackgroundColor: kBody,
                  appBarTheme: AppBarTheme(
                    backgroundColor: kSurface,
                    elevation: 0,
                    centerTitle: false,
                    iconTheme: const IconThemeData(color: kTextPrimary),
                    titleTextStyle: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 18.sp,
                      color: kTextPrimary,
                    ),
                  ),
                ),
                routerConfig: _appRouter.config(),
              ),
            );
          },
        );
      },
    );
  }
}
