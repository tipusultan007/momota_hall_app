// lib/screens/liabilities/borrowed_fund_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class BorrowedFundDetailScreen extends StatefulWidget {
  final int borrowedFundId;
  const BorrowedFundDetailScreen({super.key, required this.borrowedFundId});
  @override
  State<BorrowedFundDetailScreen> createState() => _BorrowedFundDetailScreenState();
}

class _BorrowedFundDetailScreenState extends State<BorrowedFundDetailScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _details;
  bool _isLoading = true;
  bool _didChange = false;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    if (_details == null) setState(() { _isLoading = true; });
    
    final details = await _apiService.getBorrowedFundDetails(widget.borrowedFundId);
    if (mounted) {
      setState(() {
        _details = details;
        _isLoading = false;
      });
    }
  }

  void _showAddRepaymentDialog() {
    final amountController = TextEditingController();
    final dateController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Record Repayment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: amountController, decoration: const InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number),
                TextField(controller: dateController, decoration: const InputDecoration(labelText: 'Date'), readOnly: true, onTap: () async {
                  DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                  if (picked != null) dateController.text = DateFormat('yyyy-MM-dd').format(picked);
                }),
                TextField(controller: notesController, decoration: const InputDecoration(labelText: 'Notes (Optional)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => _submitRepayment(amountController.text, dateController.text, notesController.text), child: const Text('Submit')),
          ],
        );
      },
    );
  }

  Future<void> _submitRepayment(String amount, String date, String notes) async {
    Navigator.of(context).pop();
    setState(() { _isLoading = true; });

    final updatedFund = await _apiService.addFundRepayment(
      borrowedFundId: widget.borrowedFundId,
      amount: amount,
      date: date,
      notes: notes,
    );

    if (mounted) {
      if (updatedFund != null) {
        _didChange = true;
        setState(() { _details = updatedFund; });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Repayment recorded successfully!'), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to record repayment.'), backgroundColor: Colors.red));
      }
      setState(() { _isLoading = false; });
    }
  }

  @override
   Widget build(BuildContext context) {
    bool canAddPayment = false;
    if (_details != null && _details!['financials'] != null) {
      double dueAmount = double.tryParse(_details!['financials']['due_amount'].replaceAll(',', '')) ?? 0;
      canAddPayment = dueAmount > 0;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Repayments'),
        // ** THE FIX: Add a leading widget to control the back button's behavior **
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Manually pop the screen and pass back the _didChange flag.
            Navigator.of(context).pop(_didChange);
          },
        ),
      ),
      floatingActionButton: _isLoading || !canAddPayment
          ? null
          : FloatingActionButton(
              onPressed: _showAddRepaymentDialog,
              child: const Icon(Icons.add),
              tooltip: 'Record Repayment',
            ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _details == null
              ? Center( // Improved error state with a retry button
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Failed to load details.'),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _fetchDetails,
                        child: const Text('Retry'),
                      ),
                    ],
                  ))
              : RefreshIndicator(
                  onRefresh: _fetchDetails,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildFinancialCard(_details!['financials']),
                        const SizedBox(height: 16),
                        _buildInfoCard(_details!),
                        const SizedBox(height: 16),
                        _buildPaymentsCard(_details!['repayments'] as List, context),
                      ],
                    ),
                  ),
                ),
    );
  }
 // -------------------------------------------------------------------
  // *****                HELPER WIDGETS START HERE                *****
  // -------------------------------------------------------------------

  Widget _buildFinancialCard(Map<String, dynamic> financials) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildFinancialItem('Total Borrowed', '৳${financials['total_borrowed']}', Colors.black87),
            _buildFinancialItem('Total Repaid', '৳${financials['total_repaid']}', Colors.green.shade700),
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

  Widget _buildInfoCard(Map<String, dynamic> details) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Loan Information', style: Theme.of(context).textTheme.titleLarge),
            const Divider(height: 24),
            _buildInfoRow('Lender/Source:', details['lender_name']),
            _buildInfoRow('Purpose:', details['purpose']),
            _buildInfoRow('Date Borrowed:', details['date_borrowed']),
            _buildInfoRow('Status:', details['status']),
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
            width: 110, // A bit wider for "Date Borrowed"
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
          ),
          Expanded(child: Text(value)),
        ],
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
            Text('Repayment History', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            if (payments.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No repayments recorded for this loan.'),
              ))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: payments.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final payment = payments[index];
                  return ListTile(
                    title: Text(currencyFormat.format(double.tryParse(payment['amount'].replaceAll(',', '')) ?? 0)),
                    subtitle: Text(payment['date']),
                    trailing: payment['notes'] != null ? IconButton(
                      icon: const Icon(Icons.info_outline, color: Colors.grey),
                      tooltip: payment['notes'],
                      onPressed: () {},
                    ) : null,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}