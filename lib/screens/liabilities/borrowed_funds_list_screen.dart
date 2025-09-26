import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'borrowed_fund_detail_screen.dart';
import 'add_borrowed_fund_screen.dart';

class BorrowedFundsListScreen extends StatefulWidget {
  const BorrowedFundsListScreen({super.key});
  @override
  State<BorrowedFundsListScreen> createState() => _BorrowedFundsListScreenState();
}

class _BorrowedFundsListScreenState extends State<BorrowedFundsListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _fundsFuture;

  @override
  void initState() {
    super.initState();
    _fundsFuture = _apiService.getBorrowedFunds();
  }

  void _refresh() {
    setState(() { _fundsFuture = _apiService.getBorrowedFunds(); });
  }

  void _navigateToAddFund() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const AddBorrowedFundScreen()),
    );
    if (result == true) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Borrowed Funds')),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddFund,
        child: const Icon(Icons.add),
        tooltip: 'Record Borrowed Fund',
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: FutureBuilder<List<dynamic>>(
          future: _fundsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No borrowed funds recorded.'));
            }
            
            final funds = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 80), // Padding for the FAB
              itemCount: funds.length,
              itemBuilder: (context, index) {
                final fund = funds[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(fund['purpose'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('From: ${fund['lender_name']} on ${fund['date_borrowed']}'),
                    trailing: Chip(
                      label: Text(fund['status']),
                      backgroundColor: _getStatusColor(fund['status']),
                      labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    onTap: () async {
                      final result = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(builder: (context) => BorrowedFundDetailScreen(borrowedFundId: fund['id'])),
                      );
                      if (result == true) _refresh();
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Repaid': return Colors.green.shade600;
      case 'Partially Repaid': return Colors.orange.shade700;
      case 'Due': return Colors.red.shade600;
      default: return Colors.grey;
    }
  }
}