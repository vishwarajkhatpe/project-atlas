import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../members/presentation/members_screen.dart';
import '../../consensus/presentation/consensus_screen.dart';
import '../../itinerary/presentation/itinerary_screen.dart';
import '../../ledger/presentation/ledger_screen.dart';
import '../../chat/presentation/chat_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    final pages = [
      ItineraryScreen(tripId: widget.tripId),
      ConsensusScreen(tripId: widget.tripId),
      LedgerScreen(tripId: widget.tripId),
      ChatScreen(tripId: widget.tripId),
      MembersScreen(tripId: widget.tripId),
    ];

    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
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
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
            );
          },
          destinations: const [
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
            NavigationDestination(
              icon: Icon(LucideIcons.users),
              label: 'People',
            ),
          ],
        ),
      ),
    );
  }
}
