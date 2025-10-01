import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../expenses/expenses_list_screen.dart';
import '../incomes/incomes_list_screen.dart';
import '../salaries/salaries_list_screen.dart';
import '../workers/workers_list_screen.dart';
import '../liabilities/borrowed_funds_list_screen.dart';
import '../lenders/lenders_list_screen.dart';
import '../login_screen.dart';
import '../../services/auth_service.dart';
import '../../services/permission_service.dart';
import '../../providers/locale_provider.dart';
import '../../l10n/app_localizations.dart';
import 'about_screen.dart'; 


class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  // Simplified and corrected logout method
  Future<void> _logout(BuildContext context) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.confirmLogout),
          content: Text(l10n.areYouSureLogout),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.cancel)),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.logout)),
          ],
        );
      },
    );
    
    if (confirmed == true) {
      // This single call now handles clearing the token AND permissions
      await AuthService().clearAuthData();
      
      if (context.mounted) {
        // Use the root navigator to clear the entire navigation stack
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final permissions = PermissionService(); 
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.menuTitle),
      ),
      body: ListView(
        children: [
          // Conditionally render the entire Financial Management section
          if (permissions.can('view income') || permissions.can('view expenses')) ...[
            _buildCategoryHeader(l10n.financialManagement),
            if (permissions.can('view income'))
              _buildMenuTile(context, l10n.otherIncome, Icons.trending_up, const IncomesListScreen()),
            if (permissions.can('view expenses'))
              _buildMenuTile(context, l10n.expenses, Icons.trending_down, const ExpensesListScreen()),
            const Divider(),
          ],
          
          // Conditionally render the entire HR & Salaries section
          if (permissions.can('view workers') || permissions.can('view salaries')) ...[
            _buildCategoryHeader(l10n.hrAndSalaries),
            if (permissions.can('view salaries'))
              _buildMenuTile(context, l10n.manageSalaries, Icons.payment, const SalariesListScreen()),
            if (permissions.can('view workers'))
              _buildMenuTile(context, l10n.manageWorkers, Icons.people_outline, const WorkersListScreen()),
            const Divider(),
          ],
          
          // Conditionally render the entire Liabilities section
          if (permissions.can('view liabilities') || permissions.can('manage lenders')) ...[
            _buildCategoryHeader(l10n.liabilities),
            if (permissions.can('view liabilities'))
              _buildMenuTile(context, l10n.borrowedFunds, Icons.account_balance, const BorrowedFundsListScreen()),
            if (permissions.can('manage lenders'))
              _buildMenuTile(context, l10n.manageLenders, Icons.business_center_outlined, const LendersListScreen()),
            const Divider(),
          ],

           const Divider(),
          _buildCategoryHeader(l10n.language), // <-- New category header

          // ** THE NEW LANGUAGE SWITCHER WIDGET **
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.changeLanguage),
            trailing: DropdownButton<Locale>(
              value: Provider.of<LocaleProvider>(context).locale ?? const Locale('en'), // Default to English
              underline: const SizedBox(), // Hide the default underline
              items: const [
                DropdownMenuItem(value: Locale('en'), child: Text('English')),
                DropdownMenuItem(value: Locale('bn'), child: Text('বাংলা')),
              ],
              onChanged: (Locale? newLocale) {
                if (newLocale != null) {
                  // Use the provider to set the new locale
                  Provider.of<LocaleProvider>(context, listen: false).setLocale(newLocale);
                }
              },
            ),
          ),

          // -- Account Section --
          _buildCategoryHeader('Account'),

           _buildMenuTile(
            context,
            'About This App', // Or use l10n.aboutApp
            Icons.info_outline,
            const AboutScreen(),
          ),

          // ** NEW "My Permissions" WIDGET **
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: ExpansionTile(
              leading: const Icon(Icons.shield_outlined),
              title: Text(l10n.myPermissions),
              children: <Widget>[
                if (permissions.getAllPermissions().isEmpty)
                  ListTile(title: Text(l10n.noPermissionsFound))
                else
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: permissions.getAllPermissions().map((permission) {
                        return Chip(
                          label: Text(permission),
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                          labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(l10n.logout, style: const TextStyle(color: Colors.red)),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets (Unchanged) ---
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