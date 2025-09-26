import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class TransactionsListScreen extends StatefulWidget {
  const TransactionsListScreen({super.key});
  @override
  State<TransactionsListScreen> createState() => _TransactionsListScreenState();
}

class _TransactionsListScreenState extends State<TransactionsListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    // We need to create the getTransactions method in the ApiService
    _transactionsFuture = _apiService.getTransactions();
  }

  Future<void> _refreshTransactions() async {
    setState(() {
      _transactionsFuture = _apiService.getTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Transactions (Ledger)'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshTransactions,
        child: FutureBuilder<List<dynamic>>(
          future: _transactionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No transactions found.'));
            }

            final transactions = snapshot.data!;
            return ListView.separated(
              itemCount: transactions.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                final isCredit = transaction['type'] == 'credit';
                final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '৳');
                final amount = double.tryParse(transaction['amount'].toString().replaceAll(',', '')) ?? 0;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isCredit ? Colors.green.shade100 : Colors.red.shade100,
                    child: Icon(
                      isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                      color: isCredit ? Colors.green.shade700 : Colors.red.shade700,
                    ),
                  ),
                  title: Text(transaction['description'] ?? 'No description', maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: Text(transaction['date'] ?? 'No Date'),
                  trailing: Text(
                    '${isCredit ? '+' : '-'} ${currencyFormat.format(amount)}',
                    style: TextStyle(
                      color: isCredit ? Colors.green.shade700 : Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}