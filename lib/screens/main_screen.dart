import 'package:flutter/material.dart';
import 'package:momota_hall_app/l10n/app_localizations.dart';
import 'dashboard_screen.dart';
import 'bookings/bookings_list_screen.dart';
import 'transactions/transactions_list_screen.dart';
import 'menu/menu_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // ** THE FIX: Use an IndexedStack instead of a simple List **
  // IndexedStack keeps all the pages in memory, preserving their state when you switch tabs.
  // This is a significant UX improvement.
  final List<Widget> _pages = <Widget>[
    const DashboardScreen(),
    const BookingsListScreen(),
    const TransactionsListScreen(),
    const MenuScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      // ** THE FIX: Replace 'Center' with 'IndexedStack' **
      // This directly places the selected page in the body, giving it the correct
      // screen constraints to render its ListView properly.
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: const Icon(Icons.dashboard_outlined), activeIcon: const Icon(Icons.dashboard), label: l10n.dashboardTitle),
          BottomNavigationBarItem(icon: const Icon(Icons.calendar_today_outlined), activeIcon: const Icon(Icons.calendar_today), label: l10n.bookingsTitle),
          BottomNavigationBarItem(icon: const Icon(Icons.compare_arrows_outlined), activeIcon: const Icon(Icons.compare_arrows), label: l10n.transactionsTitle),
          BottomNavigationBarItem(icon: const Icon(Icons.menu_outlined), activeIcon: const Icon(Icons.menu), label: l10n.menuTitle),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}