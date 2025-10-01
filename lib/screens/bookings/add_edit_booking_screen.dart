import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:momota_hall_app/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      if (_bookingDates.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.pleaseAddDate), backgroundColor: Colors.orange));
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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.bookingCreatedSuccess), backgroundColor: Colors.green));
          Navigator.of(context).pop(true); // Return true to refresh list
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.bookingFailed), backgroundColor: Colors.red));
          setState(() { _isLoading = false; });
        }
      }
    }
  }

 final List<String> _eventTypes = const [
    'Wedding', 'Gaye Holud', 'Birthday', 'Aqiqah', 'Mezban', 'Seminar'
  ];
  final List<String> _timeSlots = const ['Day', 'Night'];

  // ** 2. Create a helper function to get the translation for a key **
  String _getTranslatedEventType(String key, AppLocalizations l10n) {
    switch (key) {
      case 'Wedding': return l10n.eventTypeWedding;
      case 'Gaye Holud': return l10n.eventTypeGayeHolud;
      case 'Birthday': return l10n.eventTypeBirthday;
      case 'Aqiqah': return l10n.eventTypeAqiqah;
      case 'Mezban': return l10n.eventTypeMezban;
      case 'Seminar': return l10n.eventTypeSeminar;
      default: return key; // Fallback to the key itself
    }
  }

  String _getTranslatedSlot(String key, AppLocalizations l10n) {
    switch (key) {
      case 'Day': return l10n.slotDay;
      case 'Night': return l10n.slotNight;
      default: return key;
    }
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createNewBooking),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _isLoading ? const Center(child: CircularProgressIndicator(color: Colors.white)) : IconButton(
              icon: const Icon(Icons.save),
              onPressed: _submitForm,
              tooltip: l10n.saveBooking,
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
                  title: Text('1. ${l10n.customerDetails}', style: TextStyle(fontWeight: FontWeight.bold)),
                  initiallyExpanded: true,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextFormField(controller: _customerNameController, decoration: InputDecoration(labelText: l10n.customerName, border: const OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Required' : null),
                          const SizedBox(height: 16),
                          TextFormField(controller: _customerPhoneController, decoration: InputDecoration(labelText: l10n.customerPhone, border: const OutlineInputBorder()), keyboardType: TextInputType.phone, validator: (v) => v!.isEmpty ? 'Required' : null),
                          const SizedBox(height: 16),
                          TextFormField(controller: _customerAddressController, decoration: InputDecoration(labelText: l10n.address, border: const OutlineInputBorder()), maxLines: 2),
                        ],
                      ),
                    )
                  ],
                ),
              ),

              // --- Section 2: Event Details ---
              Card(
                child: ExpansionTile(
                  title: Text('2. ${l10n.eventDetails}', style: TextStyle(fontWeight: FontWeight.bold)),
                  initiallyExpanded: true,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: _selectedEventType,
                            // Map over your English keys to create the items
                            items: _eventTypes.map((String typeKey) {
                              return DropdownMenuItem<String>(
                                value: typeKey, // The value is the English key
                                child: Text(_getTranslatedEventType(typeKey, l10n)), // The display is the translation
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => _selectedEventType = value!),
                            decoration: InputDecoration(labelText: l10n.eventType, border: const OutlineInputBorder()),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(controller: _receiptNoController, decoration: InputDecoration(labelText: l10n.manualReceiptNo, border: OutlineInputBorder())),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: TextFormField(controller: _guestsController, decoration: InputDecoration(labelText: l10n.guests, border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                              const SizedBox(width: 8),
                              Expanded(child: TextFormField(controller: _tablesController, decoration: InputDecoration(labelText: l10n.tables, border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                              const SizedBox(width: 8),
                              Expanded(child: TextFormField(controller: _serversController, decoration: InputDecoration(labelText: l10n.servers, border: OutlineInputBorder()), keyboardType: TextInputType.number)),
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
                  title: Text('3. ${l10n.bookingDates}', style: TextStyle(fontWeight: FontWeight.bold)),
                  initiallyExpanded: true,
                  children: [
                     _buildDateAdder(l10n),
                    _buildDatesList(l10n),
                  ],
                ),
              ),
              
              // --- Section 4: Financials ---
              Card(
                child: ExpansionTile(
                  title: Text('4. ${l10n.financials}', style: TextStyle(fontWeight: FontWeight.bold)),
                  initiallyExpanded: true,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextFormField(controller: _totalAmountController, decoration: InputDecoration(labelText: l10n.totalAmount, border: OutlineInputBorder()), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null),
                          const SizedBox(height: 16),
                          TextFormField(controller: _advanceAmountController, decoration: InputDecoration(labelText: l10n.advanceAmount, border: OutlineInputBorder()), keyboardType: TextInputType.number),
                          const SizedBox(height: 16),
                          TextFormField(controller: _notesInWordsController, decoration: InputDecoration(labelText: l10n.inWords, border: OutlineInputBorder())),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white)) : Text(l10n.saveBooking),
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
  Widget _buildDateAdder(AppLocalizations l10n) {
    final dateController = TextEditingController();
    //String selectedSlot = 'Day';
    String selectedSlot = _timeSlots[0]; // Default to first slot

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
                  decoration: InputDecoration(
                    labelText: l10n.eventDate,
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
                  // Map over the English keys to create the items
                  items: _timeSlots.map((String slotKey) {
                    return DropdownMenuItem<String>(
                      value: slotKey, // The value is the English key ('Day' or 'Night')
                      child: Text(_getTranslatedSlot(slotKey, l10n)), // The display is the translation
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setInnerState(() {
                        selectedSlot = value;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    labelText: l10n.timeSlot,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addDate),
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
                        SnackBar(content: Text(l10n.pleaseSelectDate)),
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
  Widget _buildDatesList(AppLocalizations l10n) {
    if (_bookingDates.isEmpty) {
      return const SizedBox.shrink(); // Return an empty widget if the list is empty
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.addedDates, style: Theme.of(context).textTheme.titleMedium),
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
                subtitle: Text('${l10n.timeSlot}: ${_getTranslatedSlot(dateEntry['slot']!, l10n)}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _removeDateFromList(index),
                  tooltip: l10n.removeDate,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}