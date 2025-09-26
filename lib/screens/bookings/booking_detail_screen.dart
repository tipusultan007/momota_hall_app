// lib/screens/bookings/booking_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting
import '../../services/api_service.dart';

class BookingDetailScreen extends StatefulWidget {
  final int bookingId;
  const BookingDetailScreen({super.key, required this.bookingId});
  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  final ApiService _apiService = ApiService();
  
  // We now hold the data directly in a nullable Map
  Map<String, dynamic>? _details;
  // And we use a boolean to track the loading state
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetails(); // Call our new data fetching method
  }

  // New method to fetch data and update the state
  Future<void> _fetchDetails() async {
    // Show loading indicator only if we don't have old data
    if (_details == null) {
      setState(() { _isLoading = true; });
    }

    final details = await _apiService.getBookingDetails(widget.bookingId);
    
    // Check if the widget is still in the tree before updating state
    if (mounted) {
      setState(() {
        _details = details;
        _isLoading = false;
      });
    }
  }

   void _showAddPaymentDialog() {
    final amountController = TextEditingController();
    // Set default date to today, formatted correctly
    final dateController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
    final notesController = TextEditingController();
    String selectedMethod = 'Cash';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Payment'),
          content: SingleChildScrollView( // Use a scroll view to prevent overflow
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: amountController, decoration: const InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number),
                TextField(controller: dateController, decoration: const InputDecoration(labelText: 'Date'), readOnly: true, onTap: () async {
                    DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                    if (picked != null) dateController.text = DateFormat('yyyy-MM-dd').format(picked);
                }),
                DropdownButtonFormField<String>(
                  value: selectedMethod,
                  items: ['Cash', 'Bank Transfer', 'Mobile Banking'].map((method) => DropdownMenuItem(value: method, child: Text(method))).toList(),
                  onChanged: (value) => selectedMethod = value!,
                  decoration: const InputDecoration(labelText: 'Method'),
                ),
                TextField(controller: notesController, decoration: const InputDecoration(labelText: 'Notes (Optional)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => _submitPayment(amountController.text, dateController.text, selectedMethod, notesController.text), child: const Text('Submit')),
          ],
        );
      },
    );
  }

  Future<void> _submitPayment(String amount, String date, String method, String notes) async {
    Navigator.of(context).pop(); // Close the dialog first
    setState(() { _isLoading = true; }); // Show loading indicator

    final updatedBooking = await _apiService.addBookingPayment(
      bookingId: widget.bookingId,
      amount: amount,
      date: date,
      method: method,
      notes: notes,
    );

    if (mounted) {
      if (updatedBooking != null) {
        setState(() { 
          // CRITICAL: Update our state with the new data from the API
          _details = updatedBooking; 
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment added successfully!'), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add payment. Check input.'), backgroundColor: Colors.red));
      }
      setState(() { _isLoading = false; }); // Hide loading indicator
    }
  }

 @override
  Widget build(BuildContext context) {
    // Check if we should show the "Add Payment" button
    bool canAddPayment = false;
    if (_details != null) {
      double dueAmount = double.tryParse(_details!['financials']['due_amount'].replaceAll(',', '')) ?? 0;
      canAddPayment = dueAmount > 0;
    }

    return Scaffold(
      appBar: AppBar(title: Text('Booking Details #${widget.bookingId}')),
      // ADD THE FLOATING ACTION BUTTON
      floatingActionButton: _isLoading || !canAddPayment
          ? null // Hide button while loading or if fully paid
          : FloatingActionButton(
              onPressed: _showAddPaymentDialog,
              child: const Icon(Icons.add_shopping_cart),
              tooltip: 'Add Payment',
            ),
      
      // REPLACE THE FutureBuilder with a simple loading check
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _details == null
              ? const Center(child: Text('Failed to load booking details.'))
              : RefreshIndicator(
                  onRefresh: _fetchDetails, // The refresh now calls our new method
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildFinancialCard(_details!['financials']),
                        const SizedBox(height: 16),
                        _buildInfoCard(_details!['customer'], _details!['event'], context),
                        const SizedBox(height: 16),
                        _buildDatesCard(_details!['dates'] as List, context),
                        const SizedBox(height: 16),
                        _buildPaymentsCard(_details!['payments'] as List, context),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildFinancialCard(Map<String, dynamic> financials) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildFinancialItem('Total Amount', '৳${financials['total_amount']}', Colors.black87),
            _buildFinancialItem('Total Paid', '৳${financials['total_paid']}', Colors.green.shade700),
            _buildFinancialItem('Amount Due', '৳${financials['due_amount']}', Colors.red.shade700, isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialItem(String label, String value, Color color, {bool isBold = false}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(Map<String, dynamic> customer, Map<String, dynamic> event, BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Booking Information', style: Theme.of(context).textTheme.titleLarge),
            const Divider(height: 24),
            _buildInfoRow('Customer:', customer['name']),
            _buildInfoRow('Phone:', customer['phone']),
            _buildInfoRow('Address:', customer['address'] ?? 'N/A'),
            const SizedBox(height: 16),
            _buildInfoRow('Event Type:', event['type']),
            _buildInfoRow('Guests:', event['guests']?.toString() ?? 'N/A'),
            _buildInfoRow('Tables:', event['tables']?.toString() ?? 'N/A'),
            _buildInfoRow('Servers:', event['servers']?.toString() ?? 'N/A'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildDatesCard(List dates, BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Scheduled Dates', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            if (dates.isEmpty)
              const Text('No dates scheduled.')
            else
              ...dates.map((date) => ListTile(
                    leading: const Icon(Icons.calendar_today, color: Colors.blue),
                    title: Text(date['date'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Chip(label: Text(date['slot'])),
                  )),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPaymentsCard(List payments, BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '৳');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payment History', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            if (payments.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No payments recorded yet.'),
              ))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: payments.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final payment = payments[index];
                  return ListTile(
                    title: Text(currencyFormat.format(double.tryParse(payment['amount'].replaceAll(',', '')) ?? 0)),
                    subtitle: Text('${payment['date']} - ${payment['method'] ?? 'N/A'}'),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}