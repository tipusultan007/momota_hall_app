import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../models/paginated_response.dart';
import '../../services/auth_service.dart';
import '../../services/permission_service.dart';
import 'booking_detail_screen.dart';
import 'add_edit_booking_screen.dart';


class BookingsListScreen extends StatefulWidget {
  const BookingsListScreen({super.key});
  @override
  State<BookingsListScreen> createState() => _BookingsListScreenState();
}

class _BookingsListScreenState extends State<BookingsListScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  // --- State Variables ---
  List<dynamic> _bookings = [];
  int _currentPage = 1;
  bool _hasNextPage = true;
  bool _isLoading = true;
  bool _isLoadMoreRunning = false;
  String _currentSearchQuery = '';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _fetchInitialBookings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fetches the first page of data based on all current filters
  Future<void> _fetchInitialBookings({String? query}) async {
    setState(() {
      _isLoading = true;
      // Use the provided query, or fallback to the existing one
      _currentSearchQuery = query ?? _currentSearchQuery;
    });

    PaginatedResponse response = await _apiService.getBookings(
      page: 1,
      query: _currentSearchQuery,
      startDate: _startDate,
      endDate: _endDate,
    );

    if (mounted) {
      setState(() {
        _bookings = response.items;
        _currentPage = 1; // Always reset to page 1 on a new fetch/filter
        _hasNextPage = response.hasMorePages;
        _isLoading = false;
      });
    }
  }

  // Fetches subsequent pages with the current filters
  Future<void> _loadMore() async {
    if (_hasNextPage && !_isLoading && !_isLoadMoreRunning) {
      setState(() { _isLoadMoreRunning = true; });
      _currentPage++;
      PaginatedResponse response = await _apiService.getBookings(
        page: _currentPage,
        query: _currentSearchQuery,
        startDate: _startDate,
        endDate: _endDate,
      );
      if (mounted) {
        setState(() {
          _bookings.addAll(response.items);
          _hasNextPage = response.hasMorePages;
          _isLoadMoreRunning = false;
        });
      }
    }
  }

  // --- Filter and Navigation Methods ---

  Future<void> _showDateRangePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _startDate != null && _endDate != null ? DateTimeRange(start: _startDate!, end: _endDate!) : null,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _fetchInitialBookings();
    }
  }
  
  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _searchController.clear();
      _currentSearchQuery = '';
    });
    _fetchInitialBookings();
  }

  void _navigateToAddBooking() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const AddEditBookingScreen()),
    );
    if (result == true) {
      _fetchInitialBookings(); // Refresh list after adding
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasFilters = _startDate != null || _currentSearchQuery.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Bookings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showDateRangePicker,
            tooltip: 'Filter by Date Range',
          ),
        ],
      ),
     floatingActionButton: Consumer<AuthService>(
        builder: (context, authService, child) {
          // The logic remains the same, but it's now listening to the ChangeNotifier
          if (!authService.isLoggedIn || !PermissionService().can('create bookings')) {
            return const SizedBox.shrink(); // Hide button
          }
          
          return FloatingActionButton(
            onPressed: _navigateToAddBooking,
            child: const Icon(Icons.add),
            tooltip: 'New Booking',
          );
        },
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Name, Phone, Event...',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _currentSearchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _fetchInitialBookings(query: '');
                        },
                      )
                    : null,
              ),
              onSubmitted: (value) => _fetchInitialBookings(query: value),
            ),
          ),

          // Filter Summary Header
          if (hasFilters)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _buildFilterSummary(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: _clearFilters,
                    tooltip: 'Clear All Filters',
                  )
                ],
              ),
            ),
          
          // The List View
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => _fetchInitialBookings(query: _currentSearchQuery),
                    child: _bookings.isEmpty
                        ? const Center(child: Text('No bookings found for the selected filters.'))
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: _bookings.length + (_hasNextPage ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _bookings.length) {
                                return _buildLoadMoreButton();
                              }
                              final booking = _bookings[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: ListTile(
                                  title: Text(booking['customer_name'] ?? 'No Name'),
                                  subtitle: Text('${booking['event_type']} - ${booking['first_event_date'] ?? ''}'),
                                  trailing: Chip(
                                    label: Text(booking['status'] ?? ''),
                                    backgroundColor: _getStatusColor(booking['status']),
                                    labelStyle: const TextStyle(color: Colors.white),
                                  ),
                                  onTap: () async {
                                    final result = await Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) => BookingDetailScreen(bookingId: booking['id'])),
                                    );
                                    // Refresh if a payment was made on the detail screen
                                    if(result == true) {
                                      _fetchInitialBookings(query: _currentSearchQuery);
                                    }
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

  // Helper method for the filter summary
  String _buildFilterSummary() {
    List<String> filters = [];
    if (_startDate != null && _endDate != null) {
      filters.add('Dates: ${DateFormat.yMd().format(_startDate!)} - ${DateFormat.yMd().format(_endDate!)}');
    }
    if (_currentSearchQuery.isNotEmpty) {
      filters.add('Search: "$_currentSearchQuery"');
    }
    return filters.join(' | ');
  }
  
  // Helper for the "Load More" button
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

  // Helper for status colors
  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Paid': return Colors.green;
      case 'Partially Paid': return Colors.orange;
      case 'Pending': return Colors.red;
      default: return Colors.grey;
    }
  }
}