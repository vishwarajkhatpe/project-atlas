import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../consensus/presentation/consensus_screen.dart';
import '../../consensus/presentation/proposal_controller.dart';
import '../../itinerary/presentation/itinerary_screen.dart';
import '../../ledger/presentation/ledger_screen.dart';
import '../../chat/presentation/chat_screen.dart';
import 'trip_overview_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class TripDetailsScreen extends ConsumerStatefulWidget {
  final String tripId;
  final int initialIndex;

  const TripDetailsScreen({
    super.key, 
    required this.tripId,
    this.initialIndex = 0,
  });

  @override
  ConsumerState<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends ConsumerState<TripDetailsScreen> {
  late int _currentIndex;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToPage(int index) {
    if (_currentIndex != index) {
      HapticFeedback.lightImpact();
      setState(() {
        _currentIndex = index;
      });
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _scrubToPage(int index) {
    if (_currentIndex != index) {
      HapticFeedback.selectionClick();
      setState(() {
        _currentIndex = index;
      });
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final accent = AppColors.primaryAccent(context);

    // Real-time badge indicators
    final proposalsAsync = ref.watch(tripProposalsProvider(widget.tripId));

    final openProposalsCount = proposalsAsync.maybeWhen(
      data: (proposals) => proposals.where((p) => p['status'] == 'pending').length,
      orElse: () => 0,
    );

    final pages = [
      TripOverviewScreen(
        tripId: widget.tripId,
        onNavigateToPlan: () => _navigateToPage(1),
        onNavigateToDecisions: () => _navigateToPage(2),
        onNavigateToChat: () => _navigateToPage(4),
      ),
      ItineraryScreen(tripId: widget.tripId),
      ConsensusScreen(tripId: widget.tripId),
      LedgerScreen(tripId: widget.tripId),
      ChatScreen(tripId: widget.tripId),
    ];

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentIndex != 0) {
          _navigateToPage(0);
        }
      },
      child: Scaffold(
        extendBody: true,
        body: PageView(
          controller: _pageController,
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          onPageChanged: (index) {
            if (_currentIndex != index) {
              setState(() {
                _currentIndex = index;
              });
            }
          },
          children: pages.map((page) => RepaintBoundary(child: page)).toList(),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  // Primary ambient colored glow
                  BoxShadow(
                    color: accent.withValues(alpha: isDark ? 0.16 : 0.08),
                    blurRadius: 28,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                  // Deep diffused grounding drop shadow
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.10),
                    blurRadius: 18,
                    spreadRadius: 0,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0F172A).withValues(alpha: 0.82)
                          : Colors.white.withValues(alpha: 0.86),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.14)
                            : Colors.white.withValues(alpha: 0.85),
                        width: 1.2,
                      ),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final itemWidth = constraints.maxWidth / 5;
                        return GestureDetector(
                          onHorizontalDragStart: (details) {
                            final targetIndex = (details.localPosition.dx / itemWidth).floor().clamp(0, 4);
                            _scrubToPage(targetIndex);
                          },
                          onHorizontalDragUpdate: (details) {
                            final targetIndex = (details.localPosition.dx / itemWidth).floor().clamp(0, 4);
                            _scrubToPage(targetIndex);
                          },
                          child: AnimatedBuilder(
                            animation: _pageController,
                            builder: (context, child) {
                              double pageValue = _currentIndex.toDouble();
                              if (_pageController.hasClients && _pageController.position.hasContentDimensions) {
                                pageValue = _pageController.page ?? _currentIndex.toDouble();
                              }
                              final pillLeft = pageValue * itemWidth + 5;

                              return Stack(
                                children: [
                                  // 1:1 Sliding Fluid Glass Pill with Micro-Shimmer Highlight
                                  Positioned(
                                    left: pillLeft.clamp(5.0, constraints.maxWidth - itemWidth + 5),
                                    top: 5,
                                    bottom: 5,
                                    width: itemWidth - 10,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            accent.withValues(alpha: isDark ? 0.22 : 0.14),
                                            accent.withValues(alpha: isDark ? 0.10 : 0.05),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(26),
                                        border: Border.all(
                                          color: accent.withValues(alpha: isDark ? 0.35 : 0.22),
                                          width: 1,
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          // Top specular glow line inside pill
                                          Positioned(
                                            top: 2,
                                            left: 14,
                                            right: 14,
                                            child: Container(
                                              height: 1.5,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.transparent,
                                                    accent.withValues(alpha: 0.6),
                                                    Colors.transparent,
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(1),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Tab Items Row
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildNavItem(
                                          index: 0,
                                          icon: LucideIcons.house,
                                          label: 'Home',
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildNavItem(
                                          index: 1,
                                          icon: LucideIcons.calendar,
                                          label: 'Plan',
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildNavItem(
                                          index: 2,
                                          icon: LucideIcons.vote,
                                          label: 'Decisions',
                                          badgeCount: openProposalsCount,
                                          badgeColor: AppColors.violet,
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildNavItem(
                                          index: 3,
                                          icon: LucideIcons.receipt,
                                          label: 'Expenses',
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildNavItem(
                                          index: 4,
                                          icon: LucideIcons.message_circle,
                                          label: 'Chat',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    int badgeCount = 0,
    Color? badgeColor,
  }) {
    final isSelected = _currentIndex == index;
    final accent = AppColors.primaryAccent(context);
    final unselectedColor = AppColors.txtMuted(context);

    return GestureDetector(
      onTap: () => _navigateToPage(index),
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with Micro-Spring Scale & Dynamic Badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedScale(
                  scale: isSelected ? 1.14 : 1.0,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutBack,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      icon,
                      size: 20,
                      color: isSelected ? accent : unselectedColor,
                    ),
                  ),
                ),
                if (badgeCount > 0)
                  Positioned(
                    top: -4,
                    right: -9,
                    child: AnimatedScale(
                      scale: 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: badgeColor ?? accent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.isDark(context) ? const Color(0xFF0F172A) : Colors.white,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (badgeColor ?? accent).withValues(alpha: 0.45),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          badgeCount > 9 ? '9+' : '$badgeCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            // Text Label with Animated Color & Weight
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? accent : unselectedColor,
                letterSpacing: isSelected ? -0.1 : 0,
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

