import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../models/paginated_response.dart';

class TransactionsListScreen extends StatefulWidget {
  const TransactionsListScreen({super.key});
  @override
  State<TransactionsListScreen> createState() => _TransactionsListScreenState();
}

class _TransactionsListScreenState extends State<TransactionsListScreen> {
  final ApiService _apiService = ApiService();

  // --- State Variables ---
  List<dynamic> _transactions = [];
  int _currentPage = 1;
  bool _hasNextPage = true;
  bool _isLoading = true;
  bool _isLoadMoreRunning = false;

  // ** NEW STATE FOR DATE FILTERING **
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchInitialTransactions();
  }

  // Fetches the first page of data
  Future<void> _fetchInitialTransactions() async {
    setState(() {
      _isLoading = true;
    });

    PaginatedResponse response = await _apiService.getTransactions(
      page: 1,
      startDate: _startDate,
      endDate: _endDate,
    );

    if (mounted) {
      setState(() {
        _transactions = response.items;
        _currentPage = 1; // Reset to page 1
        _hasNextPage = response.hasMorePages;
        _isLoading = false;
      });
    }
  }

  // Fetches subsequent pages
  Future<void> _loadMore() async {
    if (_hasNextPage && !_isLoading && !_isLoadMoreRunning) {
      setState(() {
        _isLoadMoreRunning = true;
      });

      _currentPage++;
      PaginatedResponse response = await _apiService.getTransactions(
        page: _currentPage,
        startDate: _startDate,
        endDate: _endDate,
      );

      if (mounted) {
        setState(() {
          _transactions.addAll(response.items);
          _hasNextPage = response.hasMorePages;
          _isLoadMoreRunning = false;
        });
      }
    }
  }

  // ** NEW METHOD TO SHOW THE DATE RANGE PICKER **
  Future<void> _showDateRangePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      // After picking a new date range, fetch the data again from page 1
      _fetchInitialTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions Ledger'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showDateRangePicker,
            tooltip: 'Filter by Date Range',
          ),
        ],
      ),
      body: Column(
        children: [
          // ** NEW HEADER TO SHOW THE CURRENT FILTER **
          Container(
            width: double.infinity,
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_month, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Showing: ${DateFormat.yMMMd().format(_startDate)} - ${DateFormat.yMMMd().format(_endDate)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchInitialTransactions,
                    child: _transactions.isEmpty
                        ? const Center(
                            child: Text(
                              'No transactions found for this period.',
                            ),
                          )
                        : ListView.separated(
                            // The scroll controller is only needed for infinite scroll, not load more button
                            itemCount:
                                _transactions.length + (_hasNextPage ? 1 : 0),
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              if (index == _transactions.length) {
                                return _buildLoadMoreButton();
                              }
                              // The ListTile builder remains the same as your existing code
                              final transaction = _transactions[index];
                              final isCredit = transaction['type'] == 'credit';
                              final currencyFormat = NumberFormat.currency(
                                locale: 'en_IN',
                                symbol: '৳',
                              );
                              final amount = (transaction['amount'] is num)
                                  ? transaction['amount']
                                  : double.tryParse(
                                          transaction['amount']
                                              .toString()
                                              .replaceAll(',', ''),
                                        ) ??
                                        0.0;

                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isCredit
                                      ? Colors.green.shade100
                                      : Colors.red.shade100,
                                  child: Icon(
                                    isCredit
                                        ? Icons.arrow_downward
                                        : Icons.arrow_upward,
                                    color: isCredit
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                                  ),
                                ),
                                title: Text(
                                  transaction['description'] ??
                                      'No description',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  transaction['date'] ?? 'No Date',
                                ),
                                trailing: Text(
                                  '${isCredit ? '+' : '-'} ${currencyFormat.format(amount)}',
                                  style: TextStyle(
                                    color: isCredit
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  // ** NEW HELPER WIDGET FOR THE "LOAD MORE" BUTTON **
  Widget _buildLoadMoreButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: _isLoadMoreRunning
            ? const CircularProgressIndicator()
            : OutlinedButton(
                onPressed: _loadMore,
                child: const Text('Load More'),
              ),
      ),
    );
  }
}
