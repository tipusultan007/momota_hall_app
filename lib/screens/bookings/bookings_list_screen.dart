// lib/screens/bookings/bookings_list_screen.dart
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'booking_detail_screen.dart'; // We will create this next
import 'add_edit_booking_screen.dart'; // Import the new screen


class BookingsListScreen extends StatefulWidget {
  const BookingsListScreen({super.key});
  @override
  State<BookingsListScreen> createState() => _BookingsListScreenState();
}

class _BookingsListScreenState extends State<BookingsListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _bookingsFuture = _apiService.getBookings();
  }

  // **** 1. CREATE A DEDICATED REFRESH METHOD ****
  Future<void> _refreshBookings() async {
    // setState() tells Flutter to re-run the FutureBuilder with the new future
    setState(() {
      _bookingsFuture = _apiService.getBookings();
    });
  }
 void _navigateToAddBooking() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const AddEditBookingScreen()),
    );
    if (result == true) {
      _refreshBookings(); // Refresh the list after a new booking is added
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Bookings')),
       // **** ADD THIS FAB ****
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddBooking,
        child: const Icon(Icons.add),
        tooltip: 'New Booking',
      ),
      body: RefreshIndicator(
        onRefresh: _refreshBookings,
        child: FutureBuilder<List<dynamic>>(
        future: _bookingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No bookings found.'));
          }

          final bookings = snapshot.data!;
          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
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
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => BookingDetailScreen(bookingId: booking['id']),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      ),
    );
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