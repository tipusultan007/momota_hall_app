import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../services/permission_service.dart';
import '../../l10n/app_localizations.dart';

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
    if (mounted) setState(() { _details = details; _isLoading = false; });
  }

  void _showAddRepaymentDialog(AppLocalizations l10n) {
    final amountController = TextEditingController();
    final dateController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.recordRepayment),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: TextField(controller: amountController, decoration: InputDecoration(labelText: l10n.amount, border: const OutlineInputBorder()), keyboardType: TextInputType.number)),
                Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: TextField(controller: dateController, decoration: InputDecoration(labelText: l10n.date, border: const OutlineInputBorder(), suffixIcon: const Icon(Icons.calendar_today)), readOnly: true, onTap: () async {
                  DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                  if (picked != null) dateController.text = DateFormat('yyyy-MM-dd').format(picked);
                })),
                Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: TextField(controller: notesController, decoration: InputDecoration(labelText: l10n.notesOptional, border: const OutlineInputBorder()))),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
            ElevatedButton(onPressed: () => _submitRepayment(amountController.text, dateController.text, notesController.text, l10n), child: Text(l10n.submit)),
          ],
        );
      },
    );
  }

  Future<void> _submitRepayment(String amount, String date, String notes, AppLocalizations l10n) async {
    Navigator.of(context).pop();
    setState(() { _isLoading = true; });
    final updatedFund = await _apiService.addFundRepayment(borrowedFundId: widget.borrowedFundId, amount: amount, date: date, notes: notes);
    if (mounted) {
      if (updatedFund != null) {
        _didChange = true;
        setState(() { _details = updatedFund; });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.repaymentRecordedSuccess), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.failedToRecordRepayment), backgroundColor: Colors.red));
      }
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    bool canAddPayment = false;
    if (_details != null && _details!['financials'] != null) {
      double dueAmount = double.tryParse(_details!['financials']['due_amount'].replaceAll(',', '')) ?? 0;
      canAddPayment = dueAmount > 0;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.manageRepayments),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(_didChange),
        ),
      ),
      floatingActionButton: !_isLoading && canAddPayment && PermissionService().can('manage liability repayments')
          ? FloatingActionButton(onPressed: () => _showAddRepaymentDialog(l10n), child: const Icon(Icons.add), tooltip: l10n.recordRepayment)
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _details == null
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(l10n.failedToLoadDetails), const SizedBox(height: 10), ElevatedButton(onPressed: _fetchDetails, child: Text(l10n.retry))]))
              : RefreshIndicator(
                  onRefresh: _fetchDetails,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildFinancialCard(_details!['financials'], l10n),
                        const SizedBox(height: 16),
                        _buildInfoCard(_details!, l10n),
                        const SizedBox(height: 16),
                        _buildPaymentsCard(_details!['repayments'] as List, context),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildFinancialCard(Map<String, dynamic> financials, AppLocalizations l10n) {
    return Card(child: Padding(padding: const EdgeInsets.all(16.0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      _buildFinancialItem(l10n.totalBorrowed, '৳${financials['total_borrowed']}', Colors.black87),
      _buildFinancialItem(l10n.totalRepaid, '৳${financials['total_repaid']}', Colors.green.shade700),
      _buildFinancialItem(l10n.amountDue, '৳${financials['due_amount']}', Colors.red.shade700, isBold: true),
    ])));
  }

  Widget _buildFinancialItem(String label, String value, Color color, {bool isBold = false}) {
    return Column(children: [
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(fontSize: 18, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color)),
    ]);
  }

  Widget _buildInfoCard(Map<String, dynamic> details, AppLocalizations l10n) {
    return Card(child: Padding(padding: const EdgeInsets.all(16.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l10n.loanInformation, style: Theme.of(context).textTheme.titleLarge),
      const Divider(height: 24),
      _buildInfoRow(l10n.lenderSource, details['lender_name']),
      _buildInfoRow(l10n.purpose, details['purpose']),
      _buildInfoRow(l10n.dateBorrowed, details['date_borrowed']),
      _buildInfoRow(l10n.status, _getStatusText(details['status'], l10n)),
    ])));
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4.0), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 110, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54))),
      Expanded(child: Text(value)),
    ]));
  }
  
  Widget _buildPaymentsCard(List payments, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '৳');
    return Card(child: Padding(padding: const EdgeInsets.all(16.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l10n.repaymentHistory, style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 12),
      if (payments.isEmpty) Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text(l10n.noRepaymentsRecorded)))
      else ListView.separated(
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: payments.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final payment = payments[index];
          return ListTile(
            title: Text(currencyFormat.format(double.tryParse(payment['amount'].replaceAll(',', '')) ?? 0)),
            subtitle: Text(payment['date']),
            trailing: payment['notes'] != null && payment['notes'].isNotEmpty ? IconButton(icon: const Icon(Icons.info_outline, color: Colors.grey), tooltip: payment['notes'], onPressed: () {}) : null,
          );
        },
      ),
    ])));
  }

  String _getStatusText(String? status, AppLocalizations l10n) {
    switch (status) {
      case 'Repaid': return l10n.statusRepaid;
      case 'Partially Repaid': return l10n.statusPartiallyRepaid;
      case 'Due': return l10n.statusDue;
      default: return status ?? '';
    }
  }
}