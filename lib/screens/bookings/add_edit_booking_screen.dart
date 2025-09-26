import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class AddEditBookingScreen extends StatefulWidget {
  // You can pass a booking map here for editing in the future
  // final Map<String, dynamic>? booking;
  // const AddEditBookingScreen({super.key, this.booking});

  const AddEditBookingScreen({super.key});
  @override
  State<AddEditBookingScreen> createState() => _AddEditBookingScreenState();
}

class _AddEditBookingScreenState extends State<AddEditBookingScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  // Controllers for all fields
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerAddressController = TextEditingController();
  final _receiptNoController = TextEditingController();
  final _guestsController = TextEditingController();
  final _tablesController = TextEditingController();
  final _serversController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _advanceAmountController = TextEditingController();
  final _notesInWordsController = TextEditingController();
  
  String _selectedEventType = 'Wedding';
  final List<Map<String, String>> _bookingDates = [];
  bool _isLoading = false;

  void _addDateToList(String date, String slot) {
    setState(() {
      _bookingDates.add({'date': date, 'slot': slot});
    });
  }
  
  void _removeDateFromList(int index) {
    setState(() {
      _bookingDates.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_bookingDates.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one booking date.'), backgroundColor: Colors.orange));
        return;
      }
      
      setState(() { _isLoading = true; });

      final newBooking = await _apiService.addBooking(
        customerName: _customerNameController.text,
        customerPhone: _customerPhoneController.text,
        customerAddress: _customerAddressController.text,
        eventType: _selectedEventType,
        receiptNo: _receiptNoController.text,
        guests: _guestsController.text,
        tables: _tablesController.text,
        servers: _serversController.text,
        totalAmount: _totalAmountController.text,
        advanceAmount: _advanceAmountController.text,
        notesInWords: _notesInWordsController.text,
        bookingDates: _bookingDates,
      );

      if (mounted) {
        if (newBooking != null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking created successfully!'), backgroundColor: Colors.green));
          Navigator.of(context).pop(true); // Return true to refresh list
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to create booking.'), backgroundColor: Colors.red));
          setState(() { _isLoading = false; });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Booking'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _isLoading ? const Center(child: CircularProgressIndicator(color: Colors.white)) : IconButton(
              icon: const Icon(Icons.save),
              onPressed: _submitForm,
              tooltip: 'Save Booking',
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Section 1: Customer Details ---
              Card(
                child: ExpansionTile(
                  title: const Text('1. Customer Details', style: TextStyle(fontWeight: FontWeight.bold)),
                  initiallyExpanded: true,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextFormField(controller: _customerNameController, decoration: const InputDecoration(labelText: 'Customer Name', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Required' : null),
                          const SizedBox(height: 16),
                          TextFormField(controller: _customerPhoneController, decoration: const InputDecoration(labelText: 'Customer Phone', border: OutlineInputBorder()), keyboardType: TextInputType.phone, validator: (v) => v!.isEmpty ? 'Required' : null),
                          const SizedBox(height: 16),
                          TextFormField(controller: _customerAddressController, decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder()), maxLines: 2),
                        ],
                      ),
                    )
                  ],
                ),
              ),

              // --- Section 2: Event Details ---
              Card(
                child: ExpansionTile(
                  title: const Text('2. Event Details', style: TextStyle(fontWeight: FontWeight.bold)),
                  initiallyExpanded: true,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: _selectedEventType,
                            items: ['Wedding', 'Gaye Holud', 'Birthday', 'Aqiqah', 'Mezban', 'Seminar'].map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                            onChanged: (value) => setState(() => _selectedEventType = value!),
                            decoration: const InputDecoration(labelText: 'Event Type', border: OutlineInputBorder()),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(controller: _receiptNoController, decoration: const InputDecoration(labelText: 'Manual Receipt No (Optional)', border: OutlineInputBorder())),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: TextFormField(controller: _guestsController, decoration: const InputDecoration(labelText: 'Guests', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                              const SizedBox(width: 8),
                              Expanded(child: TextFormField(controller: _tablesController, decoration: const InputDecoration(labelText: 'Tables', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                              const SizedBox(width: 8),
                              Expanded(child: TextFormField(controller: _serversController, decoration: const InputDecoration(labelText: 'Servers', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              
              // --- Section 3: Booking Dates ---
              Card(
                child: ExpansionTile(
                  title: const Text('3. Booking Dates', style: TextStyle(fontWeight: FontWeight.bold)),
                  initiallyExpanded: true,
                  children: [
                    _buildDateAdder(),
                    _buildDatesList(),
                  ],
                ),
              ),
              
              // --- Section 4: Financials ---
              Card(
                child: ExpansionTile(
                  title: const Text('4. Financials', style: TextStyle(fontWeight: FontWeight.bold)),
                  initiallyExpanded: true,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextFormField(controller: _totalAmountController, decoration: const InputDecoration(labelText: 'Total Amount', border: OutlineInputBorder()), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null),
                          const SizedBox(height: 16),
                          TextFormField(controller: _advanceAmountController, decoration: const InputDecoration(labelText: 'Advance Amount', border: OutlineInputBorder()), keyboardType: TextInputType.number),
                          const SizedBox(height: 16),
                          TextFormField(controller: _notesInWordsController, decoration: const InputDecoration(labelText: 'In Words (Auto-generated if blank)', border: OutlineInputBorder())),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white)) : const Text('Save Booking Contract'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
// -------------------------------------------------------------------
  // *****                HELPER WIDGETS START HERE                *****
  // -------------------------------------------------------------------

  /// Builds the UI for the date picker, time slot dropdown, and "Add Date" button.
  Widget _buildDateAdder() {
    final dateController = TextEditingController();
    String selectedSlot = 'Day';

    return StatefulBuilder(
      builder: (context, setInnerState) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    labelText: 'Event Date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      dateController.text = DateFormat('yyyy-MM-dd').format(picked);
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedSlot,
                  items: ['Day', 'Night'].map((slot) => DropdownMenuItem(
                    value: slot,
                    child: Text(slot),
                  )).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setInnerState(() {
                        selectedSlot = value;
                      });
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Time Slot',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Date'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    if (dateController.text.isNotEmpty) {
                      _addDateToList(dateController.text, selectedSlot);
                      dateController.clear(); // Clear for next entry
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a date first.')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds the ListView that displays the dates that have been added.
  Widget _buildDatesList() {
    if (_bookingDates.isEmpty) {
      return const SizedBox.shrink(); // Return an empty widget if the list is empty
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Added Dates:', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _bookingDates.length,
          itemBuilder: (context, index) {
            final dateEntry = _bookingDates[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              child: ListTile(
                leading: const Icon(Icons.check_circle_outline, color: Colors.green),
                title: Text(DateFormat('MMMM d, yyyy').format(DateTime.parse(dateEntry['date']!))),
                subtitle: Text('Slot: ${dateEntry['slot']}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _removeDateFromList(index),
                  tooltip: 'Remove Date',
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}