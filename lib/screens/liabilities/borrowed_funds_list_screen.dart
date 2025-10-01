import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../models/paginated_response.dart';
import '../../services/permission_service.dart';
import 'borrowed_fund_detail_screen.dart';
import 'add_borrowed_fund_screen.dart';
import '../../l10n/app_localizations.dart';

class BorrowedFundsListScreen extends StatefulWidget {
  const BorrowedFundsListScreen({super.key});
  @override
  State<BorrowedFundsListScreen> createState() => _BorrowedFundsListScreenState();
}

class _BorrowedFundsListScreenState extends State<BorrowedFundsListScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _funds = [];
  int _currentPage = 1;
  bool _hasNextPage = true;
  bool _isLoading = true;
  bool _isLoadMoreRunning = false;
  DateTime? _startDate;
  DateTime? _endDate;
  int? _selectedLenderId;
  String? _selectedLenderName;

  @override
  void initState() {
    super.initState();
    _fetchInitialFunds();
  }

  Future<void> _fetchInitialFunds() async {
    setState(() { _isLoading = true; });
    PaginatedResponse response = await _apiService.getBorrowedFunds(page: 1, startDate: _startDate, endDate: _endDate, lenderId: _selectedLenderId);
    if (mounted) {
      setState(() {
        _funds = response.items;
        _currentPage = 1;
        _hasNextPage = response.hasMorePages;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_hasNextPage && !_isLoading && !_isLoadMoreRunning) {
      setState(() { _isLoadMoreRunning = true; });
      _currentPage++;
      PaginatedResponse response = await _apiService.getBorrowedFunds(page: _currentPage, startDate: _startDate, endDate: _endDate, lenderId: _selectedLenderId);
      if (mounted) {
        setState(() {
          _funds.addAll(response.items);
          _hasNextPage = response.hasMorePages;
          _isLoadMoreRunning = false;
        });
      }
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FilterSheet(
        apiService: _apiService,
        initialStartDate: _startDate,
        initialEndDate: _endDate,
        initialLenderId: _selectedLenderId,
        onFilterApplied: (startDate, endDate, lenderId, lenderName) {
          setState(() {
            _startDate = startDate;
            _endDate = endDate;
            _selectedLenderId = lenderId;
            _selectedLenderName = lenderName;
          });
          _fetchInitialFunds();
        },
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _selectedLenderId = null;
      _selectedLenderName = null;
    });
    _fetchInitialFunds();
  }

  void _navigateToAddFund() async {
    final result = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (context) => const AddBorrowedFundScreen()));
    if (result == true) _fetchInitialFunds();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    bool hasFilters = _startDate != null || _endDate != null || _selectedLenderId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.borrowedFunds),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: _showFilterSheet, tooltip: l10n.filterFunds),
        ],
      ),
      floatingActionButton: PermissionService().can('create liabilities')
          ? FloatingActionButton(onPressed: _navigateToAddFund, child: const Icon(Icons.add), tooltip: l10n.recordBorrowedFund)
          : null,
      body: Column(
        children: [
          if (hasFilters)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Row(
                children: [
                  Expanded(child: Text(_buildFilterSummary(l10n), style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                  IconButton(icon: const Icon(Icons.clear, size: 20), onPressed: _clearFilters, tooltip: l10n.clearFilters)
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchInitialFunds,
                    child: _funds.isEmpty
                        ? Center(child: Text(l10n.noFundsFound))
                        : ListView.builder(
                            itemCount: _funds.length + (_hasNextPage ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _funds.length) return _buildLoadMoreButton(l10n);
                              final fund = _funds[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  title: Text(fund['purpose'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text('${l10n.from} ${fund['lender_name']} ${l10n.on} ${fund['date_borrowed']}'),
                                  trailing: Chip(
                                    label: Text(_getStatusText(fund['status'], l10n)),
                                    backgroundColor: _getStatusColor(fund['status']),
                                    labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                  onTap: () async {
                                    final result = await Navigator.of(context).push<bool>(
                                      MaterialPageRoute(builder: (context) => BorrowedFundDetailScreen(borrowedFundId: fund['id'])),
                                    );
                                    if (result == true) _fetchInitialFunds();
                                  },
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

  String _buildFilterSummary(AppLocalizations l10n) {
    String summary = '${l10n.filters} ';
    if (_startDate != null && _endDate != null) {
      summary += '${DateFormat.yMd().format(_startDate!)} - ${DateFormat.yMd().format(_endDate!)}';
    }
    if (_selectedLenderId != null) {
      summary += '${(summary.length > 10 ? ' | ' : '')}${l10n.lenderSource}: $_selectedLenderName';
    }
    return summary;
  }
  
  Widget _buildLoadMoreButton(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: _isLoadMoreRunning ? const CircularProgressIndicator() : OutlinedButton(onPressed: _loadMore, child: Text(l10n.loadMore)),
      ),
    );
  }

  String _getStatusText(String? status, AppLocalizations l10n) {
    switch (status) {
      case 'Repaid': return l10n.statusRepaid;
      case 'Partially Repaid': return l10n.statusPartiallyRepaid;
      case 'Due': return l10n.statusDue;
      default: return status ?? '';
    }
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

// ** Reusable Filter Sheet Widget **
class FilterSheet extends StatefulWidget {
  final ApiService apiService;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final int? initialLenderId;
  final Function(DateTime?, DateTime?, int?, String?) onFilterApplied;

  const FilterSheet({
    super.key,
    required this.apiService,
    this.initialStartDate,
    this.initialEndDate,
    this.initialLenderId,
    required this.onFilterApplied,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  DateTime? _startDate;
  DateTime? _endDate;
  int? _selectedLenderId;
  String? _selectedLenderName;
  List<dynamic>? _lenders;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    _selectedLenderId = widget.initialLenderId;
    _fetchLenders();
  }

  Future<void> _fetchLenders() async {
    final lenders = await widget.apiService.getLenders();
    if (mounted) {
      setState(() { _lenders = lenders; });
      if (_selectedLenderId != null) {
        _selectedLenderName = lenders.firstWhere((l) => l['id'] == _selectedLenderId, orElse: () => {})['name'];
      }
    }
  }

  void _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _startDate != null && _endDate != null ? DateTimeRange(start: _startDate!, end: _endDate!) : null,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.filterOptions, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          _lenders == null
              ? const Center(child: CircularProgressIndicator())
              : DropdownButtonFormField<int>(
                  value: _selectedLenderId,
                  items: _lenders!.map((lender) => DropdownMenuItem<int>(value: lender['id'], child: Text(lender['name']))).toList(),
                  onChanged: (value) => setState(() {
                    _selectedLenderId = value;
                    _selectedLenderName = _lenders!.firstWhere((l) => l['id'] == value)['name'];
                  }),
                  decoration: InputDecoration(labelText: l10n.lenderSource, border: const OutlineInputBorder()),
                ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.calendar_month),
            label: Text(_startDate == null ? l10n.selectDateRange : '${DateFormat.yMd().format(_startDate!)} - ${DateFormat.yMd().format(_endDate!)}'),
            onPressed: _pickDateRange,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              widget.onFilterApplied(_startDate, _endDate, _selectedLenderId, _selectedLenderName);
              Navigator.of(context).pop();
            },
            child: Text(l10n.applyFilters),
          ),
        ],
      ),
    );
  }
}