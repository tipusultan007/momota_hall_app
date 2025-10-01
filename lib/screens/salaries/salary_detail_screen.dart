import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../l10n/app_localizations.dart';
import '../../services/permission_service.dart';

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
  bool _didChange = false;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    if (_details == null) setState(() => _isLoading = true);
    final details = await _apiService.getSalaryDetails(widget.monthlySalaryId);
    if (mounted) setState(() { _details = details; _isLoading = false; });
  }

  void _showAddPaymentDialog(AppLocalizations l10n) {
    final amountController = TextEditingController();
    final dateController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.recordPayment),
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
            ElevatedButton(onPressed: () => _submitPayment(amountController.text, dateController.text, notesController.text, l10n), child: Text(l10n.submit)),
          ],
        );
      },
    );
  }

  Future<void> _submitPayment(String amount, String date, String notes, AppLocalizations l10n) async {
    Navigator.of(context).pop();
    setState(() => _isLoading = true);
    final updatedSalary = await _apiService.addSalaryPayment(monthlySalaryId: widget.monthlySalaryId, amount: amount, date: date, notes: notes);
    if (mounted) {
      if (updatedSalary != null) {
        _didChange = true;
        setState(() => _details = updatedSalary);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.paymentRecordedSuccess), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.failedToRecordPayment), backgroundColor: Colors.red));
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    bool canAddPayment = false;
    if (_details != null && _details!['financials'] != null) {
      final financials = _details!['financials'];
      double dueAmount = double.tryParse(financials['due_amount'].replaceAll(',', '')) ?? 0;
      canAddPayment = dueAmount > 0;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.salaryDetails),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(_didChange),
        ),
      ),
      floatingActionButton: !_isLoading && canAddPayment && PermissionService().can('manage salary payments')
          ? FloatingActionButton(onPressed: () => _showAddPaymentDialog(l10n), child: const Icon(Icons.add), tooltip: l10n.recordPayment)
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _details == null
              ? Center(child: Text(l10n.failedToLoadSalary))
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
                        _buildPaymentsCard(_details!['payments'] as List, context),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildFinancialCard(Map<String, dynamic> financials, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildFinancialItem(l10n.totalSalary, '৳${financials['total_salary']}', Colors.black87),
            _buildFinancialItem(l10n.totalPaid, '৳${financials['paid_amount']}', Colors.green.shade700),
            _buildFinancialItem(l10n.amountDue, '৳${financials['due_amount']}', Colors.red.shade700, isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialItem(String label, String value, Color color, {bool isBold = false}) {
    return Column(children: [
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(fontSize: 18, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color)),
    ]);
  }

  Widget _buildInfoCard(Map<String, dynamic> salary, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.salaryInformation, style: Theme.of(context).textTheme.titleLarge),
            const Divider(height: 24),
            _buildInfoRow(l10n.worker, salary['worker_name']),
            _buildInfoRow(l10n.salaryFor, salary['salary_month']),
            _buildInfoRow(l10n.status, salary['status']),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 90, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54))),
        Expanded(child: Text(value)),
      ]),
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
            Text(l10n.paymentHistory, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            if (payments.isEmpty) Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text(l10n.noPaymentsThisMonth)))
            else ListView.separated(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: payments.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final payment = payments[index];
                return ListTile(
                  title: Text(currencyFormat.format(double.tryParse(payment['amount'].replaceAll(',', '')) ?? 0)),
                  subtitle: Text(payment['date']),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}