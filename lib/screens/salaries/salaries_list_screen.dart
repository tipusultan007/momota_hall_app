import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import 'salary_detail_screen.dart';

class SalariesListScreen extends StatefulWidget {
  const SalariesListScreen({super.key});
  @override
  State<SalariesListScreen> createState() => _SalariesListScreenState();
}

class _SalariesListScreenState extends State<SalariesListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _salariesFuture;

  @override
  void initState() {
    super.initState();
    _salariesFuture = _apiService.getSalaries();
  }

  Future<void> _refreshSalaries() async {
    setState(() {
      _salariesFuture = _apiService.getSalaries();
    });
  }

  Future<void> _showGenerateDialog() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'Select Month and Year to Generate',
    );

    if (picked != null) {
      // Format to "YYYY-MM"
      String monthYear = DateFormat('yyyy-MM').format(picked);
      
      // Show loading indicator
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()));

      bool success = await _apiService.generateSalaries(monthYear);
      
      Navigator.of(context).pop(); // Close loading indicator

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Salaries for $monthYear generated successfully!' : 'Failed to generate salaries.'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        if (success) {
          _refreshSalaries();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Salaries'),
        actions: [
          IconButton(
            onPressed: _showGenerateDialog,
            icon: const Icon(Icons.add_card),
            tooltip: 'Generate Salaries for a Month',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshSalaries,
        child: FutureBuilder<List<dynamic>>(
          future: _salariesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No salary records found.\nTry generating for a month.', textAlign: TextAlign.center));
            }

            final salaries = snapshot.data!;
            return ListView.builder(
              itemCount: salaries.length,
              itemBuilder: (context, index) {
                final salary = salaries[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(salary['worker_name'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(salary['salary_month'] ?? ''),
                    trailing: Chip(
                      label: Text(salary['status'] ?? ''),
                      backgroundColor: _getStatusColor(salary['status']),
                      labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    onTap: () async {
                      // Navigate and wait for a potential refresh signal
                      final needsRefresh = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (context) => SalaryDetailScreen(monthlySalaryId: salary['id']),
                        ),
                      );
                      if (needsRefresh == true) {
                        _refreshSalaries();
                      }
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
      case 'Paid': return Colors.green.shade600;
      case 'Partially Paid': return Colors.orange.shade700;
      case 'Unpaid': return Colors.red.shade600;
      default: return Colors.grey;
    }
  }
}