import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../models/paginated_response.dart';
import '../../services/auth_service.dart';
import '../../services/permission_service.dart';
import 'booking_detail_screen.dart';
import 'add_edit_booking_screen.dart';
import '../../l10n/app_localizations.dart';
import '../mixins/refreshable_screen_mixin.dart';
import '../calendar/calendar_screen.dart'; // Import the new screen


class BookingsListScreen extends StatefulWidget {
  const BookingsListScreen({super.key});
  @override
  State<BookingsListScreen> createState() => _BookingsListScreenState();
}

class _BookingsListScreenState extends State<BookingsListScreen> with RefreshableScreenState {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

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
    refreshData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Future<void> refreshData({String? query}) async {
    setState(() { _isLoading = true; _currentSearchQuery = query ?? _currentSearchQuery; });
    PaginatedResponse response = await _apiService.getBookings(page: 1, query: _currentSearchQuery, startDate: _startDate, endDate: _endDate);
    if (mounted) {
      setState(() {
        _bookings = response.items;
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
      PaginatedResponse response = await _apiService.getBookings(page: _currentPage, query: _currentSearchQuery, startDate: _startDate, endDate: _endDate);
      if (mounted) {
        setState(() {
          _bookings.addAll(response.items);
          _hasNextPage = response.hasMorePages;
          _isLoadMoreRunning = false;
        });
      }
    }
  }

  Future<void> _showDateRangePicker() async {
    final picked = await showDateRangePicker(context: context, initialDateRange: _startDate != null && _endDate != null ? DateTimeRange(start: _startDate!, end: _endDate!) : null, firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 365 * 5)));
    if (picked != null) {
      setState(() { _startDate = picked.start; _endDate = picked.end; });
      refreshData();
    }
  }
  
  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _searchController.clear();
      _currentSearchQuery = '';
    });
    refreshData();
  }

  void _navigateToAddBooking() async {
    final result = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (context) => const AddEditBookingScreen()));
    if (result == true) refreshData();
  }

  void _navigateToEditBooking(int bookingId) async {
    final result = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (context) => AddEditBookingScreen(bookingId: bookingId)));
    if (result == true) refreshData(query: _currentSearchQuery);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    bool hasFilters = _startDate != null || _currentSearchQuery.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bookingsTitle),
        actions: [IconButton(icon: const Icon(Icons.filter_list), onPressed: _showDateRangePicker, tooltip: l10n.filterByDate),
         IconButton(
            icon: const Icon(Icons.calendar_view_month),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CalendarScreen()),
              );
            },
            tooltip: 'Calendar View',
          )],
      ),
      floatingActionButton: Consumer<AuthService>(
        builder: (context, authService, child) {
          if (!authService.isLoggedIn || !PermissionService().can('create bookings')) return const SizedBox.shrink();
          return FloatingActionButton(onPressed: _navigateToAddBooking, child: const Icon(Icons.add), tooltip: l10n.newBooking);
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: l10n.searchByHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _currentSearchQuery.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); refreshData(query: ''); }) : null,
              ),
              onSubmitted: (value) => refreshData(query: value),
            ),
          ),
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
                    onRefresh: () => refreshData(query: _currentSearchQuery),
                    child: _bookings.isEmpty
                        ? LayoutBuilder(
                            builder: (context, constraints) {
                              return SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(), // This makes it always scrollable
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                                  child: const Center(child: Text('No bookings found for the selected filters.')),
                                ),
                              );
                            },
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: _bookings.length + (_hasNextPage ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _bookings.length) return _buildLoadMoreButton(l10n);
                              final booking = _bookings[index];
                              return Dismissible(
                                key: Key(booking['id'].toString()),
                                direction: PermissionService().can('delete bookings') ? DismissDirection.endToStart : DismissDirection.none,
                                background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.symmetric(horizontal: 20.0), child: const Icon(Icons.delete, color: Colors.white)),
                                confirmDismiss: (direction) async => await showDialog(
                                  context: context,
                                  builder: (BuildContext context) => AlertDialog(
                                    title: Text(l10n.confirmDelete),
                                    content: Text(l10n.areYouSureDeleteBooking),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.cancel.toUpperCase())),
                                      TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.delete.toUpperCase())),
                                    ],
                                  ),
                                ),
                                onDismissed: (direction) async {
                                  bool deleted = await _apiService.deleteBooking(booking['id']);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(deleted ? l10n.bookingDeleted : l10n.failedToDeleteBooking)));
                                    if (deleted) setState(() => _bookings.removeAt(index));
                                  }
                                },
                                child: Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: ListTile(
                                    title: Text(booking['customer_name'] ?? 'No Name'),
                                    subtitle: Text('${booking['event_type']} - ${booking['first_event_date'] ?? ''}'),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Chip(label: Text(_getStatusText(booking['status'], l10n)), backgroundColor: _getStatusColor(booking['status']), labelStyle: const TextStyle(color: Colors.white)),
                                        if (PermissionService().can('edit bookings'))
                                          IconButton(icon: const Icon(Icons.edit, color: Colors.grey), onPressed: () => _navigateToEditBooking(booking['id'])),
                                      ],
                                    ),
                                    onTap: () async {
                                      final result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => BookingDetailScreen(bookingId: booking['id'])));
                                      if (result == true) refreshData(query: _currentSearchQuery);
                                    },
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
    List<String> filters = [];
    if (_startDate != null && _endDate != null) {
      filters.add('${l10n.date}: ${DateFormat.yMd().format(_startDate!)} - ${DateFormat.yMd().format(_endDate!)}');
    }
    if (_currentSearchQuery.isNotEmpty) {
      filters.add('${l10n.searchByHint.split('...')[0]}: "$_currentSearchQuery"');
    }
    return '${l10n.filters} ${filters.join(' | ')}';
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
      case 'Paid': return l10n.statusPaid;
      case 'Partially Paid': return l10n.statusPartiallyPaid;
      case 'Pending': return l10n.statusPending;
      default: return status ?? '';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Paid': return Colors.green;
      case 'Partially Paid': return Colors.orange;
      case 'Pending': return Colors.red;
      default: return Colors.grey;
    }
  }
}