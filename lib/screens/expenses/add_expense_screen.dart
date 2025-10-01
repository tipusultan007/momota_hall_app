import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../l10n/app_localizations.dart'; 

class AddExpenseScreen extends StatefulWidget {
  final int? expenseId;
  const AddExpenseScreen({super.key, this.expenseId});
  
  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  int? _selectedCategoryId;
  List<dynamic>? _categories;
  bool _isLoading = true;
  bool get _isEditMode => widget.expenseId != null;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }
  
  Future<void> _initializeData() async {
    final categories = await _apiService.getExpenseCategories();
    if (_isEditMode) {
      final expenseData = await _apiService.getExpense(widget.expenseId!);
      if (expenseData != null) {
        _amountController.text = expenseData['amount'].replaceAll(',', '');
        _dateController.text = DateFormat('yyyy-MM-dd').format(DateFormat('MMM d, yyyy').parse(expenseData['date']));
        _descriptionController.text = expenseData['description'] ?? '';
        _selectedCategoryId = categories?.firstWhere((cat) => cat['name'] == expenseData['category_name'], orElse: () => null)?['id'];
      }
    } else {
      _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
    
    if (mounted) {
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    }
  }

  Future<void> _submitExpense() async {
    final l10n = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });

      final apiCall = _isEditMode
          ? _apiService.updateExpense(
              id: widget.expenseId!,
              categoryId: _selectedCategoryId!,
              amount: _amountController.text,
              date: _dateController.text,
              description: _descriptionController.text,
            )
          : _apiService.addExpense(
              categoryId: _selectedCategoryId!,
              amount: _amountController.text,
              date: _dateController.text,
              description: _descriptionController.text,
            );
            
      final result = await apiCall;
      
      if (mounted) {
        if (result != null) {
          final successMessage = _isEditMode ? l10n.expenseUpdatedSuccess : l10n.expenseLoggedSuccess;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(successMessage), backgroundColor: Colors.green));
          Navigator.of(context).pop(true);
        } else {
          final errorMessage = _isEditMode ? l10n.failedToUpdateExpense : l10n.failedToLogExpense;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage), backgroundColor: Colors.red));
          setState(() { _isLoading = false; });
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(_isEditMode ? l10n.editExpense : l10n.logNewExpense)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_categories != null)
                    DropdownButtonFormField<int>(
                      value: _selectedCategoryId,
                      items: _categories!.map((cat) => DropdownMenuItem<int>(
                        value: cat['id'] as int,
                        child: Text(cat['name']),
                      )).toList(),
                      onChanged: (value) => setState(() => _selectedCategoryId = value),
                      decoration: InputDecoration(labelText: l10n.category, border: const OutlineInputBorder()),
                      validator: (value) => value == null ? l10n.pleaseSelectCategory : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(labelText: l10n.amount, border: const OutlineInputBorder(), prefixText: '৳'),
                      keyboardType: TextInputType.number,
                      validator: (value) => (value == null || value.isEmpty) ? l10n.pleaseEnterAmount : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dateController,
                      decoration: InputDecoration(labelText: l10n.date, border: const OutlineInputBorder(), suffixIcon: const Icon(Icons.calendar_today)),
                      readOnly: true,
                      onTap: () async {
                        DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.tryParse(_dateController.text) ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                        if (picked != null) _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: l10n.descriptionOptional, border: const OutlineInputBorder()),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitExpense,
                      child: Text(_isEditMode ? l10n.updateExpense : l10n.saveExpense),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}