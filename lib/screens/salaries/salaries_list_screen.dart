import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../models/paginated_response.dart';
import 'salary_detail_screen.dart';
import '../../l10n/app_localizations.dart';

class SalariesListScreen extends StatefulWidget {
  const SalariesListScreen({super.key});
  @override
  State<SalariesListScreen> createState() => _SalariesListScreenState();
}

class _SalariesListScreenState extends State<SalariesListScreen> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();

  List<dynamic> _salaries = [];
  int _currentPage = 1;
  bool _hasNextPage = true;
  bool _isLoading = true;
  bool _isLoadMoreRunning = false;

  @override
  void initState() {
    super.initState();
    _fetchInitialSalaries();
    _scrollController.addListener(_loadMore);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_loadMore);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialSalaries() async {
    setState(() { _isLoading = true; });
    PaginatedResponse response = await _apiService.getSalaries(page: 1);
    if (mounted) {
      setState(() {
        _salaries = response.items;
        _currentPage = response.currentPage;
        _hasNextPage = response.hasMorePages;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_hasNextPage && !_isLoading && !_isLoadMoreRunning && _scrollController.position.extentAfter < 200) {
      setState(() { _isLoadMoreRunning = true; });
      _currentPage++;
      PaginatedResponse response = await _apiService.getSalaries(page: _currentPage);
      if (mounted) {
        setState(() {
          _salaries.addAll(response.items);
          _hasNextPage = response.hasMorePages;
          _isLoadMoreRunning = false;
        });
      }
    }
  }

  Future<void> _showGenerateDialog() async {
    final l10n = AppLocalizations.of(context)!;
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDatePickerMode: DatePickerMode.year,
      helpText: l10n.selectMonthAndYear,
    );
    if (picked != null) {
      String monthYear = DateFormat('yyyy-MM').format(picked);
      showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));
      bool success = await _apiService.generateSalaries(monthYear);
      Navigator.of(context).pop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? l10n.salariesGeneratedSuccess(monthYear) : l10n.failedToGenerateSalaries),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        if (success) _fetchInitialSalaries();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.manageSalaries),
        actions: [
          IconButton(
            onPressed: _showGenerateDialog,
            icon: const Icon(Icons.add_card),
            tooltip: l10n.generateSalaries,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchInitialSalaries,
              child: _salaries.isEmpty
                  ? Center(child: Text(l10n.noSalaryRecordsFound, textAlign: TextAlign.center))
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: _salaries.length + (_hasNextPage ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _salaries.length) {
                          return Padding(padding: const EdgeInsets.symmetric(vertical: 32), child: Center(child: _isLoadMoreRunning ? const CircularProgressIndicator() : OutlinedButton(onPressed: _loadMore, child: Text(l10n.loadMore))));
                        }
                        final salary = _salaries[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            title: Text(salary['worker_name'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(salary['salary_month'] ?? ''),
                            trailing: Chip(
                              label: Text(_getStatusText(salary['status'], l10n)),
                              backgroundColor: _getStatusColor(salary['status']),
                              labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            ),
                            onTap: () async {
                              final needsRefresh = await Navigator.of(context).push<bool>(
                                MaterialPageRoute(builder: (context) => SalaryDetailScreen(monthlySalaryId: salary['id'])),
                              );
                              if (needsRefresh == true) _fetchInitialSalaries();
                            },
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  String _getStatusText(String? status, AppLocalizations l10n) {
    switch (status) {
      case 'Paid': return l10n.statusPaid;
      case 'Partially Paid': return l10n.statusPartiallyPaid;
      case 'Unpaid': return l10n.statusUnpaid;
      default: return status ?? '';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Paid': return Colors.green.shade600;
      case 'Partially Paid': return Colors.orange.shade700;
      case 'Unpaid': return Colors.red.shade600;
      default: return Colors.grey;
    }
  }
}