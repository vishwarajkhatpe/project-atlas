import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'auth_controller.dart';
import '../utils/auth_error_formatter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/atlas_card.dart';
import '../../../core/widgets/atlas_button.dart';
import '../../../core/widgets/atlas_text_field.dart';
import '../../../core/widgets/atlas_snackbar.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.lightImpact();
    ref.read(authControllerProvider.notifier).signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isDark = AppColors.isDark(context);
    final accent = AppColors.primaryAccent(context);

    ref.listen<AsyncValue>(authControllerProvider, (_, state) {
      if (!state.isLoading && state.hasError) {
        final errorText = AuthErrorFormatter.format(state.error!);
        AtlasSnackbar.error(context, errorText);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: Stack(
        children: [
          // Background ambient gradient glow
          Positioned(
            top: -100,
            left: MediaQuery.of(context).size.width * 0.5 - 150,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accent.withValues(alpha: isDark ? 0.3 : 0.12),
                    accent.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo Badge
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: accent.withValues(alpha: isDark ? 0.35 : 0.15),
                                blurRadius: 24,
                                spreadRadius: 2,
                              )
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: SvgPicture.asset(
                              'assets/images/app_logo.svg',
                              width: 72,
                              height: 72,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8)),

                      const SizedBox(height: AppSpacing.lg),

                      Text(
                        'Welcome to Atlas',
                        style: AppTextStyles.pageTitle.copyWith(
                          color: AppColors.txtPrimary(context),
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(duration: 450.ms, delay: 100.ms),

                      const SizedBox(height: AppSpacing.xs),

                      Text(
                        'Sign in to plan your next adventure together.',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.txtSecondary(context),
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(duration: 500.ms, delay: 150.ms),

                      const SizedBox(height: AppSpacing.xxl),

                      // Form Card
                      AtlasCard(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AtlasTextField(
                              controller: _emailController,
                              label: 'Email',
                              hint: 'name@example.com',
                              prefixIcon: LucideIcons.mail,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Email is required';
                                }
                                if (!value.contains('@')) {
                                  return 'Enter a valid email address';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            AtlasTextField(
                              controller: _passwordController,
                              label: 'Password',
                              hint: '••••••••',
                              prefixIcon: LucideIcons.lock,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _signIn(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? LucideIcons.eye : LucideIcons.eye_off,
                                  size: 18,
                                  color: AppColors.txtMuted(context),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  _showForgotPasswordDialog(context, accent);
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Forgot Password?',
                                  style: AppTextStyles.body.copyWith(
                                    color: accent,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            AtlasButton(
                              label: 'Sign In',
                              icon: LucideIcons.log_in,
                              isLoading: authState.isLoading,
                              onPressed: authState.isLoading ? null : _signIn,
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),

                      const SizedBox(height: AppSpacing.xl),

                      // Sign Up Option
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.txtSecondary(context),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              context.go('/signup');
                            },
                            child: Text(
                              'Sign Up',
                              style: AppTextStyles.body.copyWith(
                                color: accent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 550.ms, delay: 250.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context, Color accent) {
    final resetEmailController = TextEditingController(text: _emailController.text);
    final formKey = GlobalKey<FormState>();
    bool isResetting = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              backgroundColor: AppColors.cardBg(context),
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text('Reset Password', style: AppTextStyles.sectionTitle.copyWith(color: AppColors.txtPrimary(context))),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Enter your email address and we will send you a password reset link.',
                      style: AppTextStyles.body.copyWith(color: AppColors.txtSecondary(context)),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AtlasTextField(
                      controller: resetEmailController,
                      label: 'Email',
                      hint: 'name@example.com',
                      prefixIcon: LucideIcons.mail,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Email is required';
                        if (!value.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isResetting ? null : () => Navigator.of(ctx).pop(),
                  child: Text('Cancel', style: AppTextStyles.body.copyWith(color: AppColors.txtMuted(context))),
                ),
                SizedBox(
                  width: 120,
                  child: AtlasButton(
                    label: 'Send Link',
                    isLoading: isResetting,
                    onPressed: isResetting
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;
                            setState(() => isResetting = true);
                            try {
                              await ref.read(authControllerProvider.notifier).resetPassword(resetEmailController.text.trim());
                              if (ctx.mounted) {
                                Navigator.of(ctx).pop();
                                AtlasSnackbar.success(context, 'Password reset link sent to your email.');
                              }
                            } catch (e) {
                              if (ctx.mounted) {
                                setState(() => isResetting = false);
                                AtlasSnackbar.error(ctx, AuthErrorFormatter.format(e));
                              }
                            }
                          },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
