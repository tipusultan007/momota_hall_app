import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../models/paginated_response.dart';
import './transactions/transactions_list_screen.dart';
import '../l10n/app_localizations.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _stats;
  List<dynamic> _recentTransactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (mounted) setState(() => _isLoading = true);
    
    // Fetch dashboard stats and recent transactions in parallel
    final results = await Future.wait([
      _apiService.getDashboardStats(),
      _apiService.getTransactions(page: 1), // Fetch first page of transactions
    ]);

    if (mounted) {
      setState(() {
        _stats = results[0] as Map<String, dynamic>?;
        if (results[1] != null) {
          _recentTransactions = (results[1] as PaginatedResponse).items;
        }
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboardTitle),
        actions: [
          IconButton(
            onPressed: () { /* TODO: Implement Logout */ },
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stats == null
              ? Center(child: ElevatedButton(onPressed: _fetchData, child: const Text('Retry')))
              : RefreshIndicator(
                  onRefresh: _fetchData,
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      _buildWelcomeHeader(),
                      const SizedBox(height: 24),
                      GridView.count(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.5, // Taller cards
                        children: <Widget>[
                          _buildStatCard(
                            l10n.revenueThisMonth,
                            '৳${_stats!['revenueThisMonth']}',
                            Icons.arrow_upward,
                            [Colors.green.shade600, Colors.green.shade400],
                          ),
                          _buildStatCard(
                            l10n.outstandingDues,
                            '৳${_stats!['totalOutstandingDues']}',
                            Icons.hourglass_top,
                            [Colors.orange.shade700, Colors.orange.shade400],
                          ),
                          _buildStatCard(
                            l10n.upcomingBookings,
                            _stats!['upcomingBookingsCount'].toString(),
                            Icons.event,
                            [Colors.blue.shade700, Colors.blue.shade400],
                          ),
                          _buildStatCard(
                            l10n.totalOwed,
                            '৳${_stats!['totalOwed'] ?? '0.00'}',
                            Icons.arrow_downward,
                            [Colors.red.shade700, Colors.red.shade400],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildRecentTransactions(),
                    ],
                  ),
                ),
    );
  }

 Widget _buildWelcomeHeader() { // <-- 1. Remove the parameter
    // 2. Get the localization object directly from the context
    final l10n = AppLocalizations.of(context)!;
    
    final userName = AuthService().userName ?? 'User';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat('EEEE, MMMM d', l10n.localeName).format(DateTime.now()), // Pass locale for correct date format
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.welcomeBack(userName), // 3. This now works perfectly
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, List<Color> gradientColors) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: gradientColors[1].withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: Colors.white.withOpacity(0.8)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  title,
                  style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Activity', style: Theme.of(context).textTheme.titleLarge),
            TextButton(
              onPressed: () {
                // Navigate to the full transactions list
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TransactionsListScreen()));
              },
              child: const Text('View All'),
            )
          ],
        ),
        const SizedBox(height: 8),
        _recentTransactions.isEmpty
            ? const Card(child: Padding(padding: EdgeInsets.all(32.0), child: Center(child: Text('No recent transactions.'))))
            : Card(
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _recentTransactions.length > 5 ? 5 : _recentTransactions.length, // Show max 5
                  separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (context, index) {
                    final transaction = _recentTransactions[index];
                    final isCredit = transaction['type'] == 'credit';
                    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '৳');
                    final amount = double.tryParse(transaction['amount'].toString().replaceAll(',', '')) ?? 0.0;
                    return ListTile(
                      leading: Icon(
                        isCredit ? Icons.arrow_circle_down : Icons.arrow_circle_up,
                        color: isCredit ? Colors.green : Colors.red,
                      ),
                      title: Text(transaction['description'], maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(transaction['date']),
                      trailing: Text(
                        currencyFormat.format(amount),
                        style: TextStyle(fontWeight: FontWeight.bold, color: isCredit ? Colors.green : Colors.red),
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }
}