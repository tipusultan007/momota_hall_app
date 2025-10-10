import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
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

  // Global keys to manage the state of each tab's navigator
  final _dashboardNavigatorKey = GlobalKey<NavigatorState>();
  final _bookingsNavigatorKey = GlobalKey<NavigatorState>();
  final _transactionsNavigatorKey = GlobalKey<NavigatorState>();
  final _menuNavigatorKey = GlobalKey<NavigatorState>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      DashboardScreen(key: _dashboardNavigatorKey),
      BookingsListScreen(key: _bookingsNavigatorKey),
      // ...
    ];
  }

  void _onItemTapped(int index) {
    // If the user taps the same tab again, pop to the first route in that tab's stack
    if (_selectedIndex == index) {
      switch (index) {
        case 0: _dashboardNavigatorKey.currentState?.popUntil((route) => route.isFirst); break;
        case 1: _bookingsNavigatorKey.currentState?.popUntil((route) => route.isFirst); break;
        case 2: _transactionsNavigatorKey.currentState?.popUntil((route) => route.isFirst); break;
        case 3: _menuNavigatorKey.currentState?.popUntil((route) => route.isFirst); break;
      }
    } else {
      setState(() { _selectedIndex = index; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: <Widget>[
          _buildOffstageNavigator(0, _dashboardNavigatorKey, const DashboardScreen()),
          _buildOffstageNavigator(1, _bookingsNavigatorKey, const BookingsListScreen()),
          _buildOffstageNavigator(2, _transactionsNavigatorKey, const TransactionsListScreen()),
          _buildOffstageNavigator(3, _menuNavigatorKey, const MenuScreen()),
        ],
      ),
    bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: const Icon(Icons.dashboard_outlined), activeIcon: const Icon(Icons.dashboard), label: l10n.dashboardTitle),
          BottomNavigationBarItem(icon: const Icon(Icons.calendar_today_outlined), activeIcon: const Icon(Icons.calendar_today), label: l10n.bookingsTitle),
          BottomNavigationBarItem(icon: const Icon(Icons.compare_arrows_outlined), activeIcon: const Icon(Icons.compare_arrows), label: l10n.transactionsTitle), // Replace with your translation key
          BottomNavigationBarItem(icon: const Icon(Icons.menu_outlined), activeIcon: const Icon(Icons.menu), label: l10n.menuTitle),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        
        // --- STYLING CHANGES ---
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).primaryColor,
        
        // Active (Selected) Item Style
        selectedItemColor: Colors.white,
        selectedFontSize: 12,
        
        // Inactive (Unselected) Item Style
        unselectedItemColor: Colors.white.withOpacity(0.7), // Made slightly more visible
        
        // ** THE FIX: Show labels for inactive items **
        showUnselectedLabels: true,
        unselectedFontSize: 12, // Ensure font size is consistent
      ),
    );
  }

  // Helper widget to create a Navigator for each tab
  Widget _buildOffstageNavigator(int index, GlobalKey<NavigatorState> navigatorKey, Widget initialRoute) {
    return Offstage(
      offstage: _selectedIndex != index,
      child: Navigator(
        key: navigatorKey,
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
            builder: (context) => initialRoute,
          );
        },
      ),
    );
  }
}