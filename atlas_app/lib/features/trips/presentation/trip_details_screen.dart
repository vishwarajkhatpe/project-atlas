import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../consensus/presentation/consensus_screen.dart';
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
      HapticFeedback.selectionClick();
    }
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  void _scrubToPage(int index) {
    if (_currentIndex != index) {
      HapticFeedback.selectionClick();
      setState(() {
        _currentIndex = index;
      });
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            padding: EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.xs),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.cardBg(context).withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: AppColors.brd(context),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 18,
                    spreadRadius: 1,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
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
                          final pillLeft = pageValue * itemWidth + 4;

                          return Stack(
                            children: [
                              // Continuous 1:1 Horizontal Sliding Active Pill Indicator
                              Positioned(
                                left: pillLeft.clamp(4.0, constraints.maxWidth - itemWidth + 4),
                                top: 4,
                                bottom: 4,
                                width: itemWidth - 8,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryAccent(context).withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: AppColors.primaryAccent(context).withValues(alpha: 0.25),
                                      width: 1,
                                    ),
                                  ),
                                ),
                              ),
                              // Tab Items Row
                              Row(
                                children: [
                                  Expanded(child: _buildNavItem(0, LucideIcons.house, 'Home')),
                                  Expanded(child: _buildNavItem(1, LucideIcons.calendar, 'Plan')),
                                  Expanded(child: _buildNavItem(2, LucideIcons.vote, 'Decisions')),
                                  Expanded(child: _buildNavItem(3, LucideIcons.receipt, 'Expenses')),
                                  Expanded(child: _buildNavItem(4, LucideIcons.message_circle, 'Chat')),
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
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _navigateToPage(index),
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.primaryAccent(context) : AppColors.txtMuted(context),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primaryAccent(context) : AppColors.txtMuted(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
