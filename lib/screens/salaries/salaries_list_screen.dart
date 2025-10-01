import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../models/paginated_response.dart'; // <-- ** IMPORTANT: Import your new model **
import 'salary_detail_screen.dart';

class SalariesListScreen extends StatefulWidget {
  const SalariesListScreen({super.key});
  @override
  State<SalariesListScreen> createState() => _SalariesListScreenState();
}

class _SalariesListScreenState extends State<SalariesListScreen> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();

  // --- NEW STATE VARIABLES FOR PAGINATION ---
  List<dynamic> _salaries = [];
  int _currentPage = 1;
  bool _hasNextPage = true;
  bool _isLoading = true; // For the initial load
  bool _isLoadMoreRunning = false; // To prevent multiple load more calls
  // ------------------------------------------

  @override
  void initState() {
    super.initState();
    _fetchInitialSalaries();
    _scrollController.addListener(_loadMore); // Add the scroll listener
  }

  @override
  void dispose() {
    _scrollController.removeListener(_loadMore);
    _scrollController.dispose();
    super.dispose();
  }

  // Fetches the first page of data (used for initial load and pull-to-refresh)
  Future<void> _fetchInitialSalaries() async {
    setState(() {
      _isLoading = true; // Show main loading indicator
    });
    
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

  // Fetches the next page of data when the user scrolls to the bottom
  Future<void> _loadMore() async {
    if (_hasNextPage && !_isLoading && !_isLoadMoreRunning && _scrollController.position.extentAfter < 200) {
      setState(() {
        _isLoadMoreRunning = true; // Show loading indicator at the bottom
      });
      
      _currentPage += 1; // Go to the next page
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
  
  // Your existing _showGenerateDialog method remains perfect. No changes needed.
  Future<void> _showGenerateDialog() async { /* ... same as your existing code ... */
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'Select Month and Year to Generate',
    );
    if (picked != null) {
      String monthYear = DateFormat('yyyy-MM').format(picked);
      showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));
      bool success = await _apiService.generateSalaries(monthYear);
      Navigator.of(context).pop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Salaries for $monthYear generated successfully!' : 'Failed to generate salaries.'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        if (success) _fetchInitialSalaries(); // Refresh the list
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Salaries'),
        actions: [
          IconButton(
            onPressed: _showGenerateDialog,
            icon: const Icon(Icons.add_card),
            tooltip: 'Generate Salaries for a Month',
          ),
        ],
      ),
      // ** CHANGE THE BODY TO USE THE NEW STATE VARIABLES **
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchInitialSalaries, // Pull to refresh calls the initial fetch
              child: ListView.builder(
                controller: _scrollController,
                // Add 1 to the item count if there are more pages to load (for the spinner)
                itemCount: _salaries.length + (_hasNextPage ? 1 : 0),
                itemBuilder: (context, index) {
                  // If it's the last item in the list AND there's more to load, show a spinner
                  if (index == _salaries.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  // Otherwise, build the list item as before
                  final salary = _salaries[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Text(salary['worker_name'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(salary['salary_month'] ?? ''),
                      trailing: Chip(
                        label: Text(salary['status'] ?? ''),
                        backgroundColor: _getStatusColor(salary['status']),
                        labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                      onTap: () async {
                        final needsRefresh = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (context) => SalaryDetailScreen(monthlySalaryId: salary['id']),
                          ),
                        );
                        // After returning, always refresh the first page to see the latest changes
                        if (needsRefresh == true) {
                          _fetchInitialSalaries();
                        }
                      },
                    ),
                  );
                },
              ),
            ),
    );
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