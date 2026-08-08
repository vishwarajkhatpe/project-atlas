import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../members/presentation/members_screen.dart';
import '../../consensus/presentation/consensus_screen.dart';
import '../../itinerary/presentation/itinerary_screen.dart';
import '../../ledger/presentation/ledger_screen.dart';
import '../../chat/presentation/chat_screen.dart';

class TripDetailsScreen extends ConsumerStatefulWidget {
  final String tripId;

  const TripDetailsScreen({super.key, required this.tripId});

  @override
  ConsumerState<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends ConsumerState<TripDetailsScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Content pages for the bottom navigation
    final pages = [
      ItineraryScreen(tripId: widget.tripId),
      ConsensusScreen(tripId: widget.tripId),
      LedgerScreen(tripId: widget.tripId),
      ChatScreen(tripId: widget.tripId),
      MembersScreen(tripId: widget.tripId),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(LucideIcons.calendar),
              label: 'Itinerary',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.vote),
              label: 'Consensus',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.wallet),
              label: 'Ledger',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.message_circle),
              label: 'Chat',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.users),
              label: 'Members',
            ),
          ],
        ),
      ),
    );
  }
}

