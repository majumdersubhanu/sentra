import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mix/mix.dart';
import '../../../core/theme/sentra_styles.dart';
import '../../../core/theme/sentra_tokens.dart';
import '../../../routes/app_router.dart';
import 'auth_view_model.dart';

@RoutePage()
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});
  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  late final AnimationController _anim;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slide = Tween(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    ref.listen(authViewModelProvider, (prev, next) {
      next.whenOrNull(
        data: (_) {
          if (ref.read(isAuthenticatedProvider)) {
            context.router.replaceAll([const DashboardRoute()]);
          }
        },
        error: (e, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: kDanger),
        ),
      );
    });

    return Scaffold(
      backgroundColor: kSurface,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 28.0.w),
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(16.0.w),
                    decoration: BoxDecoration(
                      color: kAccent.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shield_outlined,
                      color: kAccent,
                      size: 48.0.sp,
                    ),
                  ),
                  SizedBox(height: 20.0.h),
                  Text(
                    'Sentra',
                    style: TextStyle(
                      color: kTextPrimary,
                      fontSize: 28.0.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 4.0.h),
                  Text(
                    'Field Operations Platform',
                    style: TextStyle(color: kTextMuted, fontSize: 13.0.sp),
                  ),
                  SizedBox(height: 40.0.h),

                  Box(
                    style: $card().padding(.all(24)),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sign In',
                            style: TextStyle(
                              color: kTextPrimary,
                              fontSize: 18.0.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 6.0.h),
                          Text(
                            'Enter your credentials to continue',
                            style: TextStyle(
                              color: kTextMuted,
                              fontSize: 13.0.sp,
                            ),
                          ),
                          SizedBox(height: 24.0.h),

                          Text(
                            'Email',
                            style: TextStyle(
                              color: kTextSecondary,
                              fontSize: 12.0.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 6.0.h),
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(
                              color: kTextPrimary,
                              fontSize: 14.0.sp,
                            ),
                            decoration: _fd(
                              Icons.email_outlined,
                              'name@company.com',
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Email required';
                              }
                              if (!v.contains('@')) return 'Invalid email';
                              return null;
                            },
                          ),
                          SizedBox(height: 18.0.h),

                          Text(
                            'Password',
                            style: TextStyle(
                              color: kTextSecondary,
                              fontSize: 12.0.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 6.0.h),
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: _obscure,
                            style: TextStyle(
                              color: kTextPrimary,
                              fontSize: 14.0.sp,
                            ),
                            decoration: _fd(Icons.lock_outline, '••••••••')
                                .copyWith(
                                  suffixIcon: GestureDetector(
                                    onTap: () =>
                                        setState(() => _obscure = !_obscure),
                                    child: Icon(
                                      _obscure
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: kTextMuted,
                                      size: 20.0.sp,
                                    ),
                                  ),
                                ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Password required';
                              }
                              if (v.length < 6) return 'Min 6 characters';
                              return null;
                            },
                          ),
                          SizedBox(height: 28.0.h),

                          SizedBox(
                            width: double.infinity,
                            height: 48.0.h,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0.r),
                                ),
                                elevation: 0,
                              ),
                              onPressed: authState.isLoading
                                  ? null
                                  : () {
                                      if (_formKey.currentState!.validate()) {
                                        ref
                                            .read(
                                              authViewModelProvider.notifier,
                                            )
                                            .signIn(
                                              _emailCtrl.text.trim(),
                                              _passwordCtrl.text.trim(),
                                            );
                                      }
                                    },
                              child: authState.isLoading
                                  ? SizedBox(
                                      height: 20.0.h,
                                      width: 20.0.h,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Sign In',
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
                  SizedBox(height: 24.0.h),
                  Text(
                    'v1.0.0  •  Sentra Platform',
                    style: TextStyle(
                      color: kTextMuted.withValues(alpha: 0.4),
                      fontSize: 11.0.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _fd(IconData icon, String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: kTextMuted, fontSize: 14.0.sp),
    prefixIcon: Icon(icon, color: kTextMuted, size: 20.0.sp),
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
      borderSide: const BorderSide(color: kAccent, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0.r),
      borderSide: const BorderSide(color: kDanger),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 14.0.h),
  );
}
