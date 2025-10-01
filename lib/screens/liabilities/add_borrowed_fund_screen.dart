import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../l10n/app_localizations.dart';

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
  bool _isLoading = true; // Start loading for categories

  @override
  void initState() {
    super.initState();
    _fetchLenders();
  }

  Future<void> _fetchLenders() async {
    final lenders = await _apiService.getLenders();
    if(mounted) {
      setState(() {
        _lenders = lenders;
        _isLoading = false;
      });
    }
  }

  Future<void> _submitForm() async {
    final l10n = AppLocalizations.of(context)!;
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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.fundRecordCreatedSuccess), backgroundColor: Colors.green));
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.failedToCreateRecord), backgroundColor: Colors.red));
          setState(() { _isLoading = false; });
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.recordBorrowedFund)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if(_lenders != null)
                    DropdownButtonFormField<int>(
                      value: _selectedLenderId,
                      items: _lenders!.map((lender) => DropdownMenuItem<int>(
                        value: lender['id'] as int,
                        child: Text(lender['name']),
                      )).toList(),
                      onChanged: (value) => setState(() => _selectedLenderId = value),
                      decoration: InputDecoration(labelText: l10n.lenderSource, border: const OutlineInputBorder()),
                      validator: (value) => value == null ? l10n.pleaseSelectLender : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(labelText: l10n.amountBorrowed, border: const OutlineInputBorder(), prefixText: '৳'),
                      keyboardType: TextInputType.number,
                      validator: (value) => (value == null || value.isEmpty) ? l10n.pleaseEnterAmount : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dateController,
                      decoration: InputDecoration(labelText: l10n.date, border: const OutlineInputBorder(), suffixIcon: const Icon(Icons.calendar_today)),
                      readOnly: true,
                      onTap: () async {
                        DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                        if (picked != null) _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _purposeController,
                      decoration: InputDecoration(labelText: l10n.purpose, border: const OutlineInputBorder()),
                      validator: (value) => (value == null || value.isEmpty) ? l10n.pleaseEnterPurpose : null,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      child: Text(l10n.saveRecord),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}