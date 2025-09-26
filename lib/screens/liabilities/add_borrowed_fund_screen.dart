// lib/screens/liabilities/add_borrowed_fund_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class AddBorrowedFundScreen extends StatefulWidget {
  const AddBorrowedFundScreen({super.key});
  @override
  State<AddBorrowedFundScreen> createState() => _AddBorrowedFundScreenState();
}

class _AddBorrowedFundScreenState extends State<AddBorrowedFundScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  
  final _amountController = TextEditingController();
  final _dateController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
  final _purposeController = TextEditingController();
  
  int? _selectedLenderId;
  List<dynamic>? _lenders;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchLenders();
  }

  Future<void> _fetchLenders() async {
    final lenders = await _apiService.getLenders();
    setState(() {
      _lenders = lenders;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });

      final success = await _apiService.addBorrowedFund(
        lenderId: _selectedLenderId!,
        amount: _amountController.text,
        date: _dateController.text,
        purpose: _purposeController.text,
      );
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fund record created successfully!'), backgroundColor: Colors.green));
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to create record.'), backgroundColor: Colors.red));
          setState(() { _isLoading = false; });
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Record Borrowed Fund')),
      body: _lenders == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<int>(
                      value: _selectedLenderId,
                      items: _lenders!.map((lender) => DropdownMenuItem<int>(
                        value: lender['id'] as int,
                        child: Text(lender['name']),
                      )).toList(),
                      onChanged: (value) => setState(() => _selectedLenderId = value),
                      decoration: const InputDecoration(labelText: 'Lender/Source', border: OutlineInputBorder()),
                      validator: (value) => value == null ? 'Please select a lender' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(labelText: 'Amount Borrowed', border: OutlineInputBorder(), prefixText: '৳'),
                      keyboardType: TextInputType.number,
                      validator: (value) => (value == null || value.isEmpty) ? 'Please enter an amount' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dateController,
                      decoration: const InputDecoration(labelText: 'Date', border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_today)),
                      readOnly: true,
                      onTap: () async {
                        DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                        if (picked != null) _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _purposeController,
                      decoration: const InputDecoration(labelText: 'Purpose', border: OutlineInputBorder()),
                      validator: (value) => (value == null || value.isEmpty) ? 'Please enter a purpose' : null,
                    ),
                    const SizedBox(height: 32),
                    _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _submitForm,
                          child: const Text('Save Record'),
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        )
                  ],
                ),
              ),
            ),
    );
  }
}