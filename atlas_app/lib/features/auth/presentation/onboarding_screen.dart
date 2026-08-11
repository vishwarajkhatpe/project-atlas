import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Design System
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/widgets/atlas_button.dart';
import '../../../core/widgets/atlas_avatar.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Plan Together.',
      'subtitle': 'Invite your friends, share ideas, and map out every detail of your journey seamlessly in one place.',
      'accentColor': const Color(0xFF4F46E5), // Modern Indigo
      'bgGlow': const Color(0xFF6366F1),
    },
    {
      'title': 'Decide Together.',
      'subtitle': 'Eliminate endless group chat debates. Vote on dates, destinations, and activities with ease.',
      'accentColor': const Color(0xFF7C3AED), // Violet
      'bgGlow': const Color(0xFF8B5CF6),
    },
    {
      'title': 'Everything in\nOne Place.',
      'subtitle': 'Real-time group chat, expense splitting, and locked-in itineraries—all working together.',
      'accentColor': const Color(0xFF059669), // Emerald
      'bgGlow': const Color(0xFF10B981),
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _completeOnboarding() async {
    HapticFeedback.mediumImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    if (mounted) {
      context.go('/login');
    }
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      HapticFeedback.lightImpact();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPageData = _pages[_currentPage];
    final Color currentAccent = currentPageData['accentColor'];
    final Color currentGlow = currentPageData['bgGlow'];
    final isDark = AppColors.isDark(context);

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: Stack(
        children: [
          // Ambient Glow Circle Behind Visuals
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            top: MediaQuery.of(context).size.height * 0.1,
            left: MediaQuery.of(context).size.width * 0.5 - 150,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    currentGlow.withValues(alpha: isDark ? 0.35 : 0.15),
                    currentGlow.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Header Bar with Logo and Skip
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.xs),
                            decoration: BoxDecoration(
                              color: currentAccent.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: currentAccent.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Icon(
                              LucideIcons.compass,
                              size: 18,
                              color: currentAccent,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'ATLAS',
                            style: AppTextStyles.sectionTitle.copyWith(
                              color: AppColors.txtPrimary(context),
                              letterSpacing: 2,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      if (_currentPage < _pages.length - 1)
                        TextButton(
                          onPressed: _completeOnboarding,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.txtSecondary(context),
                          ),
                          child: const Text('Skip'),
                        ),
                    ],
                  ),
                ),

                // Page View Content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Graphic Visual Slot
                            Expanded(
                              flex: 5,
                              child: Center(
                                child: _buildIllustration(index, currentAccent),
                              ),
                            ),

                            // Text Content Slot
                            Expanded(
                              flex: 4,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    _pages[index]['title']!,
                                    style: AppTextStyles.pageTitle.copyWith(
                                      color: AppColors.txtPrimary(context),
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      height: 1.2,
                                    ),
                                    textAlign: TextAlign.center,
                                  ).animate(key: ValueKey('title_$index'))
                                   .fadeIn(duration: 400.ms)
                                   .slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),

                                  const SizedBox(height: AppSpacing.md),

                                  Text(
                                    _pages[index]['subtitle']!,
                                    style: AppTextStyles.body.copyWith(
                                      color: AppColors.txtSecondary(context),
                                      fontSize: 15,
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ).animate(key: ValueKey('sub_$index'))
                                   .fadeIn(duration: 450.ms, delay: 100.ms)
                                   .slideY(begin: 0.2, end: 0, duration: 450.ms, curve: Curves.easeOutCubic),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Controls Area
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    children: [
                      // Animated Indicator Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 8,
                            width: _currentPage == index ? 28 : 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? currentAccent
                                  : AppColors.brdStrong(context),
                              borderRadius: AppRadii.pillRadius,
                              boxShadow: _currentPage == index
                                  ? [
                                      BoxShadow(
                                        color: currentAccent.withValues(alpha: 0.4),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      )
                                    ]
                                  : [],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xxl),

                      // Next / Get Started Action Button
                      SizedBox(
                        width: double.infinity,
                        child: AtlasButton(
                          label: _currentPage == _pages.length - 1 ? 'Get Started' : 'Continue',
                          icon: _currentPage == _pages.length - 1 ? LucideIcons.rocket : LucideIcons.arrow_right,
                          onPressed: _nextPage,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds visually rich adaptive glassmorphic composited illustrations for each slide
  Widget _buildIllustration(int pageIndex, Color accent) {
    switch (pageIndex) {
      case 0:
        return _buildPlanTogetherGraphic(accent);
      case 1:
        return _buildDecideTogetherGraphic(accent);
      case 2:
      default:
        return _buildEverythingInOneGraphic(accent);
    }
  }

  Widget _buildPlanTogetherGraphic(Color accent) {
    final isDark = AppColors.isDark(context);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 340, maxHeight: 260),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.cardBg(context).withValues(alpha: isDark ? 0.85 : 0.95),
        borderRadius: AppRadii.largeRadius,
        border: Border.all(color: AppColors.brd(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 25,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(LucideIcons.plane, color: accent, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Honolulu Escape 🌴',
                      style: AppTextStyles.cardTitle.copyWith(
                        color: AppColors.txtPrimary(context),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Aug 14 - Aug 21 • 4 Travelers',
                      style: AppTextStyles.secondary.copyWith(
                        color: AppColors.txtSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Stacked Avatar Group & Route Line
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.inputBg(context),
              borderRadius: AppRadii.cardRadius,
              border: Border.all(color: AppColors.brd(context)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 90,
                  height: 36,
                  child: Stack(
                    children: const [
                      Positioned(left: 0, child: AtlasAvatar.small(name: 'Sarah M')),
                      Positioned(left: 20, child: AtlasAvatar.small(name: 'Alex K')),
                      Positioned(left: 40, child: AtlasAvatar.small(name: 'Dave T')),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.smd, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: AppRadii.pillRadius,
                    border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(LucideIcons.circle_check, size: 12, color: AppColors.success),
                      SizedBox(width: 4),
                      Text(
                        'Roster Ready',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutCubic);
  }

  Widget _buildDecideTogetherGraphic(Color accent) {
    final isDark = AppColors.isDark(context);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 340, maxHeight: 260),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.cardBg(context).withValues(alpha: isDark ? 0.85 : 0.95),
        borderRadius: AppRadii.largeRadius,
        border: Border.all(color: AppColors.brd(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 25,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(LucideIcons.vote, color: accent, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Proposal',
                style: AppTextStyles.caption.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Sunset Catamaran Cruise ⛵',
            style: AppTextStyles.cardTitle.copyWith(
              color: AppColors.txtPrimary(context),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Vote Progress Bar
          ClipRRect(
            borderRadius: AppRadii.pillRadius,
            child: LinearProgressIndicator(
              value: 0.85,
              backgroundColor: AppColors.danger.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('3 of 4 agreed', style: AppTextStyles.caption.copyWith(color: AppColors.txtSecondary(context))),
              Text('85%', style: AppTextStyles.caption.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Action Chips
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: AppRadii.buttonRadius,
                    border: Border.all(color: AppColors.success),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(LucideIcons.thumbs_up, size: 14, color: AppColors.success),
                      SizedBox(width: 6),
                      Text('Agree', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.inputBg(context),
                    borderRadius: AppRadii.buttonRadius,
                    border: Border.all(color: AppColors.brd(context)),
                  ),
                  alignment: Alignment.center,
                  child: Text('Not for me', style: TextStyle(color: AppColors.txtSecondary(context), fontSize: 12)),
                ),
              ),
            ],
          )
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutCubic);
  }

  Widget _buildEverythingInOneGraphic(Color accent) {
    final isDark = AppColors.isDark(context);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 340, maxHeight: 260),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Expense Split Card
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.cardBg(context).withValues(alpha: isDark ? 0.9 : 0.98),
              borderRadius: AppRadii.cardRadius,
              border: Border.all(color: AppColors.brd(context)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08), blurRadius: 15),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBgLight(context),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(LucideIcons.wallet, color: AppColors.primaryAccent(context), size: 18),
                ),
                const SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Luau Feast Dinner', style: AppTextStyles.body.copyWith(color: AppColors.txtPrimary(context), fontWeight: FontWeight.w600)),
                    Text('Paid by Alex • Split 4 ways', style: AppTextStyles.caption.copyWith(color: AppColors.txtSecondary(context))),
                  ],
                ),
                const Spacer(),
                Text('₹4,800', style: AppTextStyles.body.copyWith(color: AppColors.primaryAccent(context), fontWeight: FontWeight.bold)),
              ],
            ),
          ).animate().slideY(begin: -0.2, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),

          const SizedBox(height: AppSpacing.sm),

          // Chat Bubble Card
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.smd),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('Flight confirmed! ✈️ See you all Friday', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ).animate().slideX(begin: 0.2, end: 0, duration: 450.ms, curve: Curves.easeOutCubic),
        ],
      ),
    );
  }
}
