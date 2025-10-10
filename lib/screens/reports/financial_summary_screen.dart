import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../l10n/app_localizations.dart';

class FinancialSummaryScreen extends StatefulWidget {
  const FinancialSummaryScreen({super.key});
  @override
  State<FinancialSummaryScreen> createState() => _FinancialSummaryScreenState();
}

class _FinancialSummaryScreenState extends State<FinancialSummaryScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _summaryData;
  bool _isLoading = true;

  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchSummary();
  }

  Future<void> _fetchSummary() async {
    setState(() => _isLoading = true);
    final data = await _apiService.getFinancialSummary(startDate: _startDate, endDate: _endDate);
    if (mounted) setState(() { _summaryData = data; _isLoading = false; });
  }
  
  Future<void> _showDateRangePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() { _startDate = picked.start; _endDate = picked.end; });
      _fetchSummary();
    }
  }

  Future<void> _exportToPDF() async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generating PDF...')));
    
    final pdfBytes = await _apiService.downloadFinancialSummaryPDF(startDate: _startDate, endDate: _endDate);

    if (pdfBytes != null && mounted) {
      try {
        // Get the directory to save the file
        final dir = await getApplicationDocumentsDirectory();
        // Create the file path
        final file = File('${dir.path}/financial-summary-report.pdf');
        // Write the PDF data to the file
        await file.writeAsBytes(pdfBytes);
        // Open the file with the default PDF viewer
        await OpenFilex.open(file.path);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving or opening PDF: $e'), backgroundColor: Colors.red));
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to download PDF.'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.financialSummary),
        actions: [IconButton(icon: const Icon(Icons.calendar_month), onPressed: _showDateRangePicker),
         IconButton(icon: const Icon(Icons.picture_as_pdf), onPressed: _exportToPDF, tooltip: 'Export to PDF')],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _summaryData == null
              ? Center(child: ElevatedButton(onPressed: _fetchSummary, child: Text(l10n.retry)))
              : RefreshIndicator(
                  onRefresh: _fetchSummary,
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      _buildFilterHeader(l10n),
                      const SizedBox(height: 16),
                      GridView.count(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 2.0,
                        children: [
                          _buildSummaryCard(l10n.openingBalance, '৳${_summaryData!['openingBalance']}', Colors.grey.shade700),
                          _buildSummaryCard(l10n.closingBalance, '৳${_summaryData!['currentBalance']}', Theme.of(context).primaryColor, isBold: true),
                          _buildSummaryCard(l10n.totalIncomePeriod, '৳${_summaryData!['totalIncome']}', Colors.green.shade600),
                          _buildSummaryCard(l10n.totalExpensesPeriod, '৳${_summaryData!['totalExpenses']}', Colors.red.shade600),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildBreakdownCard(l10n.incomeCredits, _summaryData!['summaries']['income'], l10n),
                      const SizedBox(height: 16),
                      _buildBreakdownCard(l10n.expensesDebits, _summaryData!['summaries']['expense'], l10n),
                      const SizedBox(height: 24),
                      _buildNetCashFlowCard(_summaryData!['netCashFlow'], l10n),
                    ],
                  ),
                ),
    );
  }
  
  Widget _buildFilterHeader(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.calendar_month, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Text('${l10n.period} ${DateFormat.yMMMd().format(_startDate)} - ${DateFormat.yMMMd().format(_endDate)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ]),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color, {bool isBold = false}) {
    return Card(elevation: 2.0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), child: Padding(padding: const EdgeInsets.all(12.0), child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
      Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
      const SizedBox(height: 8),
      Text(value, textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: isBold ? FontWeight.bold : FontWeight.w600, color: color)),
    ])));
  }

  String _getTranslatedSummaryKey(String key, AppLocalizations l10n) {
    switch (key) {
      case 'Booking Payments': return l10n.bookingPayments;
      case 'Other Income': return l10n.otherIncome;
      case 'Borrowed Funds': return l10n.borrowedFunds;
      case 'General Expenses': return l10n.generalExpenses;
      case 'Salary Payments': return l10n.salaryPayments;
      case 'Loan Repayments': return l10n.loanRepayments;
      default: return key;
    }
  }

  Widget _buildBreakdownCard(String title, Map<String, dynamic> data, AppLocalizations l10n) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '৳');
    double total = data.values.fold(0.0, (sum, item) {
        final amount = (item is num) ? item.toDouble() : double.tryParse(item.toString().replaceAll(',', '')) ?? 0.0;
        return sum + amount;
    });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            ...data.entries.map((entry) {
              final amount = (entry.value is num) ? entry.value : double.tryParse(entry.value.toString()) ?? 0.0;
              return ListTile(
                title: Text(_getTranslatedSummaryKey(entry.key, l10n)),
                trailing: Text(currencyFormat.format(amount)),
                dense: true,
              );
            }).toList(),
            const Divider(),
            ListTile(
              title: Text(title == l10n.incomeCredits ? l10n.totalIncome : l10n.totalExpenses, style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: Text(currencyFormat.format(total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              dense: true,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNetCashFlowCard(String netCashFlow, AppLocalizations l10n) {
    final isPositive = !netCashFlow.startsWith('-');
    final amount = double.tryParse(netCashFlow.replaceAll(',', '')) ?? 0.0;
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '৳');

    return Card(
      color: isPositive ? Colors.green.shade50 : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(l10n.netCashFlow, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              currencyFormat.format(amount),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isPositive ? Colors.green.shade800 : Colors.red.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}