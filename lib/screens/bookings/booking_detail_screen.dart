import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../services/permission_service.dart';
import '../../l10n/app_localizations.dart'; // <-- Import the l10n class

class BookingDetailScreen extends StatefulWidget {
  final int bookingId;
  const BookingDetailScreen({super.key, required this.bookingId});
  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _details;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    if (_details == null) setState(() => _isLoading = true);
    final details = await _apiService.getBookingDetails(widget.bookingId);
    if (mounted)
      setState(() {
        _details = details;
        _isLoading = false;
      });
  }

  void _showAddPaymentDialog(AppLocalizations l10n) {
    final amountController = TextEditingController();
    final dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    final notesController = TextEditingController();
    String selectedMethod = 'Cash';

    // Create a map for translatable payment methods
    final Map<String, String> paymentMethods = {
      'Cash': l10n.paymentMethodCash,
      'Bank Transfer': l10n.paymentMethodBank,
      'Mobile Banking': l10n.paymentMethodMobile,
    };

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.addPayment),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: amountController,
                    decoration: InputDecoration(
                      labelText: l10n.amountToPay,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: dateController,
                    decoration: InputDecoration(
                      labelText: l10n.paymentDate,
                      border: const OutlineInputBorder(),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null)
                        dateController.text = DateFormat(
                          'yyyy-MM-dd',
                        ).format(picked);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: DropdownButtonFormField<String>(
                    value: selectedMethod,
                    items: paymentMethods.keys
                        .map(
                          (methodKey) => DropdownMenuItem(
                            value: methodKey,
                            child: Text(paymentMethods[methodKey]!),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) selectedMethod = value;
                    },
                    decoration: InputDecoration(
                      labelText: l10n.paymentMethod,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: notesController,
                    decoration: InputDecoration(
                      labelText: l10n.notesOptional,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => _submitPayment(
                amountController.text,
                dateController.text,
                selectedMethod,
                notesController.text,
                l10n,
              ),
              child: Text(l10n.submit),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitPayment(
    String amount,
    String date,
    String method,
    String notes,
    AppLocalizations l10n,
  ) async {
    Navigator.of(context).pop();
    setState(() => _isLoading = true);

    final updatedBooking = await _apiService.addBookingPayment(
      bookingId: widget.bookingId,
      amount: amount,
      date: date,
      method: method,
      notes: notes,
    );

    if (mounted) {
      if (updatedBooking != null) {
        setState(() => _details = updatedBooking);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.paymentAddedSuccess),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.paymentFailed),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    bool canAddPayment = false;
    if (_details != null) {
      double dueAmount =
          double.tryParse(
            _details!['financials']['due_amount'].replaceAll(',', ''),
          ) ??
          0;
      canAddPayment = dueAmount > 0;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.bookingDetailsTitle} #${widget.bookingId}'),
      ),
      floatingActionButton:
          !_isLoading &&
              canAddPayment &&
              PermissionService().can('manage booking payments')
          ? FloatingActionButton(
              onPressed: () => _showAddPaymentDialog(l10n),
              child: const Icon(Icons.add_shopping_cart),
              tooltip: l10n.addPayment,
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _details == null
          ? Center(child: Text(l10n.failedToLoadBooking))
          : RefreshIndicator(
              onRefresh: _fetchDetails,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildFinancialCard(_details!['financials'], l10n),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      _details!['customer'],
                      _details!['event'],
                      context,
                    ),
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

  Widget _buildFinancialCard(
    Map<String, dynamic> financials,
    AppLocalizations l10n,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildFinancialItem(
              l10n.totalAmount,
              '৳${financials['total_amount']}',
              Colors.black87,
            ),
            _buildFinancialItem(
              l10n.totalPaid,
              '৳${financials['total_paid']}',
              Colors.green.shade700,
            ),
            _buildFinancialItem(
              l10n.amountDue,
              '৳${financials['due_amount']}',
              Colors.red.shade700,
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialItem(
    String label,
    String value,
    Color color, {
    bool isBold = false,
  }) {
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

  Widget _buildInfoCard(
    Map<String, dynamic> customer,
    Map<String, dynamic> event,
    BuildContext context,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.bookingInformation,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(height: 24),
            _buildInfoRow(l10n.customerName, customer['name']),
            _buildInfoRow(l10n.customerPhone, customer['phone']),
            _buildInfoRow(l10n.address, customer['address'] ?? 'N/A'),
            const SizedBox(height: 16),
            _buildInfoRow(l10n.eventType, event['type']),
            _buildInfoRow(l10n.guests, event['guests']?.toString() ?? 'N/A'),
            _buildInfoRow(l10n.tables, event['tables']?.toString() ?? 'N/A'),
            _buildInfoRow(l10n.servers, event['servers']?.toString() ?? 'N/A'),
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
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildDatesCard(List dates, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.scheduledDates,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (dates.isEmpty)
              Text(l10n.noDatesScheduled)
            else
              ...dates.map(
                (date) => ListTile(
                  leading: const Icon(Icons.calendar_today, color: Colors.blue),
                  title: Text(
                    date['date'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Chip(
                    label: Text(date['slot']),
                  ), // Slot is already translated
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentsCard(List payments, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '৳');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.paymentHistory,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (payments.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(l10n.noPaymentsRecorded),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: payments.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final payment = payments[index];
                  return ListTile(
                    title: Text(
                      currencyFormat.format(
                        double.tryParse(
                              payment['amount'].replaceAll(',', ''),
                            ) ??
                            0,
                      ),
                    ),
                    subtitle: Text(
                      '${payment['date']} - ${payment['method'] ?? 'N/A'}',
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
