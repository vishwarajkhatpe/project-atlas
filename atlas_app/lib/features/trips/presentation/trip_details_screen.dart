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

class TripDetailsScreen extends ConsumerStatefulWidget {
  final String tripId;

  const TripDetailsScreen({super.key, required this.tripId});

  @override
  ConsumerState<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends ConsumerState<TripDetailsScreen> {
  int _currentIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
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
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
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
        if (!didPop) {
          _navigateToPage(0);
        }
      },
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          physics: const ClampingScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.card,
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: NavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedIndex: _currentIndex,
          onDestinationSelected: _navigateToPage,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.calendar),
              label: 'Plan',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.vote),
              label: 'Decisions',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.wallet),
              label: 'Expenses',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.message_circle),
              label: 'Chat',
            ),
          ],
        ),
      ),
      ),
    );
  }
}
