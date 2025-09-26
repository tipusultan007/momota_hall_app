// lib/screens/lenders/lender_detail_screen.dart
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../liabilities/borrowed_fund_detail_screen.dart'; // For navigation

class LenderDetailScreen extends StatefulWidget {
  final int lenderId;
  const LenderDetailScreen({super.key, required this.lenderId});
  @override
  State<LenderDetailScreen> createState() => _LenderDetailScreenState();
}

class _LenderDetailScreenState extends State<LenderDetailScreen> {
  final ApiService _apiService = ApiService();
  late Future<Map<String, dynamic>?> _detailsFuture;

  @override
  void initState() {
    super.initState();
    _detailsFuture = _apiService.getLenderDetails(widget.lenderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lender History')),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Failed to load lender details.'));
          }

          final details = snapshot.data!;
          final lender = details['lender'];
          final history = details['history'] as List;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Lender Info Card
                _buildLenderInfoCard(lender, context),
                const SizedBox(height: 24),
                
                // Loan History Section
                Text(
                  'Loan History',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Divider(),
                if (history.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No loan records found for this lender.'),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final fund = history[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(fund['purpose']),
                          subtitle: Text('Borrowed on: ${fund['date_borrowed']}'),
                          trailing: Chip(
                            label: Text(fund['status']),
                            backgroundColor: _getStatusColor(fund['status']),
                            labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          onTap: () {
                            // Navigate to the repayment screen for this specific loan
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => BorrowedFundDetailScreen(borrowedFundId: fund['id']),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLenderInfoCard(Map<String, dynamic> lender, BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lender['name'], style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(lender['contact_person'] ?? '', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(lender['phone'] ?? '', style: Theme.of(context).textTheme.titleMedium),
            if (lender['notes'] != null && lender['notes'].isNotEmpty) ...[
              const Divider(height: 24),
              Text(lender['notes']),
            ]
          ],
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