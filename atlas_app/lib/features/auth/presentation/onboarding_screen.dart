import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Design System
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/widgets/atlas_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Plan Together',
      'subtitle': 'Plan, chat, and split expenses with your friends all in one place.',
      'image': 'assets/images/onboarding_1.png', // Placeholder
    },
    {
      'title': 'Decide together.',
      'subtitle': 'Propose ideas and vote on dates, destinations, and activities.',
      'image': 'assets/images/onboarding_2.png', // Placeholder
    },
    {
      'title': 'Everything in\none place.',
      'subtitle': 'Track expenses, chat, and view your schedule all within Atlas.',
      'image': 'assets/images/onboarding_3.png', // Placeholder
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    if (mounted) {
      context.go('/login');
    }
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
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
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Placeholder for illustration
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              shape: BoxShape.circle,
                            ),
                            margin: const EdgeInsets.all(AppSpacing.xxl),
                            child: const Center(
                              child: Icon(
                                Icons.map_outlined,
                                size: 100,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          page['title']!,
                          style: AppTextStyles.pageTitle.copyWith(fontSize: 32),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          page['subtitle']!,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Bottom controls
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? AppColors.primary : AppColors.border,
                          borderRadius: AppRadii.pillRadius,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  SizedBox(
                    width: double.infinity,
                    child: AtlasButton(
                      label: _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                      onPressed: _nextPage,
                    ),
                  ),
                  if (_currentPage < _pages.length - 1) ...[
                    const SizedBox(height: AppSpacing.md),
                    TextButton(
                      onPressed: _completeOnboarding,
                      child: Text(
                        'Skip',
                        style: AppTextStyles.button.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
