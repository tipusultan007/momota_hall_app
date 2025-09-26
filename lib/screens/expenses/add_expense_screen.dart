// lib/screens/expenses/add_expense_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class AddExpenseScreen extends StatefulWidget {
  // Add an optional expenseId. If it's not null, we are in "Edit" mode.
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
  bool _isLoading = true; // Start loading immediately
  bool get _isEditMode => widget.expenseId != null;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }
  
  // New method to load all necessary data
  Future<void> _initializeData() async {
    // Fetch categories regardless of mode
    final categories = await _apiService.getExpenseCategories();
    
    // If in Edit mode, fetch the specific expense data
    if (_isEditMode) {
      final expenseData = await _apiService.getExpense(widget.expenseId!);
      if (expenseData != null) {
        // Populate controllers with existing data
        _amountController.text = expenseData['amount'].replaceAll(',', '');
        _dateController.text = DateFormat('yyyy-MM-dd').format(DateFormat('MMM d, yyyy').parse(expenseData['date']));
        _descriptionController.text = expenseData['description'] ?? '';
        _selectedCategoryId = categories?.firstWhere((cat) => cat['name'] == expenseData['category_name'], orElse: () => null)?['id'];
      }
    } else {
      // In Add mode, just set the default date
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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Expense ${_isEditMode ? 'updated' : 'logged'} successfully!'), backgroundColor: Colors.green));
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to ${_isEditMode ? 'update' : 'log'} expense.'), backgroundColor: Colors.red));
          setState(() { _isLoading = false; });
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditMode ? 'Edit Expense' : 'Log New Expense')),
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
                      decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                      validator: (value) => value == null ? 'Please select a category' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder(), prefixText: '৳'),
                      keyboardType: TextInputType.number,
                      validator: (value) => (value == null || value.isEmpty) ? 'Please enter an amount' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dateController,
                      decoration: const InputDecoration(labelText: 'Date', border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_today)),
                      readOnly: true,
                      onTap: () async {
                        DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.tryParse(_dateController.text) ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                        if (picked != null) _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Description (Optional)', border: OutlineInputBorder()),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _submitExpense,
                      child: Text(_isEditMode ? 'Update Expense' : 'Save Expense'),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}