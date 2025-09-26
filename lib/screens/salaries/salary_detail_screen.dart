import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class SalaryDetailScreen extends StatefulWidget {
  final int monthlySalaryId;
  const SalaryDetailScreen({super.key, required this.monthlySalaryId});
  @override
  State<SalaryDetailScreen> createState() => _SalaryDetailScreenState();
}

class _SalaryDetailScreenState extends State<SalaryDetailScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _details;
  bool _isLoading = true;
  bool _didChange = false; // Track if a payment was made to signal a refresh

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    if (_details == null)
      setState(() {
        _isLoading = true;
      });

    final details = await _apiService.getSalaryDetails(widget.monthlySalaryId);
    if (mounted) {
      setState(() {
        _details = details;
        _isLoading = false;
      });
    }
  }

  void _showAddPaymentDialog() {
    final amountController = TextEditingController();
    final dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Record Salary Payment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(labelText: 'Date'),
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
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _submitPayment(
                amountController.text,
                dateController.text,
                notesController.text,
              ),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitPayment(String amount, String date, String notes) async {
    Navigator.of(context).pop();
    setState(() {
      _isLoading = true;
    });

    final updatedSalary = await _apiService.addSalaryPayment(
      monthlySalaryId: widget.monthlySalaryId,
      amount: amount,
      date: date,
      notes: notes,
    );

    if (mounted) {
      if (updatedSalary != null) {
        _didChange = true; // Mark that a change happened
        setState(() {
          _details = updatedSalary;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment recorded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to record payment.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool canAddPayment = false;
     if (_details != null && _details!['financials'] != null) {
      final financials = _details!['financials'];
      double dueAmount =
          double.tryParse(financials['due_amount'].replaceAll(',', '')) ?? 0;
      canAddPayment = dueAmount > 0;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Salary Details'),
        // Add a leading widget to control the back button's behavior
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Always pop and send the result
            Navigator.of(context).pop(_didChange);
          },
        ),
      ),
      floatingActionButton: _isLoading || !canAddPayment
          ? null
          : FloatingActionButton(
              onPressed: _showAddPaymentDialog,
              child: const Icon(Icons.add),
              tooltip: 'Record Payment',
            ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _details == null
          ? const Center(child: Text('Failed to load salary details.'))
          : RefreshIndicator(
              onRefresh: _fetchDetails,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                 child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ** THE FIX: Pass the correct, nested part of the data **
                    _buildFinancialCard(_details!['financials']),
                    const SizedBox(height: 16),
                    _buildInfoCard(_details!), // Info card can still take the whole map
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
            // ** THE FIX: The map is now just 'financials', so access keys directly **
            _buildFinancialItem(
              'Total Salary',
              '৳${financials['total_salary']}',
              Colors.black87,
            ),
            _buildFinancialItem(
              'Total Paid',
              '৳${financials['paid_amount']}',
              Colors.green.shade700,
            ),
            _buildFinancialItem(
              'Amount Due',
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

  Widget _buildInfoCard(Map<String, dynamic> salary) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Salary Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(height: 24),
            _buildInfoRow('Worker:', salary['worker_name']),
            _buildInfoRow('Salary For:', salary['salary_month']),
            _buildInfoRow('Status:', salary['status']),
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

  Widget _buildPaymentsCard(List payments, BuildContext context) {
    // We can reuse the currency formatter from the booking details
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '৳');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment History',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (payments.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No payments recorded for this month.'),
                ),
              )
            else
              // Use ListView.builder for consistency, even though it's not scrolling
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: payments.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
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
                    subtitle: Text(payment['date']),
                    // You could add a trailing delete button here if needed in the future
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
