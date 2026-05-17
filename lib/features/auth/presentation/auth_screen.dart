import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentra_ui/sentra_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../routes/app_router.dart';
import 'auth_view_model.dart';

@RoutePage()
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});
  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _orgCtrl = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    _orgCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final notifier = ref.read(authViewModelProvider.notifier);

    final result = _isLogin
        ? await notifier.signInWithEmailAndPassword(
            _emailCtrl.text,
            _passwordCtrl.text,
          )
        : await notifier.signUp(
            email: _emailCtrl.text,
            password: _passwordCtrl.text,
            fullName: _nameCtrl.text,
            organizationName: _orgCtrl.text,
          );

    if (mounted) {
      setState(() => _isLoading = false);
      if (result.isRight()) {
        context.router.replaceAll([const DashboardRoute()]);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.fold((l) => l.message, (_) => '')),
            backgroundColor: SentraColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(SentraSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  LucideIcons.shieldCheck,
                  size: 64,
                  color: SentraColors.primary500,
                ),
                const SizedBox(height: SentraSpacing.m),
                Text(
                  'SENTRA',
                  style: SentraTypography.h1.copyWith(letterSpacing: 4),
                ),
                Text(
                  'FIELD PLATFORM',
                  style: SentraTypography.label.copyWith(
                    color: SentraColors.gray500,
                  ),
                ),
                const SizedBox(height: SentraSpacing.xxl),

                if (!_isLogin) ...[
                  SentraTextField(
                    label: 'Full Name',
                    controller: _nameCtrl,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: SentraSpacing.m),
                  SentraTextField(
                    label: 'Organization (Leave blank to join existing)',
                    controller: _orgCtrl,
                  ),
                  const SizedBox(height: SentraSpacing.m),
                ],

                SentraTextField(
                  label: 'Email Address',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: SentraSpacing.m),
                SentraTextField(
                  label: 'Password',
                  controller: _passwordCtrl,
                  isPassword: true,
                  validator: (v) => v!.length < 6 ? 'Too short' : null,
                ),
                const SizedBox(height: SentraSpacing.xl),

                SizedBox(
                  width: double.infinity,
                  child: SentraButton(
                    label: _isLoading
                        ? 'Processing...'
                        : (_isLogin ? 'Sign In' : 'Create Account'),
                    onPressed: _isLoading ? null : _submit,
                  ),
                ),
                const SizedBox(height: SentraSpacing.m),
                TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: Text(
                    _isLogin
                        ? 'Don\'t have an account? Sign Up'
                        : 'Already have an account? Sign In',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
