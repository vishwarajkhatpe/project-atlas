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

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signUp() {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.lightImpact();
    ref.read(authControllerProvider.notifier).signUp(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _nameController.text.trim(),
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(LucideIcons.arrow_left, color: AppColors.txtPrimary(context)),
          onPressed: () {
            HapticFeedback.lightImpact();
            context.go('/login');
          },
        ),
      ),
      body: Stack(
        children: [
          // Background ambient gradient glow
          Positioned(
            top: -100,
            right: MediaQuery.of(context).size.width * 0.5 - 150,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accent.withValues(alpha: isDark ? 0.25 : 0.1),
                    accent.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Badge Icon
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
                        'Create Account',
                        style: AppTextStyles.pageTitle.copyWith(
                          color: AppColors.txtPrimary(context),
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(duration: 450.ms, delay: 100.ms),

                      const SizedBox(height: AppSpacing.xs),

                      Text(
                        'Join Atlas and start collaborating with friends.',
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
                              controller: _nameController,
                              label: 'Full Name',
                              hint: 'Alex Morgan',
                              prefixIcon: LucideIcons.user,
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Full Name is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.lg),
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
                              onFieldSubmitted: (_) => _signUp(),
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
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                            AtlasButton(
                              label: 'Create Account',
                              icon: LucideIcons.user_check,
                              isLoading: authState.isLoading,
                              onPressed: authState.isLoading ? null : _signUp,
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),

                      const SizedBox(height: AppSpacing.xl),

                      // Sign In Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.txtSecondary(context),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              context.go('/login');
                            },
                            child: Text(
                              'Sign In',
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
}
