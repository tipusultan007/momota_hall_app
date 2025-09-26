// lib/screens/menu/menu_screen.dart
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../expenses/expenses_list_screen.dart';
import '../incomes/incomes_list_screen.dart';
import '../salaries/salaries_list_screen.dart';
import '../workers/workers_list_screen.dart';
import '../liabilities/borrowed_funds_list_screen.dart';
import '../lenders/lenders_list_screen.dart';
import '../login_screen.dart'; // For logout
import 'package:shared_preferences/shared_preferences.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    // Show a confirmation dialog before logging out
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Logout')),
          ],
        );
      },
    );
    
    if (confirmed == true) {
      // Clear the token from shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      
      // Navigate to the LoginScreen and remove all previous routes
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
      ),
      body: ListView(
        children: [
          _buildCategoryHeader('Financial Management'),
          _buildMenuTile(context, 'Other Income', Icons.trending_up, const IncomesListScreen()),
          _buildMenuTile(context, 'Expenses', Icons.trending_down, const ExpensesListScreen()),
          
          const Divider(),
          _buildCategoryHeader('HR & Salaries'),
          _buildMenuTile(context, 'Manage Salaries', Icons.payment, const SalariesListScreen()),
          _buildMenuTile(context, 'Manage Workers', Icons.people_outline, const WorkersListScreen()),
          
          const Divider(),
          _buildCategoryHeader('Liabilities'),
          _buildMenuTile(context, 'Borrowed Funds', Icons.account_balance, const BorrowedFundsListScreen()),
          _buildMenuTile(context, 'Manage Lenders', Icons.business_center_outlined, const LendersListScreen()),

          const Divider(),
          _buildCategoryHeader('Account'),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildMenuTile(BuildContext context, String title, IconData icon, Widget screen) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => screen),
        );
      },
    );
  }
}