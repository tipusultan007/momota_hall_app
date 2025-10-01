import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/paginated_response.dart';
import '../../services/permission_service.dart';
import 'add_income_screen.dart'; 
import 'package:intl/intl.dart';


class IncomesListScreen extends StatefulWidget {
  const IncomesListScreen({super.key});
  @override
  State<IncomesListScreen> createState() => _IncomesListScreenState();
}

class _IncomesListScreenState extends State<IncomesListScreen> {
  final ApiService _apiService = ApiService();

  // --- State Variables for Pagination ---
  List<dynamic> _incomes = [];
  int _currentPage = 1;
  bool _hasNextPage = true;
  bool _isLoading = true;
  bool _isLoadMoreRunning = false;


  DateTime? _startDate;
  DateTime? _endDate;
  int? _selectedCategoryId;
  String? _selectedCategoryName;

  @override
  void initState() {
    super.initState();
    _fetchInitialIncomes();
  }

  Future<void> _fetchInitialIncomes() async {
    setState(() {
      _isLoading = true;
    });

    PaginatedResponse response = await _apiService.getIncomes(
      page: 1,
      startDate: _startDate,
      endDate: _endDate,
      categoryId: _selectedCategoryId,
    );

    if (mounted) {
      setState(() {
        _incomes = response.items;
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
      PaginatedResponse response = await _apiService.getIncomes(
        page: _currentPage,
        startDate: _startDate,
        endDate: _endDate,
        categoryId: _selectedCategoryId,
      );
      if (mounted) {
        setState(() {
          _incomes.addAll(response.items);
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
          _fetchInitialIncomes();
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
    _fetchInitialIncomes();
  }

  // Navigation methods
  void _navigateToAddIncome() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const AddIncomeScreen()),
    );
    if (result == true) {
      _fetchInitialIncomes();
    }
  }

  void _navigateToEditIncome(int incomeId) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => AddIncomeScreen(incomeId: incomeId)),
    );
    if (result == true) {
      _fetchInitialIncomes();
    }
  }

    @override
  Widget build(BuildContext context) {
    // Determine if any filters are currently active
    bool hasFilters =
        _startDate != null || _endDate != null || _selectedCategoryId != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Incomes'),
        actions: [
          // Filter button in the AppBar
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
            tooltip: 'Filter Incomes',
          ),
        ],
      ),
       floatingActionButton: PermissionService().can('create income')
          ? FloatingActionButton(
              onPressed: _navigateToAddIncome,
              child: const Icon(Icons.add),
              tooltip: 'Log Income',
            )
          : null,
      body: Column(
        children: [
          // This header will only appear if filters are active
          if (hasFilters)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _buildFilterSummary(), // Call helper to build summary text
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // "Clear Filter" button
                  IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: _clearFilters,
                    tooltip: 'Clear Filters',
                  ),
                ],
              ),
            ),

          // The main list view
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchInitialIncomes,
                    child: _incomes.isEmpty
                        ? const Center(
                            child: Text(
                              'No incomess found for the selected filters.',
                            ),
                          )
                        : ListView.builder(
                            // The scroll controller is no longer needed here with the button
                            itemCount:
                                _incomes.length + (_hasNextPage ? 1 : 0),
                            itemBuilder: (context, index) {
                              // If it's the last item and there's more data, show the load more button
                              if (index == _incomes.length) {
                                return _buildLoadMoreButton();
                              }

                              final incomes = _incomes[index];
                              return Dismissible(
                                key: Key(incomes['id'].toString()),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0,
                                  ),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                confirmDismiss: (direction) async {
                                  return await showDialog(
                                    context: context,
                                    builder: (BuildContext context) => AlertDialog(
                                      title: const Text("Confirm Delete"),
                                      content: const Text(
                                        "Are you sure you wish to delete this incomes?",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: const Text("CANCEL"),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: const Text("DELETE"),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                onDismissed: (direction) async {
                                  bool deleted = await _apiService
                                      .deleteIncome(incomes['id']);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          deleted
                                              ? 'Income deleted'
                                              : 'Failed to delete incomes',
                                        ),
                                      ),
                                    );
                                    if (deleted) {
                                      setState(() {
                                        _incomes.removeAt(index);
                                      });
                                    }
                                  }
                                },
                                child: Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      '৳${incomes['amount'] ?? '0.00'} - ${incomes['category_name'] ?? 'N/A'}',
                                    ),
                                    subtitle: Text(
                                      incomes['description'] ??
                                          'No description',
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () =>
                                          _navigateToEditIncome(incomes['id']),
                                    ),
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
  
  
   String _buildFilterSummary() {
    String summary = 'Filters: ';
    if (_startDate != null && _endDate != null) {
      summary +=
          '${DateFormat.yMd().format(_startDate!)} - ${DateFormat.yMd().format(_endDate!)}';
    }
    if (_selectedCategoryId != null) {
      summary +=
          '${(summary.length > 10 ? ' | ' : '')}Category: $_selectedCategoryName';
    }
    return summary;
  }

  // 5. Load More Button Helper
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
    final categories = await widget.apiService.getIncomeCategories();
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Filter Options', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          _categories == null
              ? const Center(child: CircularProgressIndicator())
              : DropdownButtonFormField<int>(
                  value: _selectedCategoryId,
                  items: _categories!
                      .map(
                        (cat) => DropdownMenuItem<int>(
                          value: cat['id'],
                          child: Text(cat['name']),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() {
                    _selectedCategoryId = value;
                    _selectedCategoryName = _categories!.firstWhere(
                      (c) => c['id'] == value,
                    )['name'];
                  }),
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.calendar_month),
            label: Text(
              _startDate == null
                  ? 'Select Date Range'
                  : '${DateFormat.yMd().format(_startDate!)} - ${DateFormat.yMd().format(_endDate!)}',
            ),
            onPressed: _pickDateRange,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              widget.onFilterApplied(
                _startDate,
                _endDate,
                _selectedCategoryId,
                _selectedCategoryName,
              );
              Navigator.of(context).pop();
            },
            child: const Text('Apply Filters'),
          ),
        ],
      ),
    );
  }
}
