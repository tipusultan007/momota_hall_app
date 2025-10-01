import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/paginated_response.dart';
import 'add_expense_screen.dart';
import 'package:intl/intl.dart';
import '../../services/permission_service.dart';
import '../../l10n/app_localizations.dart';



class ExpensesListScreen extends StatefulWidget {
  const ExpensesListScreen({super.key});
  @override
  State<ExpensesListScreen> createState() => _ExpensesListScreenState();
}

class _ExpensesListScreenState extends State<ExpensesListScreen> {
  final ApiService _apiService = ApiService();

  // 1. State Variables (Find/Replace 'Expense')
  List<dynamic> _expenses = [];
  int _currentPage = 1;
  bool _hasNextPage = true;
  bool _isLoading = true;
  bool _isLoadMoreRunning = false;

  // ** NEW STATE FOR FILTERS **
  DateTime? _startDate;
  DateTime? _endDate;
  int? _selectedCategoryId;
  String? _selectedCategoryName;

  @override
  void initState() {
    super.initState();
    _fetchInitialExpenses();
  }

  // 2. Data Fetching Methods (Find/Replace 'Expense')
  Future<void> _fetchInitialExpenses() async {
    setState(() {
      _isLoading = true;
    });

    PaginatedResponse response = await _apiService.getExpenses(
      page: 1,
      startDate: _startDate,
      endDate: _endDate,
      categoryId: _selectedCategoryId,
    );

    if (mounted) {
      setState(() {
        _expenses = response.items;
        _currentPage = 1;
        _hasNextPage = response.hasMorePages;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_hasNextPage && !_isLoading && !_isLoadMoreRunning) {
      setState(() {
        _isLoadMoreRunning = true;
      });
      _currentPage++;
      PaginatedResponse response = await _apiService.getExpenses(
        page: _currentPage,
        startDate: _startDate,
        endDate: _endDate,
        categoryId: _selectedCategoryId,
      );
      if (mounted) {
        setState(() {
          _expenses.addAll(response.items);
          _hasNextPage = response.hasMorePages;
          _isLoadMoreRunning = false;
        });
      }
    }
  }

  // --- Filter Methods ---
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => FilterSheet(
        apiService: _apiService,
        initialStartDate: _startDate,
        initialEndDate: _endDate,
        initialCategoryId: _selectedCategoryId,
        onFilterApplied: (startDate, endDate, categoryId, categoryName) {
          setState(() {
            _startDate = startDate;
            _endDate = endDate;
            _selectedCategoryId = categoryId;
            _selectedCategoryName = categoryName;
          });
          _fetchInitialExpenses();
        },
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _selectedCategoryId = null;
      _selectedCategoryName = null;
    });
    _fetchInitialExpenses();
  }

  // 3. Navigation (Find/Replace 'Expense')
  void _navigateToAddExpense() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
    );
    if (result == true) _fetchInitialExpenses();
  }

  void _navigateToEditExpense(int expenseId) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(expenseId: expenseId),
      ),
    );
    if (result == true) _fetchInitialExpenses();
  }

  @override
Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    bool hasFilters = _startDate != null || _endDate != null || _selectedCategoryId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.allExpenses),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: _showFilterSheet, tooltip: l10n.filterExpenses),
        ],
      ),
      floatingActionButton: PermissionService().can('create expenses')
          ? FloatingActionButton(onPressed: _navigateToAddExpense, child: const Icon(Icons.add), tooltip: l10n.logExpense)
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
                    onRefresh: _fetchInitialExpenses,
                    child: _expenses.isEmpty
                        ? Center(child: Text(l10n.noExpensesFound))
                        : ListView.builder(
                            itemCount: _expenses.length + (_hasNextPage ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _expenses.length) return _buildLoadMoreButton(l10n);
                              final expense = _expenses[index];
                              return Dismissible(
                                key: Key(expense['id'].toString()),
                                direction: DismissDirection.endToStart,
                                background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.symmetric(horizontal: 20.0), child: const Icon(Icons.delete, color: Colors.white)),
                                confirmDismiss: (direction) async => await showDialog(
                                  context: context,
                                  builder: (BuildContext context) => AlertDialog(
                                    title: Text(l10n.confirmDelete),
                                    content: Text(l10n.areYouSureDeleteExpense),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.cancel.toUpperCase())),
                                      TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.delete.toUpperCase())),
                                    ],
                                  ),
                                ),
                                onDismissed: (direction) async {
                                  bool deleted = await _apiService.deleteExpense(expense['id']);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(deleted ? l10n.expenseDeleted : l10n.failedToDeleteExpense)));
                                    if (deleted) setState(() => _expenses.removeAt(index));
                                  }
                                },
                                child: Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: ListTile(
                                    title: Text('৳${expense['amount'] ?? '0.00'} - ${expense['category_name'] ?? 'N/A'}'),
                                    subtitle: Text(expense['description'] ?? l10n.noDescription),
                                    trailing: PermissionService().can('edit expenses') ? IconButton(icon: const Icon(Icons.edit, color: Colors.grey), onPressed: () => _navigateToEditExpense(expense['id'])) : null,
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

  String _buildFilterSummary(AppLocalizations l10n) {
    String summary = '${l10n.filters} ';
    if (_startDate != null && _endDate != null) {
      summary += '${DateFormat.yMd().format(_startDate!)} - ${DateFormat.yMd().format(_endDate!)}';
    }
    if (_selectedCategoryId != null) {
      summary += '${(summary.length > 10 ? ' | ' : '')}${l10n.category}: $_selectedCategoryName';
    }
    return summary;
  }

  Widget _buildLoadMoreButton(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: _isLoadMoreRunning
            ? const CircularProgressIndicator()
            : OutlinedButton(onPressed: _loadMore, child: Text(l10n.loadMore)),
      ),
    );
  }
}

// ** NEW WIDGET: A Reusable Filter Sheet **
class FilterSheet extends StatefulWidget {
  final ApiService apiService;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final int? initialCategoryId;
  final Function(DateTime?, DateTime?, int?, String?) onFilterApplied;

  const FilterSheet({
    super.key,
    required this.apiService,
    this.initialStartDate,
    this.initialEndDate,
    this.initialCategoryId,
    required this.onFilterApplied,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  DateTime? _startDate;
  DateTime? _endDate;
  int? _selectedCategoryId;
  String? _selectedCategoryName;
  List<dynamic>? _categories;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    _selectedCategoryId = widget.initialCategoryId;
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final categories = await widget.apiService.getExpenseCategories();
    if (mounted) {
      setState(() {
        _categories = categories;
      });
      if (_selectedCategoryId != null) {
        _selectedCategoryName = categories.firstWhere(
          (c) => c['id'] == _selectedCategoryId,
          orElse: () => {},
        )['name'];
      }
    }
  }

  void _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
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
          _categories == null
              ? const Center(child: CircularProgressIndicator())
              : DropdownButtonFormField<int>(
                  value: _selectedCategoryId,
                  items: _categories!.map((cat) => DropdownMenuItem<int>(value: cat['id'], child: Text(cat['name']))).toList(),
                  onChanged: (value) => setState(() {
                    _selectedCategoryId = value;
                    _selectedCategoryName = _categories!.firstWhere((c) => c['id'] == value)['name'];
                  }),
                  decoration: InputDecoration(labelText: l10n.category, border: const OutlineInputBorder()),
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
              widget.onFilterApplied(_startDate, _endDate, _selectedCategoryId, _selectedCategoryName);
              Navigator.of(context).pop();
            },
            child: Text(l10n.applyFilters),
          ),
        ],
      ),
    );
  }
}
