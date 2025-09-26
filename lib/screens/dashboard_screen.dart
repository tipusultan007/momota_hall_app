import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <-- 1. Add this import
import 'login_screen.dart'; // <-- 2. Add this import

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    // Keep the loading state true if we are fetching for the first time
    if (_stats == null) setState(() => _isLoading = true);
    final stats = await _apiService.getDashboardStats();
    if (mounted) {
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    }
  }


    Future<void> _logout(BuildContext context) async {
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
      // Clear the saved token
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      
      // Navigate to the LoginScreen and clear the navigation stack
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
      // The AppBar is now simpler as navigation is handled by the bottom bar
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: () => _logout(context), // <-- THE FIX
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stats == null
              ? Center(child: ElevatedButton(onPressed: _fetchStats, child: const Text('Retry')))
              : RefreshIndicator(
                  onRefresh: _fetchStats,
                  child: ListView( // Use ListView for better responsiveness
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      _buildWelcomeHeader(),
                      const SizedBox(height: 24),
                      GridView.count(
                        physics: const NeverScrollableScrollPhysics(), // Important for nested scrolling
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.2, // Adjust aspect ratio for a better look
                        children: <Widget>[
                          _buildStatCard(
                            'Upcoming Bookings',
                            _stats!['upcomingBookingsCount'].toString(),
                            Icons.event_available, // <-- FIX: A great icon for available/upcoming events
                            Theme.of(context).primaryColor,
                          ),
                          _buildStatCard(
                            'Outstanding Dues',
                            '৳${_stats!['totalOutstandingDues']}',
                            Icons.request_quote_outlined, // <-- FIX: Represents quotes/invoices
                            Colors.red.shade600,
                          ),
                          _buildStatCard(
                            'Bookings This Month',
                            _stats!['bookingsThisMonth'].toString(),
                            Icons.add_to_photos_outlined, // <-- FIX: Represents adding new items
                            Colors.orange.shade700,
                          ),
                          _buildStatCard(
                            'Revenue This Month',
                            '৳${_stats!['revenueThisMonth']}',
                            Icons.attach_money, // <-- FIX: A cleaner, more direct icon for money
                            Colors.green.shade600,
                          ),
                        ],
                      ),
                      // You can add more dashboard elements here, like recent transactions
                    ],
                  ),
                ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat('EEEE, MMMM d').format(DateTime.now()),
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Text(
          'Welcome Back!', // Eventually, you can use the logged-in user's name
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}