// lib/screens/incomes/add_income_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class AddIncomeScreen extends StatefulWidget {
  // Add an optional incomeId. If it's not null, we are in "Edit" mode.
  final int? incomeId;
  const AddIncomeScreen({super.key, this.incomeId});
  
  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  int? _selectedCategoryId;
  List<dynamic>? _categories;
  bool _isLoading = true; // Start loading immediately
  bool get _isEditMode => widget.incomeId != null;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }
  
  // New method to load all necessary data
  Future<void> _initializeData() async {
    // Fetch categories regardless of mode
    final categories = await _apiService.getIncomeCategories();
    
    // If in Edit mode, fetch the specific income data
    if (_isEditMode) {
      final incomeData = await _apiService.getIncome(widget.incomeId!);
      if (incomeData != null) {
        // Populate controllers with existing data
        _amountController.text = incomeData['amount'].replaceAll(',', '');
        _dateController.text = DateFormat('yyyy-MM-dd').format(DateFormat('MMM d, yyyy').parse(incomeData['date']));
        _descriptionController.text = incomeData['description'] ?? '';
        _selectedCategoryId = categories?.firstWhere((cat) => cat['name'] == incomeData['category_name'], orElse: () => null)?['id'];
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

  Future<void> _submitIncome() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });

      final apiCall = _isEditMode
          ? _apiService.updateIncome(
              id: widget.incomeId!,
              categoryId: _selectedCategoryId!,
              amount: _amountController.text,
              date: _dateController.text,
              description: _descriptionController.text,
            )
          : _apiService.addIncome(
              categoryId: _selectedCategoryId!,
              amount: _amountController.text,
              date: _dateController.text,
              description: _descriptionController.text,
            );
            
      final result = await apiCall;
      
      if (mounted) {
        if (result != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Income ${_isEditMode ? 'updated' : 'logged'} successfully!'), backgroundColor: Colors.green));
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to ${_isEditMode ? 'update' : 'log'} income.'), backgroundColor: Colors.red));
          setState(() { _isLoading = false; });
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditMode ? 'Edit Income' : 'Log New Income')),
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
                      onPressed: _submitIncome,
                      child: Text(_isEditMode ? 'Update Income' : 'Save Income'),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}